import Testing
import Foundation
import Security
@testable import KeychainKit

@Test
func getKeys() throws {
    let sut = Keychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "key_1")
    try sut.set("value_2", forKey: "key_2")

    let result = sut.keys()

    #expect(result == ["key_1", "key_2"])
    try sut.clear()
}

@Test
func setGetData() throws {
    let sut = Keychain(service: #function)
    try sut.clear()

    let value = "value_1".data(using: .utf8)!

    try sut.set(value, forKey: "key_1")
    let result = try sut.data(forKey: "key_1")

    #expect(result == value)
    try sut.clear()
}

@Test
func setGetString() throws {
    let sut = Keychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "key_1")
    let result = try sut.string(forKey: "key_1")

    #expect(result == "value_1")
    try sut.clear()
}

@Test
func setGetDataNotFound() throws {
    let sut = Keychain(service: #function)
    try sut.clear()

    #expect(throws: KeychainError.itemNotFound) {
        try sut.data(forKey: "key_1")
    }
}

@Test
func setGetStringNotFound() throws {
    let sut = Keychain(service: #function)
    try sut.clear()

    #expect(throws: KeychainError.itemNotFound) {
        try sut.string(forKey: "key_1")
    }
}

@Test
func setGetInvalidString() throws {
    let sut = Keychain(service: #function)
    try sut.clear()

    let invalidUTF8 = Data([0xFF, 0xFE, 0x00])
    try sut.set(invalidUTF8, forKey: "key_1")

    #expect(throws: KeychainError.stringConversionFailed) {
        try sut.string(forKey: "key_1")
    }
}

@Test
func remove() throws {
    let sut = Keychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "key_1")
    try sut.set("value_2", forKey: "key_2")
    try sut.remove(forKey: "key_2")

    let result = sut.keys()

    #expect(result == ["key_1"])
    try sut.clear()
}

@Test
func clear() throws {
    let sut = Keychain(service: #function)
    try sut.clear()

    try sut.set("value_1", forKey: "key_1")
    try sut.set("value_2", forKey: "key_2")
    try sut.clear()

    let result = sut.keys()

    #expect(result == [])
}

@Test
func usesService() throws {
    let sut1 = Keychain(service: "\(#function)1")
    let sut2 = Keychain(service: "\(#function)2")
    try sut1.clear()
    try sut2.clear()

    try sut1.set("value_1", forKey: "key_1")

    #expect(throws: KeychainError.itemNotFound) {
        try sut2.string(forKey: "key_1")
    }

    try sut1.clear()
}
