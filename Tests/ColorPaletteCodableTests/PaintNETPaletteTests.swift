@testable import ColorPaletteCodable
import XCTest

final class PaintNETPaletteTests: XCTestCase {

	func testPaintNET() throws {
		let palette = try loadResourcePalette(named: "Paint_NET.txt")
		XCTAssertEqual(27, palette.colors.count)
		XCTAssertEqual("#000000ff", try palette.colors[0].hexRGBA(hashmark: true))
		XCTAssertEqual("#ff0000ff", try palette.colors[1].hexRGBA(hashmark: true))
		XCTAssertEqual("#0000ffff", try palette.colors[2].hexRGBA(hashmark: true))
		XCTAssertEqual(PAL.Color.RGB(rf: 0, gf: 0, bf: 0, af: 1), try palette.colors[0].rgb())
		XCTAssertEqual(PAL.Color.RGB(rf: 1, gf: 0, bf: 0, af: 1), try palette.colors[1].rgb())
		XCTAssertEqual(PAL.Color.RGB(rf: 0, gf: 0, bf: 1, af: 1), try palette.colors[2].rgb())

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

		XCTAssertEqual("#f6edc1ff", try palette.colors[0].hexRGBA(hashmark: true))
		XCTAssertEqual("#f890a8ff", try palette.colors[1].hexRGBA(hashmark: true))
		XCTAssertEqual("#8b506dff", try palette.colors[2].hexRGBA(hashmark: true))
		XCTAssertEqual("#381a3eff", try palette.colors[3].hexRGBA(hashmark: true))

		let data = try PAL.Coder.PaintNET().encode(palette)
		let palette2 = try PAL.Coder.PaintNET().decode(from: data)
		XCTAssertEqual(palette, palette2)
	}
}
