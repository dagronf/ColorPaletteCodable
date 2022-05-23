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
		let origData = try Data(contentsOf: rgbURL)

		let palette = try ASE.Factory.shared.load(fileURL: rgbURL, usingExtension: "rgb")
		XCTAssertEqual(palette.colors.count, 7)

		let data = try ASE.Factory.shared.data(palette, fileExtension: "rgb")
		XCTAssertEqual(origData, data)
	}

	func testRGBA() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "basic1alpha", withExtension: "txt"))
		let origData = try Data(contentsOf: rgbaURL)

		// Read in as RGBA
		let palette = try ASE.Factory.shared.load(fileURL: rgbaURL, usingExtension: "rgba")
		XCTAssertEqual(palette.colors.count, 7)

		// Check some alpha values that they are correctly loaded
		XCTAssertEqual(palette.colors[0].alpha, 0.6666, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[1].alpha, 0.7333, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[2].alpha, 0.0705, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[6].alpha, 0.7019, accuracy: 0.0001)

		// Write out as RGBA
		let data = try ASE.Factory.shared.data(palette, fileExtension: "rgba")

		// The input and output files should be identical
		XCTAssertEqual(origData, data)
	}
}
