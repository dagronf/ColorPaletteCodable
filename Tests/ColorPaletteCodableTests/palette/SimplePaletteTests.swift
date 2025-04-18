@testable import ColorPaletteCodable
import XCTest

import Foundation

class SimplePaletteTests: XCTestCase {

	let files = [
		"basic.color-palette",
		"favorites.color-palette",
		"aap-64.color-palette",
	]

	func testAllRoundTrip() throws {
		try files.forEach { item in
			Swift.print("> Roundtripping: \(item)")
			let palette = try loadResourcePalette(named: item)
			let coder = PAL.Coder.SimplePaletteCoder()

			// Encode!
			let data = try coder.encode(palette)

			// Decode!
			let rebuilt = try coder.decode(from: data)

			// Check that we're still the same
			XCTAssertEqual(rebuilt.name, palette.name)

			// Check we are _mostly_ the same -- conversion and precision modifies the values somewhat
			XCTAssertTrue(AreAllColorsEqual(rebuilt.allColors(), palette.allColors(), precision: 4))
		}
	}

	func testBasic() throws {
		let palette = try loadResourcePalette(named: "basic.color-palette")
		XCTAssertEqual(palette.name, "")
		XCTAssertEqual(palette.colors.count, 5)
		XCTAssertEqual(palette.groups.count, 0)
	}
}
