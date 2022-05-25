@testable import ColorPaletteCodable
import XCTest

#if os(macOS)

let clrResources = [
	"apple-ii",
	"DarkMailTopBar",
]

final class CLRPaletteTests: XCTestCase {
	func testWriteReadRoundTripSampleFiles() throws {
		// Loop through all the resource files
		Swift.print("Round-tripping CLR files...'")
		
		let coder = try XCTUnwrap(PAL.Palette.coder(for: "clr"))
		
		for name in clrResources {
			let fileURL = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "clr"))
			
			Swift.print("Validating '\(name)...'")
			
			// Attempt to load the ase file
			let palette = try coder.decode(from: fileURL)
			
			// Write to a data stream
			let data = try coder.encode(palette)
			
			// Re-create the ase structure from the written data ...
			let reconstitutedPalette = try coder.decode(from: data)
			
			// ... and check equality between the original file and our reconstituted one.
			XCTAssertEqual(palette, reconstitutedPalette)
		}
	}
	
	func testRealBasic() throws {
		let coder = PAL.Coder.CLR()
		
		var palette = PAL.Palette()
		let c1 = try PAL.Color(name: "red", colorSpace: PAL.ColorSpace.RGB, colorComponents: [1, 0, 0])
		let c2 = try PAL.Color(name: "green", colorSpace: PAL.ColorSpace.RGB, colorComponents: [0, 1, 0])
		let c3 = try PAL.Color(name: "blue", colorSpace: PAL.ColorSpace.RGB, colorComponents: [0, 0, 1])
		palette.colors.append(contentsOf: [c1, c2, c3])
		
		// Encode
		let rawData = try coder.encode(palette)
		
		// Decode
		let reconst = try coder.decode(from: rawData)
		
		// Check equal
		XCTAssertEqual(reconst, palette)
	}
	
	func testRealBasicNSColorListLoad() throws {
		let coder = PAL.Coder.CLR()
		
		let clrURL = try XCTUnwrap(Bundle.module.url(forResource: "DarkMailTopBar", withExtension: "clr"))

		let palette = try coder.decode(from: clrURL)
		XCTAssertEqual(12, palette.colors.count)
	}
}

#endif
