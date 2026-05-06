import Foundation
import Security

public enum KeychainAccessOption: Sendable {

    // Default option for keychain items added without explicitly setting the access option.
    public static let defaultValue = KeychainAccessOption.accessibleWhenUnlocked

    /// Wrapper for: kSecAttrAccessibleWhenUnlocked
    ///
    /// Item data can only be accessed while the device is unlocked.
    /// This is recommended for items that only need be accesible while
    /// the application is in the foreground. Items with this attribute
    /// will migrate to a new device when using encrypted backups.
    ///
    /// This is the default option for keychain items added without explicitly setting the access option.
    case accessibleWhenUnlocked

    /// Wrapper for: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ///
    /// Item data can only be accessed while the device is unlocked.
    /// This is recommended for items that only need be accesible while
    /// the application is in the foreground. Items with this attribute
    /// will never migrate to a new device, so after a backup is restored
    /// to a new device, these items will be missing.
    case accessibleWhenUnlockedThisDeviceOnly

    /// Wrapper for: kSecAttrAccessibleAfterFirstUnlock
    ///
    /// Item data can only be accessed once the device has been
    /// unlocked after a restart. This is recommended for items that need
    /// to be accesible by background applications. Items with this
    /// attribute will migrate to a new device when using encrypted backups.
    case accessibleAfterFirstUnlock

    /// Wrapper for: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ///
    /// Item data can only be accessed once the device has been
    /// unlocked after a restart. This is recommended for items that need
    /// to be accessible by background applications. Items with this
    /// attribute will never migrate to a new device, so after a backup is
    /// restored to a new device these items will be missing.
    case accessibleAfterFirstUnlockThisDeviceOnly

    /// Wrapper for: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
    ///
    /// Item data can only be accessed while the device is unlocked.
    /// This is recommended for items that only need to be accessible
    /// while the application is in the foreground and requires a
    /// passcode to be set on the device. Items with this attribute
    /// will never migrate to a new device, so after a backup is
    /// restored to a new device, these items will be missing. This
    /// attribute will not be available on devices without a passcode.
    /// Disabling the device passcode will cause all previously protected
    /// items to be deleted.
    case accessibleWhenPasscodeSetThisDeviceOnly
}

extension KeychainAccessOption {

    var value: CFString {
        switch self {
        case .accessibleWhenUnlocked: kSecAttrAccessibleWhenUnlocked
        case .accessibleWhenUnlockedThisDeviceOnly: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .accessibleAfterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock
        case .accessibleAfterFirstUnlockThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .accessibleWhenPasscodeSetThisDeviceOnly: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
