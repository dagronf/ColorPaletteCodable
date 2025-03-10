@testable import ColorPaletteCodable
import XCTest

import Foundation

class JASCPaletteTests: XCTestCase {

	func testAllRoundTrip() throws {
		let files = ["DB16", "empty", "jasc256", "paintnet-palette"]
		try files.forEach { file in
			let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: file, withExtension: "pal"))
			let palette = try PAL.Palette.Decode(from: paletteURL)
			let data = try PAL.Coder.PaintShopPro().encode(palette)
			let palette2 = try PAL.Palette.Decode(from: data, fileExtension: "pal")
			XCTAssertEqual(palette.colors.count, palette2.colors.count)
		}
	}

	func testEmpty() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "empty", withExtension: "pal"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(0, palette.colors.count)

		let data = try PAL.Coder.PaintShopPro().encode(palette)
		XCTAssertGreaterThan(data.count, 0)
		try data.write(to: URL(fileURLWithPath: "/tmp/blank-jasc.pal"))
	}

	func testBasicDefault() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "paintnet-palette", withExtension: "pal"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(24, palette.colors.count)
		XCTAssertEqual(palette.colors[0].colorComponents[0], 1, accuracy: 0.001)
		XCTAssertEqual(palette.colors[0].colorComponents[1], 0, accuracy: 0.001)
		XCTAssertEqual(palette.colors[0].colorComponents[2], 0, accuracy: 0.001)

		let data = try PAL.Coder.PaintShopPro().encode(palette)
		XCTAssertGreaterThan(data.count, 0)
		try data.write(to: URL(fileURLWithPath: "/tmp/encoded.pal"))
	}

	func testMultipleExtensionSupport() throws {
		// PaintShopPro has multiple extensions (pal, psppalette).
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "atari-800xl-palette", withExtension: "psppalette"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(256, palette.colors.count)
		XCTAssertEqual(palette.colors[0], try PAL.Color(rgbaHexString: "#000000", colorType: .global))
		XCTAssertEqual(palette.colors[1], PAL.Color(r255: 37, g255: 37, b255: 37))
		XCTAssertEqual(palette.colors[254], PAL.Color(r255: 255, g255: 207, b255: 126))
		XCTAssertEqual(palette.colors[255], PAL.Color(r255: 255, g255: 218, b255: 150))

		let data = try PAL.Coder.PaintShopPro().encode(palette)
		let palette2 = try PAL.Palette.Decode(from: data, fileExtension: "psppalette")
		XCTAssertEqual(256, palette2.colors.count)
		XCTAssertEqual(palette2.colors[0], try PAL.Color(rgbaHexString: "#000000", colorType: .global))
		XCTAssertEqual(palette2.colors[1], PAL.Color(r255: 37, g255: 37, b255: 37))
		XCTAssertEqual(palette2.colors[254], PAL.Color(r255: 255, g255: 207, b255: 126))
		XCTAssertEqual(palette2.colors[255], PAL.Color(r255: 255, g255: 218, b255: 150))
	}
}
