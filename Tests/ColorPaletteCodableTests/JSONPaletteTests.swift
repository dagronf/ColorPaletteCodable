@testable import ColorPaletteCodable
import XCTest

let testFiles = [
	"encoded",
	"groups"
]

class JSONPaletteTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testHasJSONFileFormatChanged() throws {
		Swift.print("Round-tripping jsoncolorpalette files...'")
		try testFiles.forEach { name in
			Swift.print("  Validating '\(name).jsoncolorpalette'...")
			let jsonURL = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "jsoncolorpalette"))
			let palette = try XCTUnwrap(try? PAL.Palette.Decode(from: jsonURL))
			let data = try PAL.Coder.JSON().encode(palette)
			let decoded = try PAL.Coder.JSON().decode(from: data)
			XCTAssertEqual(palette, decoded)
		}
		Swift.print("...done")
	}

	func testJSONColorPaletteLoading() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "basic1alpha", withExtension: "txt"))
		let palette = try PAL.Palette.Decode(from: rgbaURL, usingCoder: PAL.Coder.RGBA())

		// Get json data
		let data = try PAL.Coder.JSON().encode(palette)

		// Reload palette
		let rec = try PAL.Coder.JSON().decode(from: data)

		XCTAssertEqual(palette, rec)
	}

	func testJSONColorPaletteLoading2() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "24 colour palettes", withExtension: "ase"))
		let palette = try PAL.Palette.Decode(from: rgbaURL)

		// Get json data
		let data = try PAL.Coder.JSON(prettyPrint: true).encode(palette)
		//try data.write(to: URL(fileURLWithPath: "/tmp/encodedgroups.jsoncolorpalette"))

		// Reload palette
		let rec = try PAL.Coder.JSON().decode(from: data)

		XCTAssertEqual(palette, rec)
	}
}
