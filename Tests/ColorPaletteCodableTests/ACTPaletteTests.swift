@testable import ColorPaletteCodable
import XCTest

let act_resources = [
	"16pal_v20",
	"arne-v20-16",
	"iconworkshop"
]

final class ACTSwatchesTests: XCTestCase {
	func testWriteReadRoundTripSampleACOFiles() throws {
		let paletteCoder = PAL.Coder.ACT()

		Swift.print("Round-tripping ACT files...'")
		// Loop through all the resource files
		for name in act_resources {
			let url = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "act"))

			Swift.print("Validating '\(name)...'")

			// Attempt to load the ase file
			let swatches = try paletteCoder.decode(from: url)

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
			let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "arne-v20-16", withExtension: "act"))
			let palette = try PAL.Palette.Decode(from: paletteURL)
			XCTAssertEqual(palette.colors.count, 16)
			(0 ..< 16).forEach { index in
				XCTAssertEqual(palette.colors[index].alpha, index == 0 ? 0 : 1)
			}
		}

		do {
			// This file doesn't define an alpha index
			let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "16pal_v20", withExtension: "act"))
			let palette = try PAL.Palette.Decode(from: paletteURL)
			XCTAssertEqual(palette.colors.count, 16)
			(0 ..< 16).forEach { index in
				XCTAssertEqual(palette.colors[index].alpha, 1)
			}
		}

		do {
			// This file doesn't define an alpha index
			let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: "iconworkshop", withExtension: "act"))
			let palette = try PAL.Palette.Decode(from: paletteURL)
			XCTAssertEqual(palette.colors.count, 48)
			(0 ..< palette.colors.count).forEach { index in
				XCTAssertEqual(palette.colors[index].alpha, index == 0 ? 0 : 1)
			}
		}
	}
}
