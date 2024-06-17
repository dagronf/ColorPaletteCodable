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
		let c1 = try PAL.Color(rf: 1.0, gf: 0, bf: 0)
		let analogous = try c1.analogous(count: 3, stepSize: 30.0 / 360.0)
		//let nsc = analogous.map { $0.nsColor }
		XCTAssertEqual(analogous.count, 3)
	}

	func testWhite() throws {
		let c1 = try PAL.Color(white: 0.5)
		XCTAssertEqual(.Gray, c1.colorSpace)
		XCTAssertEqual(1, c1.colorComponents.count)
		XCTAssertEqual(0.5, c1.colorComponents[0])

//		let x1 = try XCTUnwrap(c1.cgColor)
//		let c2 = try c1.converted(to: .RGB)
//		let x2 = try XCTUnwrap(c2.cgColor)
//		Swift.print(c2)
	}

	func testPaletteConversion() throws {
		
		let c1 = try PAL.Color(name: "1", colorSpace: .CMYK, colorComponents: [0, 1, 1, 0])
		let c2 = try PAL.Color(name: "2", colorSpace: .CMYK, colorComponents: [0, 0.6, 1, 0])
		let c3 = try PAL.Color(name: "3", colorSpace: .CMYK, colorComponents: [0, 0.3, 1, 0])
		let c4 = try PAL.Color(name: "4", colorSpace: .CMYK, colorComponents: [0, 0.05, 1, 0])
		let c5 = try PAL.Color(name: "5", colorSpace: .CMYK, colorComponents: [0.05, 1, 0, 0])
		let c6 = try PAL.Color(name: "6g", white: 0.3)

		var palette = PAL.Palette(name: "fish", colors: [c1, c2, c3])
		palette.groups.append(PAL.Group(colors: [c4, c5, c6]))
//		let im = try XCTUnwrap(palette.thumbnailImage(size: CGSize(width: 120, height: 120)))

		let converted = try palette.copy(using: .RGB)
		// let cim = try XCTUnwrap(converted.thumbnailImage(size: CGSize(width: 120, height: 120)))
		Swift.print(converted)

		XCTAssertEqual("fish", converted.name)
		XCTAssertEqual(3, converted.colors.count)
		XCTAssertEqual(["1", "2", "3"], converted.colors.map { $0.name })
		XCTAssertEqual(1, converted.groups.count)
		XCTAssertEqual(3, converted.groups[0].colors.count)
		XCTAssertEqual(["4", "5", "6g"], converted.groups[0].colors.map { $0.name })

		XCTAssertEqual([], converted.allColors().filter { $0.colorSpace != .RGB })
	}
}
