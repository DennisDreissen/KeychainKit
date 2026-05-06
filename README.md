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
    .package(url: "https://github.com/DennisDreissen/KeychainKit", .upToNextMajor(from: "1.0.0"))
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
let allKeys = keychain.keys()
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

All methods are throwing, except for the `keys()`. The `unexpectedStatus` contains an `OSStatus` returned by Apple's Security framework.

 ```Swift
public enum KeychainError: Error, Equatable {

    /// No item exists for the given key.
    case itemNotFound

    /// Data cannot be encoded or decoded as a UTF-8 string.
    case stringConversionFailed

    /// The keychain query failed.
    case unexpectedStatus(OSStatus)
}
 ```
