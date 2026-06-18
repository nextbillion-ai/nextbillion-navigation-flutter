// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nb_navigation_flutter",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "nb-navigation-flutter", targets: ["nb_navigation_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/nextbillion-ai/maps-native-distribution",
            from: "2.1.6"
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
            url: "https://github.com/nextbillion-ai/nextbillion-navigation-ios/releases/download/3.4.0/NbmapNavigation.xcframework.zip",
            checksum: "711b9ad67621c7ca2eda5e655bf0922b73baab6a2193cfb95b2d96792929be0e"
        ),
        .binaryTarget(
            name: "NbmapCoreNavigation",
            url: "https://github.com/nextbillion-ai/nextbillion-navigation-ios/releases/download/3.4.0/NbmapCoreNavigation.xcframework.zip",
            checksum: "79e267ee5f75781b2e5a3738c98d1ec25583cba590323b80643e340213746039"
        ),
        .binaryTarget(
            name: "Turf",
            url: "https://github.com/nextbillion-ai/nextbillion-turf-ios/releases/download/3.0.1/Turf.xcframework.zip",
            checksum: "8f0108b812a17892bd650cf58e5fb1e842e2678f94e8f080e65ec5c9659a8b64"
        )
    ]
)
