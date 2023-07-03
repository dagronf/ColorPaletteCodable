@testable import ColorPaletteCodable
import XCTest

final class ColorFunctionTests: XCTestCase {

	func testComplementary() throws {
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0, bf: 0)
			let comp1 = try c1.complementary()
			XCTAssertEqual(comp1.colorSpace, .RGB)

			//let hg = CGColor(red: 1, green: 0, blue: 0, alpha: 1).hue()!
			//let ee = CGColor.fromHSB(h: hg.h, s: hg.s, b: hg.b)

			#if os(macOS)
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0, g: 0.991, b: 1))
			#else
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0, g: 1, b: 1))
			#endif
		}
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0.5, bf: 0)
			let comp1 = try c1.complementary()
			XCTAssertEqual(comp1.colorSpace, .RGB)
			#if os(macOS)
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0, g: 0.588, b: 1.0))
			#else
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0, g: 0.5, b: 1.0))
			#endif
		}

		do {
			// https://www.color-hex.com/color/9440bf
			let c1 = try PAL.Color(rgbHexString: "#9340BF")
			let comp1 = try c1.complementary()
			XCTAssertEqual(comp1.colorSpace, .RGB)
			#if os(macOS)
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0.487, g: 0.779, b: 0.317))
			#else
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0.423, g: 0.749, b: 0.25))
			#endif
		}
	}

	func testAnalogousColors() throws {
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0, bf: 0)
			let analogous = try c1.analogous(count: 3, stepSize: 30.0 / 360.0)
			//let nsc = analogous.map { $0.nsColor }
			XCTAssertEqual(analogous.count, 3)
		}
	}
}
