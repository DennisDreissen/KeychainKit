// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KeychainKit",
    platforms: [
        .iOS(.v15), .macOS(.v12)
    ],
    products: [
        .library(
            name: "KeychainKit",
            targets: ["KeychainKit"]
        )
    ],
    targets: [
        .target(
            name: "KeychainKit"
        )
    ],
    swiftLanguageModes: [.v6]
)
