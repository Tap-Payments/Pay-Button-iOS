// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pay-Button-iOS",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Pay-Button-iOS",
            targets: ["Pay-Button-iOS"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/TakeScoop/SwiftyRSA.git", from: "1.0.0"),
        .package(url: "https://github.com/Tap-Payments/SharedDataModels-iOS.git", from: "0.0.1"),
        .package(url: "https://github.com/ahmdx/Robin", from: "0.98.0"),
        .package(url: "https://github.com/Tap-Payments/TapFontKit-iOS.git", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Pay-Button-iOS",
            dependencies: ["SwiftyRSA",
                           "Robin",
                           "TapFontKit-iOS",
                          "SharedDataModels-iOS"],
            resources: [.copy("Resources/BenefitLoader.gif"),
                        .process("Resources/PayButtonMedia.xcassets")]
        ),
        .testTarget(
            name: "Pay-Button-iOSTests",
            dependencies: ["Pay-Button-iOS"]),
    ],
    swiftLanguageVersions: [.v5]
)
