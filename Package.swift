// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "OSSSpeechKit",
    platforms: [
        .iOS(.v12),
        .tvOS(.v13),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "OSSSpeechKit",
            targets: ["OSSSpeechKit"]),
        .library(
            name: "OSSSpeechKit-Static",
            type: .static,
            targets: ["OSSSpeechKit"]),
        .library(
            name: "OSSSpeechKit-Dynamic",
            type: .dynamic,
            targets: ["OSSSpeechKit"])
    ],

    dependencies: [
    ],

    // MARK: - Targets
    targets: [
        // // MARK: - OSSSpeachKit
        .target(
            name: "OSSSpeechKit",
            path: "OSSSpeechKit/",
            sources: [
                "Classes/OSSSpeech.swift",
                "Classes/OSSSpeechUtility.swift",
                "Classes/OSSUtterance.swift",
                "Classes/OSSVoice.swift"
            ],
            resources: [
                .process("Assets/")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("Speech")
            ]
        ),
		
    .testTarget(
        name: "OSSSpeechKitTests",
        dependencies: [
            "OSSSpeechKit"
        ],
        path: "Example/Tests",
        exclude: [
            "Info.plist"
        ],
        linkerSettings: [
            .linkedFramework("AVKit")
        ]
    )],
    swiftLanguageVersions: [.v5]
)
