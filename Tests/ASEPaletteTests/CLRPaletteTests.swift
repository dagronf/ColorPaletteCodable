@testable import ASEPalette
import XCTest

let clrResources = [
	"apple-ii",
	"DarkMailTopBar"
]

final class CLRPaletteTests: XCTestCase {

	func testWriteReadRoundTripSampleFiles() throws {
		// Loop through all the resource files
		Swift.print("Round-tripping CLR files...'")

		let coder = try XCTUnwrap(ASE.Factory.shared.coder(for: "clr"))

		for name in clrResources {
			let fileURL = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "clr"))

			Swift.print("Validating '\(name)...'")

			// Attempt to load the ase file
			let palette = try coder.load(fileURL: fileURL)

			// Write to a data stream
			let data = try coder.data(palette)

			// Re-create the ase structure from the written data ...
			let reconstitutedPalette = try coder.load(data: data)

			// ... and check equality between the original file and our reconstituted one.
			XCTAssertEqual(palette, reconstitutedPalette)
		}
	}

	func testRealBasic() throws {

		let coder = ASE.Factory.shared.clr

		var palette = ASE.Palette()
		let c1 = try ASE.Color(name: "red", model: ASE.ColorSpace.RGB, colorComponents: [1, 0, 0])
		let c2 = try ASE.Color(name: "green", model: ASE.ColorSpace.RGB, colorComponents: [0, 1, 0])
		let c3 = try ASE.Color(name: "blue", model: ASE.ColorSpace.RGB, colorComponents: [0, 0, 1])
		palette.colors.append(contentsOf: [c1, c2, c3])

		// Encode
		let rawData = try coder.data(for: palette)

		// Decode
		let reconst = try coder.load(data: rawData)

		// Check equal
		XCTAssertEqual(reconst, palette)
	}

	func testRealBasicNSColorListLoad() throws {
		let clrURL = try XCTUnwrap(Bundle.module.url(forResource: "DarkMailTopBar", withExtension: "clr"))
		let coder = ASE.Factory.shared.clr
		let palette = try coder.load(fileURL: clrURL)
		XCTAssertEqual(12, palette.colors.count)
	}

}
