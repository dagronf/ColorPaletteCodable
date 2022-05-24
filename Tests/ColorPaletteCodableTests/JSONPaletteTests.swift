@testable import ColorPaletteCodable
import XCTest

class JSONPaletteTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testJSONColorPaletteLoading() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "basic1alpha", withExtension: "txt"))
		let palette = try PAL.Palette.Create(from: rgbaURL, forcedExtension: "rgba")

		// Get json data
		let data = try PAL.Coder.JSON().data(palette)

		// Reload palette
		let rec = try PAL.Coder.JSON().create(from: data)

		XCTAssertEqual(palette, rec)
	}
}
