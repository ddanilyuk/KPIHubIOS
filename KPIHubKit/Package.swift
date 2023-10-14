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
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    ],
    targets: [
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
            name: "Common"
        )
//        .testTarget(
//            name: "KPIHubKitTests",
//            dependencies: ["KPIHubKit"]
//        )
    ]
)
