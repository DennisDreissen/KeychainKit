// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "KeychainKit",
    products: [
        .library(
            name: "KeychainKit",
            targets: ["KeychainKit"]
        ),
    ],
    targets: [
        .target(
            name: "KeychainKit"
        ),
        .testTarget(
            name: "KeychainKitTests",
            dependencies: ["KeychainKit"],
            path: "Tests/KeychainKitTests",
            linkerSettings: [
                .linkedFramework("Security")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
