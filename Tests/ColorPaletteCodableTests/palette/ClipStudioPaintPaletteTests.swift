@testable import ColorPaletteCodable
import XCTest

final class ClipStudioPaintPaletteTests: XCTestCase {

// Test file broken, incorrent format?
//	func testBasic() throws {
//		let swatches1 = try loadResourcePalette(named: "invalid.cls")
//		XCTAssertEqual("LightGrayish", swatches1.name)
//		XCTAssertEqual(24, swatches1.totalColorCount)
//	}

	func testBasicLoad() throws {
		let swatches1 = try loadResourcePalette(named: "valid-palette.cls")
		XCTAssertEqual(swatches1.format, .clipStudioPaint)
		XCTAssertEqual("LightGrayish", swatches1.name)
		XCTAssertEqual(24, swatches1.totalColorCount)
	}

	func testStandardJapaneseLoad() throws {
		let swatches1 = try loadResourcePalette(named: "001Start-jpn.cls")
		XCTAssertEqual(swatches1.format, .clipStudioPaint)
		XCTAssertEqual("スタートカラーセット", swatches1.name)
		XCTAssertEqual(48, swatches1.totalColorCount)
	}

	func testStandardChineseTraditionalLoad() throws {
		let swatches1 = try loadResourcePalette(named: "001Start-cn-trad.cls")
		XCTAssertEqual(swatches1.format, .clipStudioPaint)
		XCTAssertEqual("開始色板", swatches1.name)
		XCTAssertEqual(48, swatches1.totalColorCount)
	}

	func testStandardEnglishLoad() throws {
		let swatches1 = try loadResourcePalette(named: "MixColorSet-en.cls")
		XCTAssertEqual(swatches1.format, .clipStudioPaint)
		XCTAssertEqual("MixColorSet", swatches1.name)
		XCTAssertEqual(13, swatches1.totalColorCount)
	}
}
