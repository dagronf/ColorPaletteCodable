@testable import ColorPaletteCodable
import XCTest

let acb_resources: [(name: String, count: Int)] = [
	("ANPA Color", 300),
	("DIC Color Guide", 1280),
	("HKS E (LAB)", 88),
	("HKS K Process (CMYK)", 86),
]

final class ACBPaletteTests: XCTestCase {

	private func loadPalette(_ name: String) throws -> PAL.Palette {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "acb"))
		return try PAL.Coder.ACB().decode(from: paletteURL)
	}

	func testWriteReadRoundTripSampleACBFiles() throws {
		// Loop through all the resource files
		for item in acb_resources {
			let swatches = try loadPalette(item.name)
			XCTAssertEqual(item.count, swatches.allColors().count)

			// Write to a data stream. Not implemented
			let _ = XCTAssertThrowsError(try PAL.Coder.ACB().encode(swatches))
		}
	}

	// A test harness for checking the CMYK loading from ACB files
//	func testCMYKEncodingStrangeness() throws {
//		let swatches = try loadPalette("HKS K Process (CMYK)")
//		let allColors = swatches.allColors()
//		XCTAssertEqual(86, allColors.count)
//
//		let color = allColors[0]
//		let cgColor = try XCTUnwrap(color.cgColor)
//
//		let rgb = try color.converted(to: .RGB)
//		let rgbCGColor = try XCTUnwrap(rgb.cgColor)
//
//		_ = 1
//	}
}
