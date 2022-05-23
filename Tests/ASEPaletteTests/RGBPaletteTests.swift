@testable import ASEPalette
import XCTest

class RGBPaletteTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testRGB() throws {
		let rgbURL = try XCTUnwrap(Bundle.module.url(forResource: "basic1", withExtension: "txt"))
		let palette = try ASE.Palette.load(fileURL: rgbURL, forcedExtension: "rgb")
		XCTAssertEqual(palette.colors.count, 7)

		let data = try ASE.Coder.RGB().data(for: palette)
		try data.write(to: URL(fileURLWithPath: "/tmp/output.txt"))
	}

	func testRGBA() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "basic1alpha", withExtension: "txt"))
		let origData = try Data(contentsOf: rgbaURL)

		// Read in as RGBA
		let palette = try ASE.Palette.load(fileURL: rgbaURL, forcedExtension: "rgba")
		XCTAssertEqual(palette.colors.count, 7)

		// Check some alpha values that they are correctly loaded
		XCTAssertEqual(palette.colors[0].alpha, 0.6666, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[1].alpha, 0.7333, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[2].alpha, 0.0705, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[6].alpha, 0.7019, accuracy: 0.0001)

		// Write out as RGBA
		let data = try ASE.Palette.data(palette, fileExtension: "rgba")

		// The input and output files should be identical
		XCTAssertEqual(origData, data)
	}

	func testRGBConversion() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "basic1alpha", withExtension: "txt"))

		// Decode from an RGBA file
		let decoder = ASE.Coder.RGBA()
		let palette = try decoder.load(fileURL: rgbaURL)
		XCTAssertEqual(palette.colors[0].alpha, 0.6666, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[1].alpha, 0.7333, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[2].alpha, 0.0705, accuracy: 0.0001)

		// Encode to an RGB File (which drop the alpha component)
		let encoder = ASE.Coder.RGB()
		let data = try encoder.data(for: palette)

		// Decode back... the alpha component should be 1
		let palette2 = try decoder.load(data: data)
		XCTAssertEqual(palette2.colors[0].alpha, 1, accuracy: 0.0001)
		XCTAssertEqual(palette2.colors[1].alpha, 1, accuracy: 0.0001)
		XCTAssertEqual(palette2.colors[2].alpha, 1, accuracy: 0.0001)
	}
}
