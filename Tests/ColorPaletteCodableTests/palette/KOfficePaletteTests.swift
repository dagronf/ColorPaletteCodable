@testable import ColorPaletteCodable
import XCTest

import Foundation

class KOfficePaletteTests: XCTestCase {

	func testBasicDefault() throws {
		let palette = try loadResourcePalette(named: "KDE40.colors")
		let colors = palette.allColors()
		XCTAssertEqual(colors.count, 40)

		XCTAssertEqual("Black", colors[0].name)
		XCTAssertEqual(try colors[0].rgb().components255, [0, 0, 0])
		XCTAssertEqual("Almost black", colors[1].name)
		XCTAssertEqual(try colors[1].rgb().components255, [48, 48, 48])
		XCTAssertEqual("Very light orange", colors[39].name)
		XCTAssertEqual(try colors[39].rgb().components255, [255, 220, 168])
	}

	func testBasicSaveReload() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "Default", withExtension: "gpl"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(23, palette.colors.count)

		let saved = try PAL.Coder.KOffice().encode(palette)

		let loaded = try PAL.Coder.KOffice().decode(from: saved)
		XCTAssertEqual(23, loaded.colors.count)

		XCTAssertEqual("Red", loaded.colors[0].name)
		XCTAssertEqual("Dark Magenta", loaded.colors[7].name)
		XCTAssertEqual("Gray 10%", loaded.colors[13].name)
		XCTAssertEqual(loaded.colors[13].colorComponents[0], 0.1, accuracy: 0.01)
		XCTAssertEqual(loaded.colors[13].colorComponents[1], 0.1, accuracy: 0.01)
		XCTAssertEqual(loaded.colors[13].colorComponents[2], 0.1, accuracy: 0.01)
	}
}
