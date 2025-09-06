import Foundation

public struct SpotifyToken: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let expirationDate: Date
    
    public init(accessToken: String, refreshToken: String, expirationDate: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expirationDate = expirationDate
    }
    
    public var isExpired: Bool {
        return Date() >= expirationDate
    }
    
    public var isValid: Bool {
        return !accessToken.isEmpty && !refreshToken.isEmpty && !isExpired
    }
}

public enum TokenStorageError: Error {
    case tokenNotFound
    case invalidTokenData
    case keychainError(KeychainError)
    
    public var localizedDescription: String {
        switch self {
        case .tokenNotFound:
            return "저장된 토큰을 찾을 수 없습니다."
        case .invalidTokenData:
            return "토큰 데이터가 유효하지 않습니다."
        case .keychainError(let error):
            return "키체인 오류: \(error.localizedDescription)"
        }
    }
}

public protocol TokenStorageProtocol {
    func saveToken(_ token: SpotifyToken) throws
    func loadToken() throws -> SpotifyToken
    func deleteToken() throws
    func clearTokens() throws
    func hasValidToken() -> Bool
    func getCurrentAccessToken() throws -> String
    func getCurrentRefreshToken() throws -> String
}

public final class TokenStorage: TokenStorageProtocol, Sendable {
    public static let shared = TokenStorage()
    
    private let keychainManager: KeychainManagerProtocol
    private let accessTokenKey = "spotify_access_token"
    private let refreshTokenKey = "spotify_refresh_token"
    private let expirationDateKey = "spotify_expiration_date"
    
    public init(keychainManager: KeychainManagerProtocol = KeychainManager.shared) {
        self.keychainManager = keychainManager
    }
    
    public func saveToken(_ token: SpotifyToken) throws {
        do {
            guard let accessTokenData = token.accessToken.data(using: .utf8),
                  let refreshTokenData = token.refreshToken.data(using: .utf8) else {
                throw TokenStorageError.invalidTokenData
            }
            
            try keychainManager.save(accessTokenData, for: accessTokenKey)
            try keychainManager.save(refreshTokenData, for: refreshTokenKey)
            
            let expirationData = try JSONEncoder().encode(token.expirationDate)
            try keychainManager.save(expirationData, for: expirationDateKey)
        } catch let error as KeychainError {
            throw TokenStorageError.keychainError(error)
        } catch {
            throw TokenStorageError.invalidTokenData
        }
    }
    
    public func loadToken() throws -> SpotifyToken {
        do {
            let accessTokenData = try keychainManager.load(for: accessTokenKey)
            let refreshTokenData = try keychainManager.load(for: refreshTokenKey)
            let expirationData = try keychainManager.load(for: expirationDateKey)
            
            guard let accessToken = String(data: accessTokenData, encoding: .utf8),
                  let refreshToken = String(data: refreshTokenData, encoding: .utf8) else {
                throw TokenStorageError.invalidTokenData
            }
            
            let expirationDate = try JSONDecoder().decode(Date.self, from: expirationData)
            
            return SpotifyToken(
                accessToken: accessToken,
                refreshToken: refreshToken,
                expirationDate: expirationDate
            )
        } catch KeychainError.itemNotFound {
            throw TokenStorageError.tokenNotFound
        } catch let error as KeychainError {
            throw TokenStorageError.keychainError(error)
        } catch {
            throw TokenStorageError.invalidTokenData
        }
    }
    
    public func deleteToken() throws {
        try clearTokens()
    }
    
    public func clearTokens() throws {
        do {
            try keychainManager.delete(for: accessTokenKey)
            try keychainManager.delete(for: refreshTokenKey)
            try keychainManager.delete(for: expirationDateKey)
        } catch let error as KeychainError {
            throw TokenStorageError.keychainError(error)
        }
    }
    
    public func hasValidToken() -> Bool {
        do {
            let token = try loadToken()
            return token.isValid
        } catch {
            return false
        }
    }
    
    public func getCurrentAccessToken() throws -> String {
        let token = try loadToken()
        guard token.isValid else {
            throw TokenStorageError.tokenNotFound
        }
        return token.accessToken
    }
    
    public func getCurrentRefreshToken() throws -> String {
        let token = try loadToken()
        return token.refreshToken
    }
}