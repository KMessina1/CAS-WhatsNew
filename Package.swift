// swift-tools-version: 6.2
/*-------------------------------------------------------------------------------------------------------------------------
     File: Package.swift
   Author: Kevin Messina
  Created: 8/22/26
 Modified: 08/23/2026 03:50 PM EDT
  Version: 2
   Source: CODEX: (GPT-5) 🤖AI Code a portion or all of this code.
 
©2026 Creative App Solutions, LLC. - All Rights Reserved.
--------------------------------------------------------------------------------------------------------------------------
NOTES:
-------------------------------------------------------------------------------------------------------------------------*/

import PackageDescription

let package = Package(
    name: "CAS-WhatsNew",
    platforms: [
        .iOS(.v26),
        .macCatalyst(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "CASWhatsNew",
            targets: ["CASWhatsNew"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/KMessina1/CAS-External-Foundations.git",
            from: "1.1.5"
        ),
        .package(
            url: "https://github.com/KMessina1/CAS-External-Basics.git",
            from: "1.1.1"
        ),
        .package(
            url: "https://github.com/KMessina1/CAS-ThemeSupport.git",
            from: "1.1.1"
        ),
        .package(
            url: "https://github.com/groue/GRDB.swift.git",
            from: "6.29.3"
        )
    ],
    targets: [
        .target(
            name: "CASWhatsNew",
            dependencies: [
                .product(
                    name: "CASExternalFoundations",
                    package: "CAS-External-Foundations"
                ),
                .product(
                    name: "CASExternalBasics",
                    package: "CAS-External-Basics"
                ),
                .product(
                    name: "CASThemeSupport",
                    package: "CAS-ThemeSupport"
                ),
                .product(
                    name: "GRDB",
                    package: "GRDB.swift"
                )
            ],
            resources: [
                .process("Resources/WhatsNew.xcassets")
            ]
        ),
        .testTarget(
            name: "CASWhatsNewTests",
            dependencies: ["CASWhatsNew"]
        )
    ],
    swiftLanguageModes: [.v5]
)
