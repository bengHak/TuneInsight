import XCTest
@testable import FoundationKit

final class FoundationKitTests: XCTestCase {
    
    func testFoundationKitModule() {
        XCTAssertNotNil(FoundationKitModule.shared)
    }
}

final class KeychainManagerTests: XCTestCase {
    var keychainManager: KeychainManager!
    private let testKey = "test_keychain_key"
    private let testService = "com.test.keychain"
    
    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager(service: testService)
        
        try? keychainManager.delete(for: testKey)
    }
    
    override func tearDown() {
        try? keychainManager.delete(for: testKey)
        keychainManager = nil
        super.tearDown()
    }
    
    func testSaveAndLoadData() throws {
        let testData = "Hello, Keychain!".data(using: .utf8)!
        
        try keychainManager.save(testData, for: testKey)
        let loadedData = try keychainManager.load(for: testKey)
        
        XCTAssertEqual(testData, loadedData)
    }
    
    func testSaveAndLoadString() throws {
        let testString = "Hello, Keychain!"
        
        try keychainManager.save(testString, for: testKey)
        let loadedString = try keychainManager.loadString(for: testKey)
        
        XCTAssertEqual(testString, loadedString)
    }
    
    func testUpdateExistingItem() throws {
        let originalData = "Original".data(using: .utf8)!
        let updatedData = "Updated".data(using: .utf8)!
        
        try keychainManager.save(originalData, for: testKey)
        try keychainManager.save(updatedData, for: testKey)
        
        let loadedData = try keychainManager.load(for: testKey)
        XCTAssertEqual(updatedData, loadedData)
    }
    
    func testExistsMethod() throws {
        XCTAssertFalse(keychainManager.exists(for: testKey))
        
        let testData = "Test".data(using: .utf8)!
        try keychainManager.save(testData, for: testKey)
        
        XCTAssertTrue(keychainManager.exists(for: testKey))
    }
    
    func testDeleteItem() throws {
        let testData = "Test".data(using: .utf8)!
        try keychainManager.save(testData, for: testKey)
        
        XCTAssertTrue(keychainManager.exists(for: testKey))
        
        try keychainManager.delete(for: testKey)
        
        XCTAssertFalse(keychainManager.exists(for: testKey))
    }
    
    func testLoadNonExistentItem() {
        XCTAssertThrowsError(try keychainManager.load(for: "non_existent_key")) { error in
            XCTAssertTrue(error is KeychainError)
            if let keychainError = error as? KeychainError {
                if case .itemNotFound = keychainError {
                    // Expected error
                } else {
                    XCTFail("Expected itemNotFound error")
                }
            }
        }
    }
}

final class TokenStorageTests: XCTestCase {
    var tokenStorage: TokenStorage!
    fileprivate var mockKeychainManager: MockKeychainManager!
    
    override func setUp() {
        super.setUp()
        mockKeychainManager = MockKeychainManager()
        tokenStorage = TokenStorage(keychainManager: mockKeychainManager)
    }
    
    override func tearDown() {
        tokenStorage = nil
        mockKeychainManager = nil
        super.tearDown()
    }
    
    func testSaveAndLoadToken() throws {
        let token = SpotifyToken(
            accessToken: "access_token",
            refreshToken: "refresh_token",
            expirationDate: Date().addingTimeInterval(3600)
        )
        
        try tokenStorage.saveToken(token)
        let loadedToken = try tokenStorage.loadToken()
        
        XCTAssertEqual(token.accessToken, loadedToken.accessToken)
        XCTAssertEqual(token.refreshToken, loadedToken.refreshToken)
        XCTAssertEqual(token.expirationDate.timeIntervalSince1970, loadedToken.expirationDate.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testTokenValidation() {
        let validToken = SpotifyToken(
            accessToken: "access_token",
            refreshToken: "refresh_token",
            expirationDate: Date().addingTimeInterval(3600)
        )
        
        let expiredToken = SpotifyToken(
            accessToken: "access_token",
            refreshToken: "refresh_token",
            expirationDate: Date().addingTimeInterval(-3600)
        )
        
        XCTAssertTrue(validToken.isValid)
        XCTAssertFalse(validToken.isExpired)
        
        XCTAssertFalse(expiredToken.isValid)
        XCTAssertTrue(expiredToken.isExpired)
    }
    
    func testHasValidToken() throws {
        XCTAssertFalse(tokenStorage.hasValidToken())
        
        let validToken = SpotifyToken(
            accessToken: "access_token",
            refreshToken: "refresh_token",
            expirationDate: Date().addingTimeInterval(3600)
        )
        
        try tokenStorage.saveToken(validToken)
        XCTAssertTrue(tokenStorage.hasValidToken())
        
        let expiredToken = SpotifyToken(
            accessToken: "access_token",
            refreshToken: "refresh_token",
            expirationDate: Date().addingTimeInterval(-3600)
        )
        
        try tokenStorage.saveToken(expiredToken)
        XCTAssertFalse(tokenStorage.hasValidToken())
    }
    
    func testDeleteToken() throws {
        let token = SpotifyToken(
            accessToken: "access_token",
            refreshToken: "refresh_token",
            expirationDate: Date().addingTimeInterval(3600)
        )
        
        try tokenStorage.saveToken(token)
        XCTAssertTrue(tokenStorage.hasValidToken())
        
        try tokenStorage.deleteToken()
        XCTAssertFalse(tokenStorage.hasValidToken())
    }
}

// MARK: - Mock Classes

fileprivate final class MockKeychainManager: KeychainManagerProtocol, @unchecked Sendable {
    private var storage: [String: Data] = [:]
    
    func save(_ data: Data, for key: String) throws {
        storage[key] = data
    }
    
    func load(for key: String) throws -> Data {
        guard let data = storage[key] else {
            throw KeychainError.itemNotFound
        }
        return data
    }
    
    func delete(for key: String) throws {
        storage.removeValue(forKey: key)
    }
    
    func exists(for key: String) -> Bool {
        return storage[key] != nil
    }
}



extension MockKeychainManager {
    func save(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.unexpectedData
        }
        try save(data, for: key)
    }
    
    func loadString(for key: String) throws -> String {
        let data = try load(for: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedData
        }
        return string
    }
}
