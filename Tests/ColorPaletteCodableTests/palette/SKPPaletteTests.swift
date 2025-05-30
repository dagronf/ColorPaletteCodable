@testable import ColorPaletteCodable
import XCTest

import Foundation

class SKPPaletteTests: XCTestCase {
	func testBasicSKP() throws {
		let data = try loadResourceData(named: "Ubuntu_colors.skp")
		let palette = try PAL.Coder.SKP().decode(from: data)
		XCTAssertEqual(palette.name, "Ubuntu colors")
		XCTAssertEqual(palette.colors.count, 9)
	}

	func testBasicSKP2() throws {
		let data = try loadResourceData(named: "Lible_Colors.skp")
		let palette = try PAL.Coder.SKP().decode(from: data)
		XCTAssertEqual(palette.name, "Lible Colors")
		XCTAssertEqual(palette.colors.count, 16)
	}

	func testBasicEncode() throws {

		let colors: [PAL.Color] = [
			rgbf(1, 1, 1, name: "white"),
			rgbf(0, 0, 0, name: "black"),
			rgbf(1, 0, 0, name: "red"),
			rgbf(0, 0.5, 0, name: "green"),
			rgbf(0, 0, 0.8, name: "blue"),
			rgbf(0.1, 0.2, 0.3, 0.4, name: "alpha"),
		]
		let palette = PAL.Palette(colors: colors, name: "Sample")

		let result = try PAL.Coder.SKP().encode(palette)
		//try result.write(to: URL(fileURLWithPath: "/tmp/output.skp"))

		let str = try XCTUnwrap(String(data: result, encoding: .utf8))
		XCTAssertNotNil(str.range(of: "color(['RGB', [0.1, 0.2, 0.3], 0.4, 'alpha'])"))
		XCTAssertNotNil(str.range(of: "color(['RGB', [1.0, 0.0, 0.0], 1.0, 'red'])"))
		XCTAssertNotNil(str.range(of: "set_name('Sample')"))
	}
}
