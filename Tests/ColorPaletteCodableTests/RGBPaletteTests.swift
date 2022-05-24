@testable import ColorPaletteCodable
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
		let palette = try PAL.Palette.Decode(from: rgbURL, usingCoder: PAL.Coder.RGB())
		XCTAssertEqual(palette.colors.count, 7)

		XCTAssertEqual(palette.colors[3].name, "Fish and chips")

		//let data = try PAL.Coder.RGB().data(for: palette)
		//try data.write(to: URL(fileURLWithPath: "/tmp/output.txt"))
	}

	func testRGBA() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "basic1alpha", withExtension: "txt"))
		let origData = try Data(contentsOf: rgbaURL)

		// Read in as RGBA
		let palette = try PAL.Palette.Decode(from: rgbaURL, usingCoder: PAL.Coder.RGBA())
		XCTAssertEqual(palette.colors.count, 7)

		// Check some alpha values that they are correctly loaded
		XCTAssertEqual(palette.colors[0].alpha, 0.6666, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[1].alpha, 0.7333, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[1].name, "This is a duck")
		XCTAssertEqual(palette.colors[2].alpha, 0.0705, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[6].alpha, 0.7019, accuracy: 0.0001)

		// Write out as RGBA
		let data = try PAL.Palette.Encode(palette, fileExtension: "rgba")

		// The input and output files should be identical
		let o = String(data: origData, encoding: .utf8)!
		let r = String(data: data, encoding: .utf8)!

		XCTAssertEqual(o, r)
	}

	func testRGBConversion() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "basic1alpha", withExtension: "txt"))
		//let originalText = try String(contentsOf: rgbaURL)

		// Decode from an RGBA file
		let decoder = PAL.Coder.RGBA()
		let palette = try decoder.decode(from: rgbaURL)
		XCTAssertEqual(palette.colors[0].alpha, 0.6666, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[1].alpha, 0.7333, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[2].alpha, 0.0705, accuracy: 0.0001)

		// Encode to an RGB File (which drop the alpha component)
		let encoder = PAL.Coder.RGB()
		let data = try encoder.encode(palette)

		//let encText = String(data: data, encoding: .utf8)!

		// Decode back... the alpha component should be 1
		let palette2 = try decoder.decode(from: data)
		XCTAssertEqual(palette2.colors[0].alpha, 1, accuracy: 0.0001)
		XCTAssertEqual(palette2.colors[1].alpha, 1, accuracy: 0.0001)
		XCTAssertEqual(palette2.colors[2].alpha, 1, accuracy: 0.0001)
	}

	func testAttemptLoadBadFormattedTxtFile() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "bad-coding", withExtension: "txt"))
		XCTAssertThrowsError(try PAL.Coder.RGBA().decode(from: rgbaURL))
	}
}
