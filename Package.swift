// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "ColorPaletteCodable",
	platforms: [
		.macOS(.v10_13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6)
	],
	products: [
		.library(name: "ColorPaletteCodable", targets: ["ColorPaletteCodable"]),
		.library(name: "ColorPaletteCodable-static", type: .static, targets: ["ColorPaletteCodable"]),
		.library(name: "ColorPaletteCodable-shared", type: .dynamic, targets: ["ColorPaletteCodable"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFRegex", from: "3.1.0"),
		.package(url: "https://github.com/dagronf/SwiftImageReadWrite", from: "1.3.0")
	],
	targets: [
		.target(
			name: "ColorPaletteCodable",
			dependencies: [
				.product(name: "DSFRegex", package: "DSFRegex"),
				.product(name: "SwiftImageReadWrite", package: "SwiftImageReadWrite")
			]
		),
		.testTarget(
			name: "ColorPaletteCodableTests",
			dependencies: ["ColorPaletteCodable"],
			resources: [
				.process("resources"),
			]
		),
	]
)
