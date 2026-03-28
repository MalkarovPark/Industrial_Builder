//
//  AppPackagePattern.swift
//  Industrial Builder
//
//  Created by Artem on 27.03.2026.
//

import Foundation

public func app_package_pattern(
    name: String,
    data: String
) -> FilePattern
{
    let listing_name = name.code_correct_format
    return
        .init(
            name: "\(listing_name)_Project",
            children: [
                Package_file_pattern(name: listing_name),
                .init(
                    name: "Sources",
                    children: [
                        .init(
                            name: name,
                            children: [
                                .init(
                                    name: "main.swift",
                                    data: data
                                )
                            ]
                        )
                    ]
                )
            ]
        )
}

private func Package_file_pattern(
    name: String
) -> FilePattern
{
    .init(
        name: "Package.swift",
        data:
"""

// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "\(name)",
    platforms: [
        .iOS("26.0"),
        .macOS("26.0"),
        .visionOS("26.0")
    ],
    dependencies: [
        .package(url: "https://github.com/MalkarovPark/IndustrialKit", branch: "development"),
        //.package(url: "https://github.com/MalkarovPark/IndustrialKit", "5.0.0"..<"6.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "\(name)",
            dependencies: [
                .product(name: "IndustrialKit", package: "IndustrialKit"),
            ],
            path: "Sources"
        ),
    ]
)
"""
    )
}
