// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UniversityHubKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "UniversityHubKit",
            targets: ["UniversityHubKit"]
        ),
        .library(
            name: "GroupPickerFeature",
            targets: ["GroupPickerFeature"]
        ),
        .library(
            name: "RozkladKit",
            targets: ["RozkladKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "observation-beta"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "10.19.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", exact: "4.2.2"),
        .package(url: "https://github.com/ddanilyuk/KPIHubServer", branch: "master"),
    ],
    targets: [
        .target(
            name: "UniversityHubKit",
            dependencies: [
                "Services",
                "SharedViews",
                "Extensions",
                "RozkladKit",
                "GroupPickerFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),
        .target(
            name: "GroupPickerFeature",
            dependencies: [
                "Services",
                "SharedViews",
//                "Extensions",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),
        .target(
            name: "RozkladKit",
            dependencies: [
                "Services",
                "SharedViews",
                "Extensions",
                "GroupPickerFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),
        .target(
            name: "SharedViews",
            dependencies: [
                "Extensions",
            ]
        ),
        .target(
            name: "Services",
            dependencies: [
                "Extensions",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),
        .target(
            name: "Extensions",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "UniversityHubKitTests",
            dependencies: ["UniversityHubKit"]
        ),
    ]
)
