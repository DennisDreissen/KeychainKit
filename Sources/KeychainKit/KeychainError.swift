//
//  KeychainError.swift
//  KeychainKit
//
//  Created by Dennis Dreissen on 15/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation

public enum KeychainError: Error, Sendable, Equatable {

    /// No item exists for the given key.
    case itemNotFound

    /// The keychain result data is invalid.
    case unexpectedResultType

    /// Data cannot be decoded as a UTF-8 string.
    case stringConversionFailed

    /// The keychain query failed.
    case unexpectedStatus(OSStatus)
}
