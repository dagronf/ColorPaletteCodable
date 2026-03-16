@testable import ColorPaletteCodable
import XCTest

final class ACBLPaletteTests: XCTestCase {

	func testBasic() throws {
		let swatches = try loadResourcePalette(named: "basic.acbl")

		XCTAssertEqual(0, swatches.groups.count)
		XCTAssertEqual(11, swatches.colors.count)

		XCTAssertEqual(swatches.colors[0].colorSpace, .CMYK)
		XCTAssertEqual(swatches.colors[0].name, "Yellow")
		XCTAssertEqual(swatches.colors[0].colorComponents, [0.0, 0.01, 1.0, 0.0])

		XCTAssertEqual(swatches.colors[6].colorSpace, .CMYK)
		XCTAssertEqual(swatches.colors[6].name, "Rhodamine Red")
		XCTAssertEqual(swatches.colors[6].colorComponents, [0.03, 0.89, 0.0, 0.0])

		XCTAssertEqual(swatches.colors[10].colorSpace, .CMYK)
		XCTAssertEqual(swatches.colors[10].name, "8321")
		XCTAssertEqual(swatches.colors[10].colorComponents, [0.2, 0.0, 0.3, 0.25])
	}
}
