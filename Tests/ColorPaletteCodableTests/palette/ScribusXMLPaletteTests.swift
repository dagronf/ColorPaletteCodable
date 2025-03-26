@testable import ColorPaletteCodable
import XCTest

import Foundation

class ScribusXMLPaletteTests: XCTestCase {

	let files = [
		("Echo_Icon_Theme_Palette.xml", 27),
		("Scribus_Splash.xml", 20),
	]

	func testBasic() throws {
		let palette = try loadResourcePalette(named: "Echo_Icon_Theme_Palette.xml")
		XCTAssertEqual(27, palette.allColors().count)

		let coder = PAL.Coder.ScribusXMLPaletteCoder()
		let data = try coder.encode(palette)
		let palette2 = try coder.decode(from: data)
		XCTAssertEqual(palette, palette2)
	}

	func testAllRoundTrip() throws {
		try files.forEach { item in
			Swift.print("> Roundtripping: \(item.0)")
			let palette = try loadResourcePalette(named: item.0)
			XCTAssertEqual(item.1, palette.allColors().count)

			let coder = PAL.Coder.ScribusXMLPaletteCoder()
			let data = try coder.encode(palette)
			let rebuilt = try coder.decode(from: data)
			XCTAssertEqual(rebuilt, palette)
		}
	}
}
