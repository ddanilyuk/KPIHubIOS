// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KPIHubKit",
    platforms: [
      .iOS(.v16),
    ],
    products: [
        .library(
            name: "Common",
            targets: ["Common"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.2.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.16.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
        .package(url: "https://github.com/ddanilyuk/KPIHubServer", branch: "master"),
    ],
    targets: [
         .target(
             name: "Common",
             dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//                .product(name: "Firebase", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
                .product(name: "Routes", package: "KPIHubServer"),
             ]
         ),
         .testTarget(
             name: "KPIHubKitTests",
             dependencies: ["Common"]
         ),
    ]
)
