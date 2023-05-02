@testable import ColorPaletteCodable
import XCTest

import Foundation

class SketchPaletteTests: XCTestCase {

	func testAllRoundTrip() throws {
		let files = ["ios", "material-design", "sketch-default", "iOS-Material-FlatUI", "emoji-average-colors.gpl"]
		try files.forEach { file in
			let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: file, withExtension: "sketchpalette"))
			let palette = try PAL.Palette.Decode(from: paletteURL)
			let data = try PAL.Coder.SketchPalette().encode(palette)
			let palette2 = try PAL.Palette.Decode(from: data, fileExtension: "sketchpalette")
			XCTAssertEqual(palette.colors.count, palette2.colors.count)
		}
	}

	func testBasicDefault() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "material-design", withExtension: "sketchpalette"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
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
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "iOS-Material-FlatUI", withExtension: "sketchpalette"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(48, palette.colors.count)
	}
}
