#if canImport(Darwin)

// ZipFoundation fails to compile on linux, so lets ignore it for the moment

@testable import ColorPaletteCodable
import XCTest

final class KritaPaletteTests: XCTestCase {

	func testBasicLoad() throws {
		let palette = try loadResourcePalette(named: "Rose_Pine_3_variants.kpl")
		XCTAssertEqual(palette.format, .krita)
		XCTAssertEqual("Rosé Pine", palette.name)
		XCTAssertEqual(45, palette.totalColorCount)
		XCTAssertEqual(0, palette.groups.count)
	}

	func testBasicLoad2() throws {
		let palette = try loadResourcePalette(named: "blues.kpl")
		XCTAssertEqual(palette.format, .krita)
		XCTAssertEqual(palette.name, "Blues")
		XCTAssertEqual(palette.totalColorCount, 256)
		XCTAssertEqual(palette.groups.count, 0)
	}
}

#endif
