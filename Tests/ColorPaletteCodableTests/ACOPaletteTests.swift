@testable import ColorPaletteCodable
import XCTest

let aco_resources = [
	"davis-colors-concrete-pigments",
	"Material Palette",
	"454306_iColorpalette",
	"arne-v20-16",
	"Zeldman-v1"
]

final class ACOSwatchesTests: XCTestCase {
	func testWriteReadRoundTripSampleACOFiles() throws {
		let paletteCoder = PAL.Coder.ACO()

		Swift.print("Round-tripping ACO files...'")
		// Loop through all the resource files
		for name in aco_resources {
			let controlACO = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "aco"))

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

	func testACOBasic() throws {
		let acoURL = try XCTUnwrap(Bundle.module.url(forResource: "davis-colors-concrete-pigments", withExtension: "aco"))
		let paletteCoder = PAL.Coder.ACO()

		let aco = try paletteCoder.decode(from: acoURL)
		XCTAssertEqual(59, aco.colors.count)
	}

	func testACOGoogleMaterial() throws {
		let acoURL = try XCTUnwrap(Bundle.module.url(forResource: "Material Palette", withExtension: "aco"))
		let paletteCoder = PAL.Coder.ACO()

		let aco = try paletteCoder.decode(from: acoURL)
		XCTAssertEqual(256, aco.colors.count)

		XCTAssertEqual("Red 500 - Primary", aco.colors[0].name)
		XCTAssertEqual("ffffff", aco.colors[255].name)
	}

	func testLoadV1() throws {
		let acoURL = try XCTUnwrap(Bundle.module.url(forResource: "Zeldman-v1", withExtension: "aco"))
		let paletteCoder = PAL.Coder.ACO()

		let aco = try paletteCoder.decode(from: acoURL)
		XCTAssertEqual(6, aco.colors.count)
	}

	// This file couldn't originally be loaded, as its color name encoding is slightly odd
	func testLoadBrokenNames() throws {

		let acoURL = try XCTUnwrap(Bundle.module.url(forResource: "arne-v20-16", withExtension: "aco"))
		let palette = try PAL.Palette.Decode(from: acoURL)

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
