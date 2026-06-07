// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ThemeKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ThemeKit",        targets: ["ThemeKit"]),
        .library(name: "ThemeKitSwiftUI", targets: ["ThemeKitSwiftUI"]),
        .library(name: "ThemeKitUIKit",   targets: ["ThemeKitUIKit"]),
    ],
    targets: [
        .target(name: "ThemeKit"),
        .target(name: "ThemeKitSwiftUI", dependencies: ["ThemeKit"]),
        .target(name: "ThemeKitUIKit",   dependencies: ["ThemeKit"]),
        .testTarget(name: "ThemeKitTests",        dependencies: ["ThemeKit"]),
        .testTarget(name: "ThemeKitSwiftUITests",  dependencies: ["ThemeKitSwiftUI", "ThemeKit"]),
        .testTarget(name: "ThemeKitUIKitTests",    dependencies: ["ThemeKitUIKit", "ThemeKit"]),
    ],
    swiftLanguageModes: [.v6]
)
