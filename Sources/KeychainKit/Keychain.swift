//
//  Keychain.swift
//  KeychainKit
//
//  Created by Dennis Dreissen on 15/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

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
    public func keys() throws -> [String] {
        var query = getBaseQuery()
        query[kSecReturnAttributes] = true
        query[kSecMatchLimit] = kSecMatchLimitAll

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else {
            return []
        }

        guard status == noErr else {
            throw KeychainError.unexpectedStatus(status)
        }

        guard let items = result as? [[CFString: Any]] else {
            throw KeychainError.unexpectedResultType
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
            throw KeychainError.unexpectedResultType
        }

        return data
    }

    /// Stores a string value in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - value: The string to store in the keychain.
    ///   - key: The key to associate with the stored value.
    ///   - accessOption: Controls when the item can be accessed. Defaults to `.accessibleWhenUnlocked`.
    public func set(
        _ value: String,
        forKey key: String,
        withAccessOption accessOption: KeychainAccessOption = .defaultValue
    ) throws {
        try set(Data(value.utf8), forKey: key, withAccessOption: accessOption)
    }

    /// Stores a data value in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - value: The data to store in the keychain.
    ///   - key: The key to associate with the stored value.
    ///   - accessOption: Controls when the item can be accessed. Defaults to `.accessibleWhenUnlocked`.
    public func set(
        _ value: Data,
        forKey key: String,
        withAccessOption accessOption: KeychainAccessOption = .defaultValue
    ) throws {
        var query = getBaseQuery()
        query[kSecAttrAccount] = key

        let attributes: [CFString: Any] = [
            kSecValueData: value,
            kSecAttrAccessible: accessOption.value,
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        switch status {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            query[kSecValueData] = value
            query[kSecAttrAccessible] = accessOption.value

            let status = SecItemAdd(query as CFDictionary, nil)

            if status != errSecSuccess {
                throw KeychainError.unexpectedStatus(status)
            }
        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    /// Removes an item in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - key: The key of the item to remove.
    public func remove(forKey key: String) throws {
        var query = getBaseQuery()
        query[kSecAttrAccount] = key

        try remove(withQuery: query)
    }

    /// Removes all items in the keychain with this instance's service, access group and synchronizable setting.
    public func clear() throws {
        try remove(withQuery: getBaseQuery())
    }
}

private extension Keychain {

    func getBaseQuery() -> [CFString: Any] {
        var query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecUseDataProtectionKeychain: true
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
