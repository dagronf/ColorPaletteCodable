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
		let palette = try PAL.Palette.Create(from: rgbaURL, usingCoder: PAL.Coder.RGBA())

		// Get json data
		let data = try PAL.Coder.JSON().data(palette)

		// Reload palette
		let rec = try PAL.Coder.JSON().create(from: data)

		XCTAssertEqual(palette, rec)
	}

	func testJSONColorPaletteLoading2() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "24 colour palettes", withExtension: "ase"))
		let palette = try PAL.Palette.Create(from: rgbaURL)

		// Get json data
		let data = try PAL.Coder.JSON().data(palette)
		//try data.write(to: URL(fileURLWithPath: "/tmp/encodedgroups.jsoncolorpalette"))

		// Reload palette
		let rec = try PAL.Coder.JSON().create(from: data)

		XCTAssertEqual(palette, rec)
	}
}
