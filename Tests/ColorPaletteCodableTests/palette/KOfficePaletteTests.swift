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
}
