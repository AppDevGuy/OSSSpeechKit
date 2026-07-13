// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OSSSpeechKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "OSSSpeechKit",
            targets: ["OSSSpeechKit"]
        )
    ],
    targets: [
        .target(
            name: "OSSSpeechKit",
            path: "OSSSpeechKit",
            sources: ["Classes"],
            resources: [
                .process("Assets"),
                .copy("PrivacyInfo.xcprivacy")
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("Speech"),
                .linkedFramework("UIKit")
            ]
        ),
        .testTarget(
            name: "OSSSpeechKitTests",
            dependencies: ["OSSSpeechKit"],
            path: "Example/Tests",
            exclude: ["Info.plist", "RecordingSessionModelTests.swift"],
            resources: [
                .process("LocalizableTests.strings")
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("Speech"),
                .linkedFramework("UIKit")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
