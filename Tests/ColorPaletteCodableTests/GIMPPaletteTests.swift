@testable import ColorPaletteCodable
import XCTest

import Foundation

class GIMPPaletteTests: XCTestCase {

	// You can find palette files in
	//  /Applications/GIMP-2.10.app/Contents/Resources/share/gimp/2.0/palettes/

	func testAll() throws {
		let files = ["atari-800xl-palette", "Caramel", "Default", "pear36-sep-rn"]
		try files.forEach { file in
			let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: file, withExtension: "gpl"))
			let palette = try PAL.Palette.Decode(from: paletteURL)
			XCTAssertGreaterThan(palette.colors.count, 0)
			let data = try PAL.Coder.GIMP().encode(palette)
			let palette2 = try PAL.Palette.Decode(from: data, fileExtension: "gpl")
			XCTAssertGreaterThan(palette2.colors.count, 0)
			XCTAssertEqual(palette.colors.count, palette2.colors.count)
		}
	}

	#if !os(Linux) && !os(Windows)
	func testImage() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "atari-800xl-palette", withExtension: "gpl"))
		let palette = try PAL.Palette.Decode(from: paletteURL)

		let sz = CGSize(width: 200, height: 200)
		let image = try XCTUnwrap(PAL.Image.GeneratePaletteImage(palette: palette, size: sz))
		XCTAssertEqual(image.size, sz)

		// Force the drawing
		let _ = try image.representation.png()
		Swift.print(image)
	}
	#endif

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

	func testUnableToLoadGPL() throws {
		// This file has a UTF8 bom
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "atari-800xl-palette", withExtension: "gpl"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual("Atari 800XL Palette", palette.name)
		XCTAssertEqual(256, palette.colors.count)
	}
}
