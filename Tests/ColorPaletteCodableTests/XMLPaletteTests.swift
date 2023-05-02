@testable import ColorPaletteCodable
import XCTest

import Foundation

class XMLPaletteTests: XCTestCase {
	
	func testAllRoundTrip() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "db32-rgb", withExtension: "xml"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(palette.groups.count, 1)
		XCTAssertEqual(palette.groups[0].colors.count, 32)

		let coder = PAL.Coder.XMLPalette()
		let data = try coder.encode(palette)

		let str = try XCTUnwrap(String(data: data, encoding: .utf8))
		XCTAssert(str.count > 0)
	}

	func testXMLWithCustomColorspace() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "ThermoFlex Plus", withExtension: "xml"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(palette.colors.count, 0)
		XCTAssertEqual(palette.groups.count, 1)
		XCTAssertEqual(palette.groups[0].colors.count, 101)
	}
}
