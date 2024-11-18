@testable import ColorPaletteCodable
import XCTest

import Foundation

class AndroidColorsXMLTests: XCTestCase {

	let files = [
		"android_webcolors_colors.xml",
		"android_basicrgbcolors.xml",
		"android_basicrgbacolors.xml",
		"android_colors_xml.xml",
		"android_colors_comments_xml.xml",
	]

	func testAllRoundTrip() throws {
		try files.forEach { item in
			Swift.print("> Roundtripping: \(item)")
			let palette = try loadResourcePalette(named: item)
			let coder = PAL.Coder.AndroidColorsXML()
			let data = try coder.encode(palette)

			let rebuilt = try coder.decode(from: data)

			XCTAssertEqual(rebuilt.name, palette.name)
			XCTAssertEqual(rebuilt.allColors().count, palette.allColors().count)

			/// Make sure all the colors match
			XCTAssertEqual(rebuilt.allColors(), palette.allColors())
		}
	}

	func testWebColorsXMLDecode() throws {
		let palette = try loadResourcePalette(named: "android_webcolors_colors.xml")
		XCTAssertEqual(140, palette.colors.count)

		XCTAssertEqual(palette.colors[0].name, "White")
		XCTAssertEqual(try palette.colors[0].hexRGBA(hashmark: false, uppercase: true), "FFFFFFFF")

		XCTAssertEqual(palette.colors[1].name, "Ivory")
		XCTAssertEqual(try palette.colors[1].hexRGBA(hashmark: false, uppercase: true), "FFFFF0FF")

		XCTAssertEqual(palette.colors[139].name, "Black")
		XCTAssertEqual(try palette.colors[139].hexRGBA(hashmark: false, uppercase: true), "000000FF")

		XCTAssertEqual(palette.colors[73].name, "LightSteelBlue")
		XCTAssertEqual(try palette.colors[73].hexRGBA(hashmark: false, uppercase: true), "B0C4DEFF")
	}

	func testWebColorsXMLDecodeWithAlpha() throws {
		let palette = try loadResourcePalette(named: "android_basicrgbcolors_with_alpha.xml")
		XCTAssertEqual(3, palette.colors.count)

		XCTAssertEqual(234.0 / 255.0, palette.colors[0].alpha, accuracy: 0.00001)
		XCTAssertEqual(85.0 / 255.0, palette.colors[1].alpha, accuracy: 0.00001)
		XCTAssertEqual(33.0 / 255.0, palette.colors[2].alpha, accuracy: 0.00001)
	}

	func testEncode() throws {
		var palette = PAL.Palette()
		let c1 = try PAL.Color(name: "red", colorSpace: .RGB, colorComponents: [1, 0, 0])
		let c2 = try PAL.Color(name: "green", colorSpace: .RGB, colorComponents: [0, 1, 0])
		let c3 = try PAL.Color(name: "blue", colorSpace: .RGB, colorComponents: [0, 0, 1])
		palette.colors.append(contentsOf: [c1, c2, c3])

		do {
			// Check ignoring alpha during coding
			let coder = PAL.Coder.AndroidColorsXML(includeAlphaDuringExport: false)
			let data = try coder.encode(palette)
			//try data.write(to: URL(fileURLWithPath: "/tmp/colors.xml"))
			let matchData = try loadResourceData(named: "android_basicrgbcolors.xml")
			XCTAssertEqual(matchData, data)
		}

		do {
			// Check including alpha during coding
			let coder = PAL.Coder.AndroidColorsXML(includeAlphaDuringExport: true)
			let data = try coder.encode(palette)
			//try data.write(to: URL(fileURLWithPath: "/tmp/colors-a.xml"))
			let matchData = try loadResourceData(named: "android_basicrgbacolors.xml")
			XCTAssertEqual(matchData, data)
		}
	}
}
