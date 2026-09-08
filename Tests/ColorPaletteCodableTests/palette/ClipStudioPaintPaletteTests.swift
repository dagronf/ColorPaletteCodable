@testable import ColorPaletteCodable
import XCTest

// Testing - https://stepswitcher.neocities.org/clsview

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
		let palette = try loadResourcePalette(named: "MixColorSet-en.cls")
		XCTAssertEqual(palette.format, .clipStudioPaint)
		XCTAssertEqual("MixColorSet", palette.name)
		XCTAssertEqual(13, palette.totalColorCount)

		// RGB colors gathered from https://stepswitcher.neocities.org/clsview

		let elements: [String] = [
			"#FF283CFF",
			"#FF9C35FF",
			"#FFF752FF",
			"#55E74EFF",
			"#006172FF",
			"#2A74FFFF",
			"#23D8FFFF",
			"#8C34FFFF",
			"#FF78AAFF",
			"#835117FF",
			"#FFCCC2FF"
		]

		try elements.enumerated().forEach {
			XCTAssertEqual($0.element, try palette.colors[$0.offset].hexRGBA(hashmark: true, uppercase: true))
		}
	}
}
