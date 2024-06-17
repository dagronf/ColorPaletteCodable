@testable import ColorPaletteCodable
import XCTest

let acb_resources: [(name: String, count: Int)] = [
	("ANPA Color.acb", 300),
	("DIC Color Guide.acb", 1280),
	("HKS E (LAB).acb", 88),
	("HKS K Process (CMYK).acb", 86),
]

final class ACBPaletteTests: XCTestCase {

	func testWriteReadRoundTripSampleACBFiles() throws {
		// Loop through all the resource files
		for item in acb_resources {
			let swatches = try loadResourcePalette(named: item.name, using: PAL.Coder.ACB())
			XCTAssertEqual(item.count, swatches.allColors().count)

			// Write to a data stream. Not implemented
			let _ = XCTAssertThrowsError(try PAL.Coder.ACB().encode(swatches))
		}
	}

	func testACBLab() throws {
		let swatches = try loadResourcePalette(named: "ANPA Color.acb")

		XCTAssertEqual(0, swatches.groups.count)
		XCTAssertEqual(300, swatches.colors.count)

		XCTAssertEqual(swatches.colors[0].colorSpace, .LAB)
		XCTAssertEqual(swatches.colors[299].colorSpace, .LAB)
	}

	func testACBCMYK() throws {
		let swatches = try loadResourcePalette(named: "HKS K Process (CMYK).acb")

		XCTAssertEqual(0, swatches.groups.count)
		XCTAssertEqual(86, swatches.colors.count)

		XCTAssertEqual(swatches.colors[0].colorSpace, .CMYK)
	}
}
