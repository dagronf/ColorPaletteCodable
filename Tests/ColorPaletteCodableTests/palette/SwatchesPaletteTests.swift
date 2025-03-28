@testable import ColorPaletteCodable
import XCTest

#if !os(Linux)

// ZipFoundation fails to compile on linux, so lets ignore it for the moment

import Foundation

class SwatchesPaletteTests: XCTestCase {

	let files = [
		("Ascend.swatches", 24),
		("mypalette.swatches", 2)
	]

	func testBasic() throws {

		let palette2 = try loadResourcePalette(named: "mypalette.swatches")
		XCTAssertEqual(2, palette2.allColors().count)

		let url = try resourceURL(for: "Ascend.swatches")
		let coder = PAL.Coder.SwatchesPaletteCoder()
		let palette = try coder.decode(from: url)

		XCTAssertEqual(24, palette.allColors().count)
	}

	func testAllRoundTrip() throws {
		try files.forEach { item in
			Swift.print("> Roundtripping: \(item.0)")
			let palette = try loadResourcePalette(named: item.0)
			XCTAssertEqual(item.1, palette.allColors().count)

			// Doesn't support coding yet

//			let coder = PAL.Coder.ScribusXMLPaletteCoder()
//			let data = try coder.encode(palette)
//			let rebuilt = try coder.decode(from: data)
//			XCTAssertEqual(rebuilt, palette)
		}
	}
}

#endif
