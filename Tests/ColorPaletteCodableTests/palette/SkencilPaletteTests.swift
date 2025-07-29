@testable import ColorPaletteCodable
import XCTest

import Foundation

class SkencilPaletteTests: XCTestCase {
	func testBasicLoad() throws {
		let palette = try loadResourcePalette(named: "mini.spl")

		XCTAssertEqual(23, palette.colors.count)

		XCTAssertEqual("Black", palette.colors[0].name)
		XCTAssertEqual("#000000ff", try palette.colors[0].hexRGBA(hashmark: true))

		XCTAssertEqual("Green", palette.colors[12].name)
		XCTAssertEqual("#00ff00ff", try palette.colors[12].hexRGBA(hashmark: true))

		XCTAssertEqual("Dark Yellow", palette.colors[22].name)
		XCTAssertEqual("#808000ff", try palette.colors[22].hexRGBA(hashmark: true))
	}

	func testBasicSaveReload() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "Default", withExtension: "gpl"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(23, palette.colors.count)

		let saved = try PAL.Coder.Skencil().encode(palette)

		let loaded = try PAL.Coder.Skencil().decode(from: saved)
		XCTAssertEqual(23, loaded.colors.count)

		XCTAssertEqual(loaded.colors[11].name, "Dark Yellow")
		XCTAssertEqual(loaded.colors[11].colorComponents[0], 0.509803921, accuracy: 0.0001)
		XCTAssertEqual(loaded.colors[11].colorComponents[1], 0.498039215, accuracy: 0.0001)
		XCTAssertEqual(loaded.colors[11].colorComponents[2], 0.0, accuracy: 0.01)

		XCTAssertEqual(loaded.colors[13].name, "Gray 10%")
		XCTAssertEqual(loaded.colors[13].colorComponents[0], 0.1, accuracy: 0.01)
		XCTAssertEqual(loaded.colors[13].colorComponents[1], 0.1, accuracy: 0.01)
		XCTAssertEqual(loaded.colors[13].colorComponents[2], 0.1, accuracy: 0.01)
	}
}
