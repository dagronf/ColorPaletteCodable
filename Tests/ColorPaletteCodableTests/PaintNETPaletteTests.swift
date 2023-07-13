@testable import ColorPaletteCodable
import XCTest

final class PaintNETPaletteTests: XCTestCase {

	func testPaintNET() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "Paint_NET", withExtension: "txt"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(27, palette.colors.count)
		XCTAssertEqual(PAL.Color.RGB(r: 0, g: 0, b: 0, a: 1), try palette.colors[0].rgbValues())
		XCTAssertEqual(PAL.Color.RGB(r: 1, g: 0, b: 0, a: 1), try palette.colors[1].rgbValues())
		XCTAssertEqual(PAL.Color.RGB(r: 0, g: 0, b: 1, a: 1), try palette.colors[2].rgbValues())

		let data = try PAL.Coder.PaintNET().encode(palette)
		let palette2 = try PAL.Coder.PaintNET().decode(from: data)
		XCTAssertEqual(palette, palette2)
	}

	func testPaintNET_2() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "lospec500", withExtension: "txt"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(42, palette.colors.count)

		let data = try PAL.Coder.PaintNET().encode(palette)
		let palette2 = try PAL.Coder.PaintNET().decode(from: data)
		XCTAssertEqual(palette, palette2)
	}

	func testPaintNET_3() throws {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "eb-gb-strawberry-flavour", withExtension: "txt"))
		let palette = try PAL.Palette.Decode(from: paletteURL)
		XCTAssertEqual(4, palette.colors.count)

		let data = try PAL.Coder.PaintNET().encode(palette)
		//Swift.print(String(data: data, encoding: .utf8))

		let palette2 = try PAL.Coder.PaintNET().decode(from: data)
		XCTAssertEqual(palette, palette2)
	}
}
