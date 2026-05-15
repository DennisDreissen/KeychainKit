//
//  KeychainKitTests.swift
//  KeychainKit
//
//  Created by Dennis Dreissen on 15/05/2026.
//  Copyright © 2026 Dennis Dreissen
//

import Foundation
import Testing
import KeychainKit

@Test
func getKeys() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "key_1")
    try sut.set("value_2", forKey: "key_2")

    let result = try sut.keys()

    #expect(result.contains("key_1"))
    #expect(result.contains("key_2"))

    try sut.clear()
}

@Test
func setData() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    let value = "value_1".data(using: .utf8)!

    try sut.set(value, forKey: "key_1")
    let result = try sut.data(forKey: "key_1")

    #expect(result == value)

    try sut.clear()
}

@Test
func setOverwritesExistingValue() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "key_1")
    try sut.set("value_2", forKey: "key_1")

    #expect(try sut.string(forKey: "key_1") == "value_2")

    try sut.clear()
}

@Test
func setOverwritesExistingValueAccessOption() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "key_1", withAccessOption: .accessibleWhenUnlocked)
    try sut.set("value_1", forKey: "key_1", withAccessOption: .accessibleAfterFirstUnlock)

    let query: [CFString: Any] = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrService: #function,
        kSecAttrAccount: "key_1",
        kSecReturnAttributes: true,
        kSecMatchLimit: kSecMatchLimitOne,
        kSecUseDataProtectionKeychain: true,
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    let attributes = result as? [CFString: Any]
    let accessOption = attributes?[kSecAttrAccessible] as? String

    #expect(status == errSecSuccess)
    #expect(accessOption == kSecAttrAccessibleAfterFirstUnlock as String)

    try sut.clear()
}

@Test(arguments: KeychainAccessOption.allCases)
func setDataWithAccessOption(option: KeychainAccessOption) throws {
    let service = "setDataWithAccessOption-\(option)"
    let sut = createKeychain(service: service)
    try sut.clear()

    let value = Data("value_1".utf8)
    try sut.set(value, forKey: "key_1", withAccessOption: option)

    let query: [CFString: Any] = [
        kSecClass: kSecClassGenericPassword,
        kSecAttrService: service,
        kSecAttrAccount: "key_1",
        kSecReturnAttributes: true,
        kSecMatchLimit: kSecMatchLimitOne,
        kSecUseDataProtectionKeychain: true,
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    let attributes = result as? [CFString: Any]
    let accessOption = attributes?[kSecAttrAccessible] as? String

    #expect(status == errSecSuccess)
    #expect(accessOption == option.value as String)

    try sut.clear()
}

@Test
func setString() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "key_1")
    let result = try sut.string(forKey: "key_1")

    #expect(result == "value_1")

    try sut.clear()
}

@Test
func setInvalidString() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    let invalidUTF8 = Data([0xFF, 0xFE, 0x00])
    try sut.set(invalidUTF8, forKey: "key_1")

    #expect(throws: KeychainError.stringConversionFailed) {
        try sut.string(forKey: "key_1")
    }

    try sut.clear()
}

@Test
func setEmptyKey() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "")
    let result = try sut.string(forKey: "")

    #expect(result == "value_1")

    try sut.clear()
}

@Test
func getDataNotFound() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    #expect(throws: KeychainError.itemNotFound) {
        try sut.data(forKey: "key_1")
    }
}

@Test
func getStringNotFound() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    #expect(throws: KeychainError.itemNotFound) {
        try sut.string(forKey: "key_1")
    }
}

@Test
func remove() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "key_1")
    try sut.set("value_2", forKey: "key_2")
    try sut.remove(forKey: "key_2")

    let result = try sut.keys()

    #expect(result.contains("key_1"))

    try sut.clear()
}

@Test
func removeNonExistingKey() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    try sut.remove(forKey: "key_1")
}

@Test
func clear() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "key_1")
    try sut.set("value_2", forKey: "key_2")
    try sut.clear()

    let result = try sut.keys()

    #expect(result == [])
}

@Test
func clearEmptyKeychain() throws {
    let sut = createKeychain(service: #function)
    try sut.clear()
}

@Test
func usesService() throws {
    let sut1 = createKeychain(service: "\(#function)1")
    let sut2 = createKeychain(service: "\(#function)2")
    try sut1.clear()
    try sut2.clear()

    try sut1.set("value_1", forKey: "key_1")

    #expect(throws: KeychainError.itemNotFound) {
        try sut2.string(forKey: "key_1")
    }

    try sut1.clear()
}

@Test
func usesSynchronizable() throws {
    let sut1 = createKeychain(service: #function, synchronizable: true)
    let sut2 = createKeychain(service: #function, synchronizable: false)
    try sut1.clear()
    try sut2.clear()

    try sut1.set("value_1", forKey: "key_1")

    #expect(throws: KeychainError.itemNotFound) {
        try sut2.string(forKey: "key_1")
    }

    try sut1.clear()
}

func createKeychain(
    service: String? = nil,
    accessGroup: String? = nil,
    synchronizable: Bool = false
) -> KeychainProtocol {
    Keychain(service: service, accessGroup: accessGroup, synchronizable: synchronizable)
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
