// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "ColorPaletteCodable",
	platforms: [
		.macOS(.v10_13),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v4)
	],
	products: [
		.library(
			name: "ColorPaletteCodable",
			type: .static,
			targets: ["ColorPaletteCodable"]
		),
		.library(
			name: "ColorPaletteCodableDynamic",
			type: .dynamic,
			targets: ["ColorPaletteCodable"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFRegex", from: "2.0.0")
	],
	targets: [
		.target(
			name: "ColorPaletteCodable",
			dependencies: [.product(name: "DSFRegexStatic", package: "DSFRegex")]
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
