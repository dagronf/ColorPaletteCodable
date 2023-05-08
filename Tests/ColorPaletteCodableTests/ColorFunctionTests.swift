@testable import ColorPaletteCodable
import XCTest

final class ColorFunctionTests: XCTestCase {

	func testComplementary() throws {
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0, bf: 0)
			let comp1 = try c1.complementary()
			XCTAssertEqual(comp1.colorSpace, .RGB)
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0, g: 0.991, b: 1))
		}
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0.5, bf: 0)
			let comp1 = try c1.complementary()
			XCTAssertEqual(comp1.colorSpace, .RGB)
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0, g: 0.588, b: 1.0))
		}

		do {
			// https://www.color-hex.com/color/9440bf
			let c1 = try PAL.Color(rgbHexString: "#9340BF")
			let comp1 = try c1.complementary()
			XCTAssertEqual(comp1.colorSpace, .RGB)
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0.487, g: 0.779, b: 0.317))
		}
	}

	func testAnalogousColors() throws {
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0, bf: 0)
			let analogous = try c1.analogous(count: 3, stepSize: 30.0 / 360.0)
			let ccc = analogous.map { $0.nsColor }
			XCTAssertEqual(analogous.count, 3)
		}
	}
}
