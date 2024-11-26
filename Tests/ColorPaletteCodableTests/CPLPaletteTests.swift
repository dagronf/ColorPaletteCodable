@testable import ColorPaletteCodable
import XCTest

final class CPLPaletteTests: XCTestCase {

	func testSimple() throws {
		let swatches = try loadResourcePalette(named: "LaserGlow.cpl")
		XCTAssertEqual(5, swatches.colors.count)
	}
}
