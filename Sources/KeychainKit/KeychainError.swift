import Foundation

public enum KeychainError: Error, Equatable {

    /// No item exists for the given key.
    case itemNotFound

    /// Data cannot be encoded or decoded as a UTF-8 string.
    case stringConversionFailed

    /// The keychain query failed.
    case unexpectedStatus(OSStatus)
}
