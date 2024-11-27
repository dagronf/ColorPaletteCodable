@testable import ColorPaletteCodable
import XCTest

import Foundation

class XMLPaletteTests: XCTestCase {

	let files = [
		"db32-cmyk.xml",
		"db32-rgb.xml",
		"Signature.xml",
		"ThermoFlex Plus.xml",     // colorspaces
		"Satins Cap Colors.xml"    // CMYK colors
	]

	func testAllRoundTrip() throws {
		try files.forEach { item in
			Swift.print("> Roundtripping: \(item)")
			let palette = try loadResourcePalette(named: item)
			let coder = PAL.Coder.CorelXMLPalette()
			let data = try coder.encode(palette)

			let rebuilt = try coder.decode(from: data)

			XCTAssertEqual(rebuilt.name, palette.name)
			XCTAssertEqual(rebuilt.allColors().count, palette.allColors().count)
		}
	}

	func testXMLWithCustomColorspace() throws {
		let palette = try loadResourcePalette(named: "ThermoFlex Plus.xml")
		XCTAssertEqual(palette.colors.count, 0)
		XCTAssertEqual(palette.groups.count, 1)
		XCTAssertEqual(palette.groups[0].colors.count, 101)
	}

	func testBasicXML1() throws {
		let data = try loadResourceData(named: "basic-xml-1.xml")
		let c = PAL.Coder.BasicXML()

		let palette: PAL.Palette = try {
			try usingStreamData(data) { s in
				return try c.decode(from: s)
			}
		}()
		XCTAssertEqual(palette.colors.count, 5)
		XCTAssertEqual(palette.name, "basicxml")

		let ep = try c.encode(palette)
		let dec = try c.decode(from: ep)
		XCTAssertEqual(dec.colors.count, 5)
		XCTAssertEqual(dec.name, "basicxml")
	}
}
