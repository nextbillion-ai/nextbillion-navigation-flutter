// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nb_navigation_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "nb-navigation-flutter", targets: ["nb_navigation_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/nextbillion-ai/maps-native-distribution",
            exact: "2.3.3"
        )
    ],
    targets: [
        .target(
            name: "nb_navigation_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Nbmap", package: "maps-native-distribution"),
                "NbmapNavigation",
                "NbmapCoreNavigation",
                "Turf"
            ]
        ),
        .binaryTarget(
            name: "NbmapNavigation",
            url: "https://github.com/nextbillion-ai/nextbillion-navigation-ios/releases/download/4.1.4/NbmapNavigation.xcframework.zip",
            checksum: "32745d9047ad4e36ad96f4c5abeb7055cff6e747f7efc3ab227b049d1c927cfe"
        ),
        .binaryTarget(
            name: "NbmapCoreNavigation",
            url: "https://github.com/nextbillion-ai/nextbillion-navigation-ios/releases/download/4.1.4/NbmapCoreNavigation.xcframework.zip",
            checksum: "87aafa6efd446b15dccc56214125a1e626a55465e2e3f865ea3e5839c48327a9"
        ),
        .binaryTarget(
            name: "Turf",
            url: "https://github.com/nextbillion-ai/nextbillion-turf-ios/releases/download/3.0.1/Turf.xcframework.zip",
            checksum: "8f0108b812a17892bd650cf58e5fb1e842e2678f94e8f080e65ec5c9659a8b64"
        )
    ]
)
