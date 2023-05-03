@testable import ColorPaletteCodable
import XCTest

let acb_resources = [
	"ANPA Color",
]

final class ACBPaletteTests: XCTestCase {
	func testWriteReadRoundTripSampleACBFiles() throws {
		let paletteCoder = PAL.Coder.ACB()

		Swift.print("Round-tripping ACB files...'")
		// Loop through all the resource files
		for name in acb_resources {
			let controlACO = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "acb"))

			Swift.print("Validating '\(name)...'")

			// Attempt to load the ase file
			let swatches = try paletteCoder.decode(from: controlACO)

			// Write to a data stream
			let data = try paletteCoder.encode(swatches)

			// Re-create the ase structure from the written data ...
			let reconstitutedSwatches = try paletteCoder.decode(from: data)

			// ... and check equality between the original file and our reconstituted one.
			XCTAssertEqual(swatches, reconstitutedSwatches)
		}
	}
}
