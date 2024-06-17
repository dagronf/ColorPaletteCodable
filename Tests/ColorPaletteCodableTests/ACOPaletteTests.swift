@testable import ColorPaletteCodable
import XCTest

let aco_resources = [
	"davis-colors-concrete-pigments.aco",
	"Material Palette.aco",
	"454306_iColorpalette.aco",
	"arne-v20-16.aco",
	"Zeldman-v1.aco"
]

final class ACOSwatchesTests: XCTestCase {
	func testWriteReadRoundTripSampleACOFiles() throws {
		let paletteCoder = PAL.Coder.ACO()

		Swift.print("Round-tripping ACO files...'")
		// Loop through all the resource files
		for name in aco_resources {
			Swift.print("Validating '\(name)...'")
			// Attempt to load the ase file
			let swatches = try loadResourcePalette(named: name, using: paletteCoder)

			// Write to a data stream
			let data = try paletteCoder.encode(swatches)

			// Re-create the ase structure from the written data ...
			let reconstitutedSwatches = try paletteCoder.decode(from: data)

			// ... and check equality between the original file and our reconstituted one.
			XCTAssertEqual(swatches, reconstitutedSwatches)
		}
	}

	func testACOBasic() throws {
		let paletteCoder = PAL.Coder.ACO()
		let acoURL =  try resourceURL(for: "davis-colors-concrete-pigments.aco")
		let aco = try paletteCoder.decode(from: acoURL)
		XCTAssertEqual(59, aco.colors.count)
	}

	func testACOGoogleMaterial() throws {
		let aco = try loadResourcePalette(named: "Material Palette.aco")
		XCTAssertEqual(256, aco.colors.count)

		XCTAssertEqual("Red 500 - Primary", aco.colors[0].name)
		XCTAssertEqual("ffffff", aco.colors[255].name)
	}

	func testLoadV1() throws {
		let aco = try loadResourcePalette(named: "Zeldman-v1.aco")
		XCTAssertEqual(6, aco.colors.count)
	}

	// This file couldn't originally be loaded, as its color name encoding is slightly odd
	func testLoadBrokenNames() throws {
		let palette = try loadResourcePalette(named: "arne-v20-16.aco")
		XCTAssertEqual("", palette.name)

		XCTAssertEqual(0, palette.groups.count)
		XCTAssertEqual(16, palette.colors.count)

		XCTAssertEqual("Void", palette.colors[0].name)
		XCTAssertEqual("Ash", palette.colors[1].name)
		XCTAssertEqual("Zornskin", palette.colors[8].name)
		XCTAssertEqual("SkyBlue", palette.colors[14].name)
		XCTAssertEqual("CloudBlue", palette.colors[15].name)

		let encoded = try PAL.Coder.ACO().encode(palette)
		let palette2 = try PAL.Palette.Decode(from: encoded, fileExtension: "aco")
		XCTAssertEqual(palette, palette2)
	}
}
