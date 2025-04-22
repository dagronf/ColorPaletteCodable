@testable import ColorPaletteCodable
import XCTest

final class AFPaletteTests: XCTestCase {

	func testBasicAFPalette() throws {
		let swatches1 = try loadResourcePalette(named: "basicrgb.afpalette")
		XCTAssertEqual("unnamed", swatches1.name)
		XCTAssertEqual(3, swatches1.totalColorCount)

		let swatches2 = try loadResourcePalette(named: "Bulma.io.afpalette")
		XCTAssertEqual("Bulma.io", swatches2.name)
		XCTAssertEqual(17, swatches2.totalColorCount)
	}
}
