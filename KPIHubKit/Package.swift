// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KPIHubKit",
    platforms: [
      .iOS(.v17),
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]
        ),
        .library(
            name: "Services",
            targets: ["Services"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "observation-beta"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "10.19.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", exact: "4.2.2"),
        .package(url: "https://github.com/ddanilyuk/KPIHubServer", branch: "master"),
    ],
    targets: [
         .target(
             name: "Common",
             dependencies: [
                "Services",
                "Extensions",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "Routes", package: "KPIHubServer"),
             ],
             resources: [
                .copy("Configs")
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
             name: "KPIHubKitTests",
             dependencies: ["Common"]
         ),
    ]
)
