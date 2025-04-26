@testable import ColorPaletteCodable
import XCTest

final class JCWPaletteTests: XCTestCase {
	func testJCWRead() throws {
		let swatches = try loadResourcePalette(named: "wikicolorlist.jcw")
		XCTAssertEqual(swatches.format, .xara)
		XCTAssertEqual(swatches.colors.count, 723)
	}
}
