@testable import ColorPaletteCodable
import XCTest

import Foundation

class OpenOfficePaletteTests: XCTestCase {

	let files = [
		("libreoffice.soc", 32),
		("standard.soc", 120),
		("freecolour-hlc.soc", 1032),
		("scribus.soc", 546)
	]

	func testAllRoundTrip() throws {
		try files.forEach { item in
			Swift.print("> Roundtripping: \(item.0)")
			let palette = try loadResourcePalette(named: item.0)
			XCTAssertEqual(item.1, palette.allColors().count)

			let coder = PAL.Coder.OpenOfficePaletteCoder()
			let data = try coder.encode(palette)

			let rebuilt = try coder.decode(from: data)

			XCTAssertEqual(rebuilt.name, palette.name)
			XCTAssertEqual(rebuilt.allColors(), palette.allColors())
		}
	}
}
