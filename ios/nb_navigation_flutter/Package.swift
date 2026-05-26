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
            from: "2.1.5"
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
            url: "https://github.com/nextbillion-ai/nextbillion-navigation-ios/releases/download/3.3.1/NbmapNavigation.xcframework.zip",
            checksum: "bd8a260c519b5f515c05307c538444d7817a269cda723417fc0fadd88f322d24"
        ),
        .binaryTarget(
            name: "NbmapCoreNavigation",
            url: "https://github.com/nextbillion-ai/nextbillion-navigation-ios/releases/download/3.3.1/NbmapCoreNavigation.xcframework.zip",
            checksum: "7e7574dff11500a7884a6bc513716806e710c4eac08ff7c7e5e2c2d10baee3da"
        ),
        .binaryTarget(
            name: "Turf",
            url: "https://github.com/nextbillion-ai/nextbillion-turf-ios/releases/download/3.0.1/Turf.xcframework.zip",
            checksum: "8f0108b812a17892bd650cf58e5fb1e842e2678f94e8f080e65ec5c9659a8b64"
        )
    ]
)
