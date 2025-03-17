@testable import ColorPaletteCodable
import XCTest

let act_resources = [
	"16pal_v20.act",
	"arne-v20-16.act",
	"iconworkshop.act"
]

final class ACTSwatchesTests: XCTestCase {
	func testWriteReadRoundTripSampleACOFiles() throws {
		let paletteCoder = PAL.Coder.ACT()

		Swift.print("Round-tripping ACT files...'")
		// Loop through all the resource files
		for name in act_resources {
			Swift.print("Validating '\(name)...'")

			// Attempt to load the ase file
			let swatches = try loadResourcePalette(named: name)
			XCTAssertEqual(swatches.format, .act)

			// Write to a data stream
			let data = try paletteCoder.encode(swatches)

			// Re-create the ase structure from the written data ...
			let reconstitutedSwatches = try paletteCoder.decode(from: data)

			// ... and check equality between the original file and our reconstituted one.

			// We can't just equality check, as reading _in_ the file we support alpha, but we
			// cannot write it back out

			XCTAssertEqual(swatches.name, reconstitutedSwatches.name)
			XCTAssertEqual(swatches.groups.count, reconstitutedSwatches.groups.count)
			XCTAssertEqual(swatches.colors.count, reconstitutedSwatches.colors.count)
		}
	}

	func testReadACTFileWithAlphaIndex() throws {
		do {
			// This file specifies that index 0 is the 'alpha' color
			let palette = try loadResourcePalette(named: "arne-v20-16.act")
			XCTAssertEqual(palette.colors.count, 16)
			(0 ..< 16).forEach { index in
				XCTAssertEqual(palette.colors[index].alpha, index == 0 ? 0 : 1)
			}
		}

		do {
			// This file doesn't define an alpha index
			let palette = try loadResourcePalette(named: "16pal_v20.act")
			XCTAssertEqual(palette.colors.count, 16)
			(0 ..< 16).forEach { index in
				XCTAssertEqual(palette.colors[index].alpha, 1)
			}
		}

		do {
			// This file doesn't define an alpha index
			let palette = try loadResourcePalette(named: "iconworkshop.act")
			XCTAssertEqual(palette.colors.count, 48)
			(0 ..< palette.colors.count).forEach { index in
				XCTAssertEqual(palette.colors[index].alpha, index == 0 ? 0 : 1)
			}
		}
	}
}
