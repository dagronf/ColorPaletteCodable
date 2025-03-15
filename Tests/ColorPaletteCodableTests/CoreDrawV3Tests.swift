@testable import ColorPaletteCodable
import XCTest

final class CoreDrawV3Tests: XCTestCase {
	func testRoundTripAllTestFiles() throws {
		let files = [
			"DB32-CDR.PAL",
			"Farbpalette Trotec Laser (Corel Draw 3).pal",
			"WithQuote.PAL",
		]
		try files.forEach { file in
			let paletteURL = try resourceURL(for: file)
			let palette = try PAL.Palette(paletteURL, format: .corelDrawV3)

			// Export out
			let data = try palette.export(format: .corelDrawV3)

			// Read back
			let palette2 = try PAL.Palette(data, format: .corelDrawV3)

			// and compare!
			XCTAssertEqual(palette.colors, palette2.colors)
		}
	}

	func testBasic() throws {
		do {
			// Check load with explicit coder
			let pal = try loadResourcePalette(
				named: "Farbpalette Trotec Laser (Corel Draw 3).pal",
				using: PAL.Coder.CorelDraw3PaletteCoder()
			)
			XCTAssertEqual(27, pal.colors.count)

			XCTAssertEqual(pal.colors[0].name, "Schwarz")
			XCTAssertEqual(pal.colors[0].colorComponents, [0, 0, 0, 1])
			XCTAssertEqual(pal.colors[0].alpha, 1.0)

			XCTAssertEqual(pal.colors[1].name, "Rot")
			XCTAssertEqual(pal.colors[1].colorComponents, [0, 1, 1, 0])
			XCTAssertEqual(pal.colors[1].alpha, 1.0)

			XCTAssertEqual(pal.colors.last?.name, "0%")
			XCTAssertEqual(pal.colors.last?.colorComponents, [0, 0, 0, 0])
			XCTAssertEqual(pal.colors.last?.alpha, 1.0)
		}

		do {
			// Check that we can be loaded from our extension
			let url = try resourceURL(for: "Farbpalette Trotec Laser (Corel Draw 3).pal")
			let pal = try PAL.Palette(url)
			XCTAssertEqual(27, pal.colors.count)
		}
	}
}
