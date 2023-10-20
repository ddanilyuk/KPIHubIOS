// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KPIHubKit",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RozkladServiceLessons",
            targets: ["RozkladServiceLessons"]
        ),
        .library(
            name: "GeneralServices",
            targets: ["GeneralServices"]
        ),
        .library(
            name: "Common",
            targets: ["Common"]
        ),
        .library(
            name: "ForDevelopersFeature",
            targets: ["ForDevelopersFeature"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.16.0"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Theme",
            resources: [.process("Resources")],
            swiftSettings: [.define("ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS")]
        ),
        .target(
            name: "ForDevelopersFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "AnalyticsService",
                "Theme",
                "Common"
            ],
            resources: [
                .process("Media.xcassets"),
//                .process("Media.xcassets")
            ],
            packageAccess: true,
            swiftSettings: [
                .define("ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS"),
                .define("ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS")
            ]
        ),
        .target(
            name: "AnalyticsService",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
//                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
                "Common"
            ]
        ),
        .target(
            name: "RozkladServiceLessons",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common",
                "GeneralServices"
            ]
        ),
        .target(
            name: "GeneralServices",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                "Common"
            ]
        ),
        .target(
            name: "Common",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        )
//        .testTarget(
//            name: "KPIHubKitTests",
//            dependencies: ["KPIHubKit"]
//        )
    ]
)
