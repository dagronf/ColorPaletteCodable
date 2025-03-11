@testable import ColorPaletteCodable
import XCTest

#if os(macOS)

let clrResources = [
	"apple-ii.clr",
	"DarkMailTopBar.clr",
]

final class CLRPaletteTests: XCTestCase {
	func testWriteReadRoundTripSampleFiles() throws {
		// Loop through all the resource files
		Swift.print("Round-tripping CLR files...'")
		
		let coder = try XCTUnwrap(PAL.Palette.firstCoder(for: "clr"))
		XCTAssertEqual(coder.name, PAL.Coder.CLR().name)

		for name in clrResources {
			Swift.print("Validating '\(name)...'")

			// Try to load
			let palette = try loadResourcePalette(named: name)

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
		let c1 = try PAL.Color(colorSpace: PAL.ColorSpace.RGB, colorComponents: [1, 0, 0], name: "red")
		let c2 = try PAL.Color(colorSpace: PAL.ColorSpace.RGB, colorComponents: [0, 1, 0], name: "green")
		let c3 = try PAL.Color(colorSpace: PAL.ColorSpace.RGB, colorComponents: [0, 0, 1], name: "blue")
		palette.colors.append(contentsOf: [c1, c2, c3])
		
		// Encode
		let rawData = try coder.encode(palette)
		
		// Decode
		let reconst = try coder.decode(from: rawData)
		
		// Check equal
		XCTAssertEqual(reconst, palette)
	}
	
	func testRealBasicNSColorListLoad() throws {
		let palette = try loadResourcePalette(named: "DarkMailTopBar.clr", using: PAL.Coder.CLR())
		XCTAssertEqual(12, palette.colors.count)
		XCTAssertEqual("0 0", palette.colors[0].name)
		XCTAssertEqual("#ff1b19ff", try palette.colors[0].hexRGBA(hashmark: true))
		XCTAssertEqual("0 1", palette.colors[1].name)
		XCTAssertEqual("#fe7f00ff", try palette.colors[1].hexRGBA(hashmark: true))
		XCTAssertEqual("0 2", palette.colors[2].name)
		XCTAssertEqual("#e3e300", try palette.colors[2].hexRGB(hashmark: true))
	}
}

#endif
