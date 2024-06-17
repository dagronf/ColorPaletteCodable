@testable import ColorPaletteCodable
import XCTest

import Foundation

class SketchPaletteTests: XCTestCase {

	func testAllRoundTrip() throws {
		let files = [
			"ios.sketchpalette",
			"material-design.sketchpalette",
			"sketch-default.sketchpalette",
			"iOS-Material-FlatUI.sketchpalette",
			"emoji-average-colors.gpl.sketchpalette"
		]
		try files.forEach { file in
			let palette = try loadResourcePalette(named: file)
			let data = try PAL.Coder.SketchPalette().encode(palette)
			let palette2 = try PAL.Palette.Decode(from: data, fileExtension: "sketchpalette")
			XCTAssertEqual(palette.colors.count, palette2.colors.count)
		}
	}

	func testBasicDefault() throws {
		let palette = try loadResourcePalette(named: "material-design.sketchpalette")
		XCTAssertEqual(256, palette.colors.count)
		XCTAssertEqual(palette.colors[0].colorComponents[0], 0.9568, accuracy: 0.001)
		XCTAssertEqual(palette.colors[0].colorComponents[1], 0.2627, accuracy: 0.001)
		XCTAssertEqual(palette.colors[0].colorComponents[2], 0.2117, accuracy: 0.001)
		XCTAssertEqual(palette.colors[0].alpha, 1, accuracy: 0.001)

		XCTAssertEqual(palette.colors[1].colorComponents[0], 1, accuracy: 0.001)
		XCTAssertEqual(palette.colors[1].colorComponents[1], 0.921, accuracy: 0.001)
		XCTAssertEqual(palette.colors[1].colorComponents[2], 0.933, accuracy: 0.001)
		XCTAssertEqual(palette.colors[1].alpha, 1, accuracy: 0.001)

		XCTAssertEqual(palette.colors[255].colorComponents[0], 1, accuracy: 0.001)
		XCTAssertEqual(palette.colors[255].colorComponents[1], 1, accuracy: 0.001)
		XCTAssertEqual(palette.colors[255].colorComponents[2], 1, accuracy: 0.001)
		XCTAssertEqual(palette.colors[255].alpha, 1, accuracy: 0.001)
	}

	func testSketchPaletteWithHex() throws {
		let palette = try loadResourcePalette(named: "iOS-Material-FlatUI.sketchpalette")
		XCTAssertEqual(48, palette.colors.count)
		XCTAssertEqual(palette.colors[0].hexRGB, "#ffffff")
		XCTAssertEqual(palette.colors[1].hexRGB, "#efeff4")
		XCTAssertEqual(palette.colors[2].hexRGB, "#ceced2")
		XCTAssertEqual(palette.colors[47].hexRGB, "#be3a31")
	}
}
