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
        ),
        .library(
            name: "RozkladFeature",
            targets: ["RozkladFeature"]
        ),
        .library(
            name: "CampusFeature",
            targets: ["CampusFeature"]
        ),
        .library(
            name: "LessonDetailsFeature",
            targets: ["LessonDetailsFeature"]
        ),
        .library(
            name: "ProfileHomeFeature",
            targets: ["ProfileHomeFeature"]
        ),
        .library(
            name: "DesignKit",
            targets: ["DesignKit"]
        ),
        .library(
            name: "RozkladServices",
            targets: ["RozkladServices"]
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
            name: "UniversityHubKit",
            dependencies: [
                "Services",
                "DesignKit",
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
                "DesignKit",
                "RozkladServices",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "CampusFeature",
            dependencies: [
                "Services",
                "DesignKit",
                "Extensions",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),
        .target(
            name: "RozkladFeature",
            dependencies: [
                "Services",
                "DesignKit",
                "RozkladModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),
        .target(
            name: "RozkladServices",
            dependencies: [
                "Services",
                "RozkladModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),

        .target(
            name: "ProfileHomeFeature",
            dependencies: [
                "Services",
                "DesignKit",
                "RozkladModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),
        .target(
            name: "LessonDetailsFeature",
            dependencies: [
                "Services",
                "DesignKit",
                "RozkladModels",
                "RozkladServices",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "EditLessonNamesFeature",
            dependencies: [
                "Services",
                "DesignKit",
                "RozkladModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "EditLessonTeachersFeature",
            dependencies: [
                "Services",
                "DesignKit",
                "RozkladModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "RozkladModels",
            dependencies: [
                "Services", // TODO: Used only because of legacy Lesson
            ]
        ),
        .target(
            name: "RozkladKit",
            dependencies: [
                "Services",
                "DesignKit",
                "Extensions",
                "GroupPickerFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),
        .target(
            name: "DesignKit",
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
