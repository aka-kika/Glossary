// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Glossary",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        // Pure, fully unit-tested logic. No AppKit.
        .target(
            name: "GlossaryCore",
            resources: [
                .copy("Resources/glossary.json")
            ]
        ),
        // AppKit shell + SwiftUI views. The menu-bar overlay app.
        // Swift 5 language mode keeps AppKit/Carbon interop free of strict-concurrency noise.
        .executableTarget(
            name: "Glossary",
            dependencies: ["GlossaryCore"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "GlossaryCoreTests",
            dependencies: ["GlossaryCore"]
        ),
    ]
)
