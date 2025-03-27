@testable import ColorPaletteCodable
import XCTest

import Foundation

class SwatchesPaletteTests: XCTestCase {

	let files = [
		("Ascend.swatches", 24),
		("mypalette.swatches", 18)
	]

	func testBasic() throws {

		let palette2 = try loadResourcePalette(named: "mypalette.swatches")
		XCTAssertEqual(2, palette2.allColors().count)

		let url = try resourceURL(for: "Ascend.swatches")
		let coder = PAL.Coder.SwatchesPaletteCoder()
		let palette = try coder.decode(from: url)

		XCTAssertEqual(24, palette.allColors().count)
	}

//	func testAllRoundTrip() throws {
//		try files.forEach { item in
//			Swift.print("> Roundtripping: \(item.0)")
//			let palette = try loadResourcePalette(named: item.0)
//			XCTAssertEqual(item.1, palette.allColors().count)
//
//			let coder = PAL.Coder.ScribusXMLPaletteCoder()
//			let data = try coder.encode(palette)
//			let rebuilt = try coder.decode(from: data)
//			XCTAssertEqual(rebuilt, palette)
//		}
//	}
}
