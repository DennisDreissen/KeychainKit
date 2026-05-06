import Foundation
import Security

public struct Keychain: Sendable, KeychainProtocol {

    /// Service associated with this keychain to scope items.
    public let service: String?

    /// Access group used to access and store items. Useful to share keychain items between applications from the same team.
    public let accessGroup: String?

    /// Indicates whether the items synchronize through iCloud with other devices.
    public let synchronizable: Bool

    /// Creates a new Keychain instance.
    ///
    /// - Parameters:
    ///   - service: Scope keychain items to a specific service.
    ///   - accessGroup: Restricts keychain access to apps sharing the same access group.
    ///   - synchronizable: Allow keychain items to synchronize across devices via iCloud.
    public init(
        service: String? = nil,
        accessGroup: String? = nil,
        synchronizable: Bool = false
    ) {
        self.service = service
        self.accessGroup = accessGroup
        self.synchronizable = synchronizable
    }

    /// Get all keys from the keychain with this instance's service, access group and synchronizable setting.
    public func keys() -> [String] {
        var query = getBaseQuery()
        query[kSecReturnAttributes] = true
        query[kSecMatchLimit] = kSecMatchLimitAll

        var result: AnyObject?

        guard SecItemCopyMatching(query as CFDictionary, &result) == noErr,
              let items = result as? [[CFString: Any]]
        else {
            return []
        }

        return items.compactMap {
            $0[kSecAttrAccount] as? String
        }
    }

    /// Retrieves a string value from the keychain for the given key.
    ///
    /// - Parameters:
    ///   - key: The key used to store the string.
    /// - Returns: The stored string.
    /// - Throws: `KeychainError.itemNotFound` if no item exists for the given key.
    /// - Throws: `KeychainError.stringConversionFailed` if the data cannot be decoded as UTF-8.
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    public func string(forKey key: String) throws -> String {
        let data = try data(forKey: key)

        guard let result = String(data: data, encoding: .utf8) else {
            throw KeychainError.stringConversionFailed
        }

        return result
    }

    /// Retrieves a data value from the keychain for the given key.
    ///
    /// - Parameters:
    ///   - key: The key used to store the data.
    /// - Returns: The stored data.
    /// - Throws: `KeychainError.itemNotFound` if no item exists for the given key.
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    public func data(forKey key: String) throws -> Data {
        var query = getBaseQuery()
        query[kSecAttrAccount] = key
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnData] = kCFBooleanTrue

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        }

        if status != noErr {
            throw KeychainError.unexpectedStatus(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.unexpectedStatus(status)
        }

        return data
    }

    /// Stores a string value in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - value: The string to store in the keychain.
    ///   - key: The key to associate with the stored value.
    ///   - accessOption: Controls when the item can be accessed. Defaults to `.accessibleWhenUnlocked`.
    /// - Throws: `KeychainError.stringConversionFailed` if the string cannot be encoded as UTF-8.
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    public func set(
        _ value: String,
        forKey key: String,
        withAccessOption accessOption: KeychainAccessOption = .defaultValue
    ) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.stringConversionFailed
        }

        try set(data, forKey: key, withAccessOption: accessOption)
    }

    /// Stores a data value in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - value: The data to store in the keychain.
    ///   - key: The key to associate with the stored value.
    ///   - accessOption: Controls when the item can be accessed. Defaults to `.accessibleWhenUnlocked`.
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    public func set(
        _ value: Data,
        forKey key: String,
        withAccessOption accessOption: KeychainAccessOption = .defaultValue
    ) throws {
        try remove(forKey: key)

        var query = getBaseQuery()
        query[kSecAttrAccount] = key
        query[kSecValueData] = value
        query[kSecAttrAccessible] = accessOption.value

        let status = SecItemAdd(query as CFDictionary, nil)

        if status != noErr {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    /// Removes an item in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - key: The key of the item to remove.
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    public func remove(forKey key: String) throws {
        var query = getBaseQuery()
        query[kSecAttrAccount] = key

        try remove(withQuery: query)
    }

    /// Removes all  items in the keychain with this instance's service, access group and synchronizable setting.
    ///
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    public func clear() throws {
        var query = getBaseQuery()
        query[kSecMatchLimit] = kSecMatchLimitAll
        
        try remove(withQuery: query)
    }
}

private extension Keychain {

    func getBaseQuery() -> [CFString: Any] {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword
        ]
        
        if let accessGroup {
            query[kSecAttrAccessGroup] = accessGroup
        }

        if let service {
            query[kSecAttrService] = service
        }

        if synchronizable {
            query[kSecAttrSynchronizable] = true
        }

        return query
    }

    func remove(withQuery query: [CFString: Any]) throws {
        let status = SecItemDelete(query as CFDictionary)

        if status != noErr && status != errSecItemNotFound {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
