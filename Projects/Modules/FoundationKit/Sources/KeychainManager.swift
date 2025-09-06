import Foundation
import Security

public enum KeychainError: Error {
    case itemNotFound
    case duplicateItem
    case unexpectedData
    case unexpectedError(OSStatus)
    
    public var localizedDescription: String {
        switch self {
        case .itemNotFound:
            return "키체인에서 항목을 찾을 수 없습니다."
        case .duplicateItem:
            return "키체인에 중복된 항목이 있습니다."
        case .unexpectedData:
            return "키체인에서 예상치 못한 데이터가 반환되었습니다."
        case .unexpectedError(let status):
            return "키체인 오류 (코드: \(status))"
        }
    }
}

public protocol KeychainManagerProtocol: Sendable {
    func save(_ data: Data, for key: String) throws
    func load(for key: String) throws -> Data
    func delete(for key: String) throws
    func exists(for key: String) -> Bool
}

public final class KeychainManager: KeychainManagerProtocol, Sendable {
    public static let shared = KeychainManager()
    
    private let service: String
    
    public init(service: String = Bundle.main.bundleIdentifier ?? "com.sparkish.spotifystats") {
        self.service = service
    }
    
    public func save(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
            break
        case errSecDuplicateItem:
            try update(data, for: key)
        default:
            throw KeychainError.unexpectedError(status)
        }
    }
    
    public func load(for key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.unexpectedData
            }
            return data
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.unexpectedError(status)
        }
    }
    
    public func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        case errSecSuccess, errSecItemNotFound:
            break
        default:
            throw KeychainError.unexpectedError(status)
        }
    }
    
    public func exists(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func update(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        switch status {
        case errSecSuccess:
            break
        default:
            throw KeychainError.unexpectedError(status)
        }
    }
}

public extension KeychainManager {
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