import Foundation

public protocol KeychainProtocol {

    /// Service associated with this keychain to scope items.
    var service: String? { get }

    /// Access group used to access and store items. Useful to share keychain items between applications from the same team.
    var accessGroup: String? { get }

    /// Indicates whether the items synchronize through iCloud with other devices.
    var synchronizable: Bool { get }

    /// Get all keys from the keychain with this instance's service, access group and synchronizable setting.
    func keys() -> [String]

    /// Retrieves a string value from the keychain for the given key.
    ///
    /// - Parameters:
    ///   - key: The key used to store the string.
    /// - Returns: The stored string.
    /// - Throws: `KeychainError.itemNotFound` if no item exists for the given key.
    /// - Throws: `KeychainError.stringConversionFailed` if the data cannot be decoded as UTF-8.
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    func string(forKey key: String) throws -> String

    /// Retrieves a data value from the keychain for the given key.
    ///
    /// - Parameters:
    ///   - key: The key used to store the data.
    /// - Returns: The stored data.
    /// - Throws: `KeychainError.itemNotFound` if no item exists for the given key.
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    func data(forKey key: String) throws -> Data

    /// Stores a string value in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - value: The string to store in the keychain.
    ///   - key: The key to associate with the stored value.
    ///   - accessOption: Controls when the item can be accessed. Defaults to `.accessibleWhenUnlocked`.
    /// - Throws: `KeychainError.stringConversionFailed` if the string cannot be encoded as UTF-8.
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    func set(_ value: String, forKey key: String, withAccessOption accessOption: KeychainAccessOption) throws

    /// Stores a data value in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - value: The data to store in the keychain.
    ///   - key: The key to associate with the stored value.
    ///   - accessOption: Controls when the item can be accessed. Defaults to `.accessibleWhenUnlocked`.
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    func set(_ value: Data, forKey key: String, withAccessOption accessOption: KeychainAccessOption) throws

    /// Removes an item in the keychain for the given key.
    ///
    /// - Parameters:
    ///   - key: The key of the item to remove.
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
    func remove(forKey key: String) throws

    /// Removes all  items in the keychain with this instance's service, access group and synchronizable setting.
    ///
    /// - Throws: `KeychainError.unexpectedStatus` if the keychain query fails.
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
