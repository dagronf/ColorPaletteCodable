@testable import ColorPaletteCodable
import XCTest

final class PaintNETPaletteTests: XCTestCase {

	func testPaintNET() throws {
		let palette = try loadResourcePalette(named: "Paint_NET.txt")
		XCTAssertEqual(27, palette.colors.count)
		XCTAssertEqual("#000000ff", palette.colors[0].hexRGBA)
		XCTAssertEqual("#ff0000ff", palette.colors[1].hexRGBA)
		XCTAssertEqual("#0000ffff", palette.colors[2].hexRGBA)
		XCTAssertEqual(PAL.Color.RGB(r: 0, g: 0, b: 0, a: 1), try palette.colors[0].rgbValues())
		XCTAssertEqual(PAL.Color.RGB(r: 1, g: 0, b: 0, a: 1), try palette.colors[1].rgbValues())
		XCTAssertEqual(PAL.Color.RGB(r: 0, g: 0, b: 1, a: 1), try palette.colors[2].rgbValues())

		let data = try PAL.Coder.PaintNET().encode(palette)
		let palette2 = try PAL.Coder.PaintNET().decode(from: data)
		XCTAssertEqual(palette, palette2)
	}

	func testPaintNET_2() throws {
		let palette = try loadResourcePalette(named: "lospec500.txt")
		XCTAssertEqual(42, palette.colors.count)

		let data = try PAL.Coder.PaintNET().encode(palette)
		let palette2 = try PAL.Coder.PaintNET().decode(from: data)
		XCTAssertEqual(palette, palette2)
	}

	func testPaintNET_3() throws {
		let palette = try loadResourcePalette(named: "eb-gb-strawberry-flavour.txt")
		XCTAssertEqual(4, palette.colors.count)

		XCTAssertEqual("#f6edc1ff", palette.colors[0].hexRGBA)
		XCTAssertEqual("#f890a8ff", palette.colors[1].hexRGBA)
		XCTAssertEqual("#8b506dff", palette.colors[2].hexRGBA)
		XCTAssertEqual("#381a3eff", palette.colors[3].hexRGBA)

		let data = try PAL.Coder.PaintNET().encode(palette)
		let palette2 = try PAL.Coder.PaintNET().decode(from: data)
		XCTAssertEqual(palette, palette2)
	}
}
