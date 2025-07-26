@testable import ColorPaletteCodable
import XCTest
import Foundation

class HPLPaletteTests: XCTestCase {

	func testLoad1() throws {
		let palette = try loadResourcePalette(named: "hpl1_v4.0.hpl")
		let colors = palette.allColors()
		XCTAssertEqual(colors.count, 287)
	}

	func testLoad2() throws {
		let palette = try loadResourcePalette(named: "hpl2_v4.0.hpl")
		let colors = palette.allColors()
		XCTAssertEqual(colors.count, 256)
	}

	func testBasicSaveReload() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "Default", withExtension: "gpl"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(23, palette.colors.count)

		let saved = try PAL.Coder.HPL().encode(palette)

		let loaded = try PAL.Coder.HPL().decode(from: saved)
		XCTAssertEqual(23, loaded.colors.count)

		// HPL doesn't save the color names
		for color in loaded.colors {
			XCTAssertEqual("", color.name)
		}

		XCTAssertEqual(loaded.colors[11].colorComponents[0], 0.509803921, accuracy: 0.0001)
		XCTAssertEqual(loaded.colors[11].colorComponents[1], 0.498039215, accuracy: 0.0001)
		XCTAssertEqual(loaded.colors[11].colorComponents[2], 0.0, accuracy: 0.01)

		XCTAssertEqual(loaded.colors[13].colorComponents[0], 0.1, accuracy: 0.01)
		XCTAssertEqual(loaded.colors[13].colorComponents[1], 0.1, accuracy: 0.01)
		XCTAssertEqual(loaded.colors[13].colorComponents[2], 0.1, accuracy: 0.01)
	}
}
