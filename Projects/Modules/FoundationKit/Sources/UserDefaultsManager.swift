import Foundation

// MARK: - UserDefaultsKey
public enum UserDefaultsKey: String, CaseIterable {
    case spotifySession = "SpotifySession"
    case userPreferences = "UserPreferences"
    case appSettings = "AppSettings"
    
    var key: String {
        return self.rawValue
    }
}

// MARK: - UserDefaultsManager
public final class UserDefaultsManager {
    public static let shared = UserDefaultsManager()
    
    private let userDefaults: UserDefaults
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Save Methods
    
    /// 값을 UserDefaults에 저장
    public func save<T>(_ value: T, for key: UserDefaultsKey) {
        userDefaults.set(value, forKey: key.key)
    }
    
    /// Codable 객체를 UserDefaults에 저장
    public func save<T: Codable>(_ value: T, for key: UserDefaultsKey) {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key.key)
        } catch {
            print("UserDefaultsManager: Failed to encode object for key \(key.key): \(error)")
        }
    }
    
    /// NSCoding 객체를 UserDefaults에 저장
    public func saveSecurely<T: NSObject & NSSecureCoding>(_ value: T, for key: UserDefaultsKey) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
            userDefaults.set(data, forKey: key.key)
        } catch {
            print("UserDefaultsManager: Failed to archive object for key \(key.key): \(error)")
        }
    }
    
    // MARK: - Get Methods
    
    /// UserDefaults에서 값을 가져옴
    public func get<T>(_ type: T.Type, for key: UserDefaultsKey) -> T? {
        return userDefaults.object(forKey: key.key) as? T
    }
    
    /// UserDefaults에서 Codable 객체를 가져옴
    public func getCodable<T: Codable>(_ type: T.Type, for key: UserDefaultsKey) -> T? {
        guard let data = userDefaults.data(forKey: key.key) else { return nil }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("UserDefaultsManager: Failed to decode object for key \(key.key): \(error)")
            return nil
        }
    }
    
    /// UserDefaults에서 NSCoding 객체를 가져옴
    public func getSecurely<T: NSObject & NSSecureCoding>(_ type: T.Type, for key: UserDefaultsKey) -> T? {
        guard let data = userDefaults.data(forKey: key.key) else { return nil }
        
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: type, from: data)
        } catch {
            print("UserDefaultsManager: Failed to unarchive object for key \(key.key): \(error)")
            return nil
        }
    }
    
    // MARK: - Utility Methods
    
    /// 키에 대한 값이 존재하는지 확인
    public func exists(for key: UserDefaultsKey) -> Bool {
        return userDefaults.object(forKey: key.key) != nil
    }
    
    /// 특정 키의 값을 제거
    public func remove(for key: UserDefaultsKey) {
        userDefaults.removeObject(forKey: key.key)
    }
    
    /// 모든 UserDefaults 값을 제거 (주의: 앱의 모든 설정이 초기화됨)
    public func removeAll() {
        UserDefaultsKey.allCases.forEach { key in
            userDefaults.removeObject(forKey: key.key)
        }
    }
    
    /// UserDefaults 변경사항을 즉시 저장
    public func synchronize() {
        userDefaults.synchronize()
    }
}

// MARK: - Convenience Methods for Common Types
extension UserDefaultsManager {
    
    /// Bool 값 저장
    public func setBool(_ value: Bool, for key: UserDefaultsKey) {
        userDefaults.set(value, forKey: key.key)
    }
    
    /// Bool 값 가져오기
    public func getBool(for key: UserDefaultsKey, defaultValue: Bool = false) -> Bool {
        return userDefaults.bool(forKey: key.key)
    }
    
    /// String 값 저장
    public func setString(_ value: String, for key: UserDefaultsKey) {
        userDefaults.set(value, forKey: key.key)
    }
    
    /// String 값 가져오기
    public func getString(for key: UserDefaultsKey) -> String? {
        return userDefaults.string(forKey: key.key)
    }
    
    /// Int 값 저장
    public func setInt(_ value: Int, for key: UserDefaultsKey) {
        userDefaults.set(value, forKey: key.key)
    }
    
    /// Int 값 가져오기
    public func getInt(for key: UserDefaultsKey, defaultValue: Int = 0) -> Int {
        return userDefaults.integer(forKey: key.key)
    }
}
