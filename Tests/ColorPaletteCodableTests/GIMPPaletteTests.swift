@testable import ColorPaletteCodable
import XCTest

import Foundation

class GIMPPaletteTests: XCTestCase {

	// You can find palette files in
	//  /Applications/GIMP-2.10.app/Contents/Resources/share/gimp/2.0/palettes/

	func testBasicDefault() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "Default", withExtension: "gpl"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(23, palette.colors.count)
		XCTAssertEqual("Red", palette.colors[0].name)
		XCTAssertEqual("Dark Magenta", palette.colors[7].name)
		XCTAssertEqual("Gray 10%", palette.colors[13].name)
		XCTAssertEqual(palette.colors[13].colorComponents[0], 0.1, accuracy: 0.01)
		XCTAssertEqual(palette.colors[13].colorComponents[1], 0.1, accuracy: 0.01)
		XCTAssertEqual(palette.colors[13].colorComponents[2], 0.1, accuracy: 0.01)

		let data = try PAL.Coder.GIMP().encode(palette)
		XCTAssertGreaterThan(data.count, 0)
		//try data.write(to: URL(fileURLWithPath: "/tmp/encoded.gpl"))
	}

	func testBasic() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "Caramel", withExtension: "gpl"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(256, palette.colors.count)
	}

	func testLoadAgain() throws {
		let demo = """
			GIMP Palette
			Name: mona
			#Description:
			#Colors: 6
			91	64	78	5b404e
			119	90	95	775a5f
			142	116	112	8e7470
			172	155	144	ac9b90
			210	204	184	d2ccb8
			238	238	225	eeeee1
			"""
		let data = demo.data(using: .utf8)!
		let palette = try PAL.Coder.GIMP().decode(from: data)
		XCTAssertEqual("mona", palette.name)
		XCTAssertEqual(6, palette.colors.count)
		XCTAssertEqual("5b404e", palette.colors[0].name)

		let aseData = try PAL.Coder.ASE().encode(palette)

		let recons = try PAL.Palette.Decode(from: aseData, fileExtension: "ase")
		// ASE format doesn't support palette name
		XCTAssertEqual("", recons.name)
		XCTAssertEqual(6, recons.colors.count)
		XCTAssertEqual("5b404e", recons.colors[0].name)
	}

	func testSlashRSlashNSeparator() throws {
		// Check handling \r\n separators
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "pear36-sep-rn", withExtension: "gpl"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(36, palette.colors.count)
	}
}
