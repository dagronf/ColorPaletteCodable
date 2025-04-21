@testable import ColorPaletteCodable
import XCTest

import Foundation

#if canImport(Darwin)

class SwatchBookerTests: XCTestCase {

	func testSampleSBZ() throws {
		let palette = try loadResourcePalette(named: "sample.sbz")
		XCTAssertEqual("Sample swatch book", palette.name)
		XCTAssertEqual(47, palette.totalColorCount)
		XCTAssertEqual(0, palette.groups.count)

		XCTAssertEqual(20, palette.colors.filter({ $0.colorSpace == .RGB }).count)
		XCTAssertEqual(10, palette.colors.filter({ $0.colorSpace == .CMYK }).count)
		XCTAssertEqual(10, palette.colors.filter({ $0.colorSpace == .Gray }).count)
		XCTAssertEqual(7, palette.colors.filter({ $0.colorSpace == .LAB }).count)
	}
}

#endif
