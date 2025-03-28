// swift-tools-version: 5.6

import PackageDescription

let packageDeps: [Package.Dependency] = {
	var d: [Package.Dependency] = [
		.package(url: "https://github.com/dagronf/DSFRegex", from: "3.4.0"),
		.package(url: "https://github.com/dagronf/SwiftImageReadWrite", from: "1.7.1"),
		.package(url: "https://github.com/dagronf/TinyCSV", from: "1.0.0"),
		.package(url: "https://github.com/dagronf/BytesParser", from: "3.1.1"),
	]
#if !os(Linux)
	d.append(.package(url: "https://github.com/weichsel/ZIPFoundation", from: "0.9.19"))
#endif
	return d
}()

let targetDeps: [Target.Dependency] = {
	var d: [Target.Dependency] = [
		"DSFRegex",
		"SwiftImageReadWrite",
		"TinyCSV",
		"BytesParser",
	]
#if !os(Linux)
	d.append("ZIPFoundation")
#endif
	return d
}()

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
	dependencies: packageDeps,
	targets: [
		.target(
			name: "ColorPaletteCodable",
			dependencies: targetDeps,
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
