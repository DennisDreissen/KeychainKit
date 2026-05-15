//
//  KeychainProtocol.swift
//  KeychainKit
//
//  Created by Dennis Dreissen on 15/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation

public protocol KeychainProtocol: Sendable {

    /// Service associated with this keychain to scope items.
    var service: String? { get }

    /// Access group used to access and store items. Useful to share keychain items between applications from the same team.
    var accessGroup: String? { get }

    /// Indicates whether the items synchronize through iCloud with other devices.
    var synchronizable: Bool { get }

    /// Get all keys from the keychain with this instance's service, access group and synchronizable setting.
    func keys() throws -> [String]

    /// Retrieves a string value from the keychain for the given key.
    ///
    /// - Parameters:
    ///   - key: The key used to store the string.
    /// - Returns: The stored string.
    func string(forKey key: String) throws -> String

    /// Retrieves a data value from the keychain for the given key.
    ///
    /// - Parameters:
    ///   - key: The key used to store the data.
    /// - Returns: The stored data.
    func data(forKey key: String) throws -> Data

    /// Stores a string value in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - value: The string to store in the keychain.
    ///   - key: The key to associate with the stored value.
    ///   - accessOption: Controls when the item can be accessed. Defaults to `.accessibleWhenUnlocked`.
    func set(_ value: String, forKey key: String, withAccessOption accessOption: KeychainAccessOption) throws

    /// Stores a data value in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - value: The data to store in the keychain.
    ///   - key: The key to associate with the stored value.
    ///   - accessOption: Controls when the item can be accessed. Defaults to `.accessibleWhenUnlocked`.
    func set(_ value: Data, forKey key: String, withAccessOption accessOption: KeychainAccessOption) throws

    /// Removes an item in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - key: The key of the item to remove.
    func remove(forKey key: String) throws

    /// Removes all items in the keychain with this instance's service, access group and synchronizable setting.
    func clear() throws
}

public extension KeychainProtocol {

    func set(_ value: String, forKey key: String) throws {
        try set(value, forKey: key, withAccessOption: .defaultValue)
    }

    func set(_ value: Data, forKey key: String) throws {
        try set(value, forKey: key, withAccessOption: .defaultValue)
    }
}
