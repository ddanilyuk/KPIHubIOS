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
            name: "GeneralServices",
            targets: ["GeneralServices"]
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
        .library(
            name: "CampusLoginFeature",
            targets: ["CampusLoginFeature"]
        ),
        .library(
            name: "CampusServices",
            targets: ["CampusServices"]
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
                "GeneralServices",
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
                "GeneralServices",
                "DesignKit",
                "RozkladServices",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "CampusFeature",
            dependencies: [
                "GeneralServices",
                "DesignKit",
                "Extensions",
                "CampusServices",
                "CampusModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),
        .target(
            name: "CampusLoginFeature",
            dependencies: [
                "GeneralServices",
                "DesignKit",
                "RozkladServices",
                "RozkladModels",
                "CampusModels",
                "CampusServices",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "RozkladFeature",
            dependencies: [
                "GeneralServices",
                "DesignKit",
                "RozkladModels",
                "RozkladServices",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "RozkladServices",
            dependencies: [
                "GeneralServices",
                "RozkladModels",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),

        .target(
            name: "ProfileHomeFeature",
            dependencies: [
                "GeneralServices",
                "DesignKit",
                "RozkladModels", // TODO: Remove i think
                "CampusModels", // TODO: Remove i think
                "RozkladServices",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//                .product(name: "Routes", package: "KPIHubServer"),
            ]
        ),
        .target(
            name: "LessonDetailsFeature",
            dependencies: [
                "GeneralServices",
                "DesignKit",
                "EditLessonNamesFeature",
                "EditLessonTeachersFeature",
                "RozkladModels",
                "RozkladServices",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "EditLessonNamesFeature",
            dependencies: [
                "GeneralServices",
                "DesignKit",
                "RozkladModels",
                "RozkladServices",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "EditLessonTeachersFeature",
            dependencies: [
                "GeneralServices",
                "DesignKit",
                "RozkladModels",
                "RozkladServices",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "CampusModels",
            dependencies: [
                "GeneralServices",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "CampusServices",
            dependencies: [
                "GeneralServices",
                "DesignKit",
                "CampusModels",
                .product(name: "Routes", package: "KPIHubServer"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "RozkladModels",
            dependencies: [
                "GeneralServices", // TODO: Used only because of legacy Lesson
            ]
        ),
        .target(
            name: "RozkladKit",
            dependencies: [
                "GeneralServices",
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
            name: "GeneralServices",
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
            name: "EditLessonNamesFeatureTests",
            dependencies: [
                "EditLessonNamesFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"), // TODO: ?
            ]
        ),
        .testTarget(
            name: "UniversityHubKitTests",
            dependencies: ["UniversityHubKit"]
        ),
    ]
)
