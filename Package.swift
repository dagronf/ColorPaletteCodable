// swift-tools-version: 5.6

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
		.package(url: "https://github.com/dagronf/DSFRegex", from: "3.4.0"),
		.package(url: "https://github.com/dagronf/SwiftImageReadWrite", from: "1.7.1"),
		.package(url: "https://github.com/dagronf/TinyCSV", from: "1.0.0"),
		.package(url: "https://github.com/dagronf/BytesParser", from: "3.1.1"),
	],
	targets: [
		.target(
			name: "ColorPaletteCodable",
			dependencies: [ 
				"DSFRegex",
				"SwiftImageReadWrite", 
				"TinyCSV",
				"BytesParser",
			],
			resources: [
				.copy("PrivacyInfo.xcprivacy"),
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
