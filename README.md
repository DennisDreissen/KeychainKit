![Tests](https://img.shields.io/github/actions/workflow/status/DennisDreissen/KeychainKit/tests.yml?color=brightgreen&label=Tests&logo=github)
![SPM](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen)
![Swift](https://img.shields.io/badge/Swift-6.0_6.1_6.2_6.3-brightgreen)

# KeychainKit for Swift

This is a simple wrapper around Apple's Keychain to make saving and retrieving data from the Keychain a bit easier.

 ```Swift
let keychain = Keychain()
try keychain.set("value_1", forKey: "key_1")
let value = try keychain.string(forKey: "key_1")
 ```
## Setup using SPM

 ```Swift
dependencies: [
    .package(url: "https://github.com/DennisDreissen/KeychainKit.git", .upToNextMajor(from: "1.0.0"))
]
 ```

## Usage

### Storing data

 ```Swift
let keychain = Keychain()
try keychain.set(String(), forKey: "key_1")
try keychain.set(Data(), forKey: "key_2")
 ```

#### Using an access level other than the default `KeychainAccessOption.accessibleWhenUnlocked`
 ```Swift
let keychain = Keychain()
try keychain.set(
    "value_1",
    forKey: "key_1",
    withAccessOption: .accessibleAfterFirstUnlock
)
 ```

### Getting data

 ```Swift
let keychain = Keychain()
let stringValue = try keychain.string(forKey: "key_1")
let dataValue = try keychain.data(forKey: "key_2")
 ```

### Getting all stored keys

 ```Swift
let keychain = Keychain()
let allKeys = try keychain.keys()
 ```

### Removing data

 ```Swift
let keychain = Keychain()
try keychain.remove(forKey: "key_1")
 ```

### Removing all data

 ```Swift
let keychain = Keychain()
try keychain.clear()
 ```

### Initializer options

 | Parameter | Type | Default | Description |
|---|---|---|---|
| `service` | `String?` | `nil` | Scopes keychain items to a specific service. |
| `accessGroup` | `String?` | `nil` | Restricts access to apps sharing the same access group. |
| `synchronizable` | `Bool` | `false` | Allow keychain items to synchronize across devices via iCloud. |

 ```Swift
let keychain = Keychain(
    service: String? = nil,
    accessGroup: String? = nil,
    synchronizable: Bool = false
)
 ```

# Errors

All methods are throwing. The `unexpectedStatus` contains an `OSStatus` returned by Apple's Security framework.

 ```Swift
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
 ```
