@testable import ColorPaletteCodable
import XCTest

final class ColorFunctionTests: XCTestCase {

	let outputFolder = try! testResultsContainer.subfolder(with: "color-function")

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

			let pal = PAL.Palette(colors: [c1, comp1])
			try outputFolder.write(pal, coder: PAL.Coder.ASE(), filename: "complementary-test-1.ase")
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

			let pal = PAL.Palette(colors: [c1, comp1])
			try outputFolder.write(pal, coder: PAL.Coder.ASE(), filename: "complementary-test-2.ase")
		}

		do {
			// https://www.color-hex.com/color/9440bf
			let c1 = try PAL.Color(rgbaHexString: "#9340BF")
			let comp1 = try c1.complementary()
			XCTAssertEqual(comp1.colorSpace, .RGB)
			#if os(macOS)
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0.487, g: 0.779, b: 0.317))
			#else
			XCTAssertEqual(try comp1.rgbValues(), PAL.Color.RGB(r: 0.423, g: 0.749, b: 0.25))
			#endif

			let pal = PAL.Palette(colors: [c1, comp1])
			try outputFolder.write(pal, coder: PAL.Coder.ASE(), filename: "complementary-test-3.ase")
		}
	}

	func testAnalogousColors() throws {
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0, bf: 0)
			let analogous1 = try c1.analogous(count: 3, stepSize: 30.0 / 360.0)
			XCTAssertEqual(analogous1.count, 3)
			try outputFolder.write(analogous1, coder: PAL.Coder.ASE(), filename: "analogous-3step.ase")
		}
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0, bf: 0)
			let analogous1 = try c1.analogous(count: 5, stepSize: 30.0 / 360.0)
			XCTAssertEqual(analogous1.count, 5)
			try outputFolder.write(analogous1, coder: PAL.Coder.ASE(), filename: "analogous-5step-1.ase")
		}
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0, bf: 0)
			let analogous1 = try c1.analogous(count: 5, stepSize: 10.0 / 360.0)
			XCTAssertEqual(analogous1.count, 5)
			try outputFolder.write(analogous1, coder: PAL.Coder.ASE(), filename: "analogous-5step-2.ase")
		}
	}

	func testMonochromaticColors() throws {
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0, bf: 0)
			let mono1 = try c1.monochromatic(style: .saturation, count: 4, step: -0.2)
			XCTAssertEqual(mono1.count, 4)
			try outputFolder.write(mono1, coder: PAL.Coder.RGB(), filename: "monochromatic-3step-0_1-sat.rgb")
		}
		do {
			let c1 = try PAL.Color(rf: 1.0, gf: 0, bf: 0)
			let mono1 = try c1.monochromatic(style: .brightness, count: 4, step: -0.2)
			XCTAssertEqual(mono1.count, 4)
			try outputFolder.write(mono1, coder: PAL.Coder.RGB(), filename: "monochromatic-3step-0_1-bri.rgb")
		}
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
		
		let c1 = PAL.Color.cmyk(name: "1", 0, 1, 1, 0)
		let c2 = PAL.Color.cmyk(name: "2", 0, 0.6, 1, 0)
		let c3 = PAL.Color.cmyk(name: "3", 0, 0.3, 1, 0)
		let c4 = PAL.Color.cmyk(name: "4", 0, 0.05, 1, 0)
		let c5 = PAL.Color.cmyk(name: "5", 0.05, 1, 0, 0)
		let c6 = PAL.Color.gray(name: "6g", 0.3)

		var palette = PAL.Palette(name: "fish", colors: [c1, c2, c3])
		palette.groups.append(PAL.Group(colors: [c4, c5, c6]))
		//let im = try XCTUnwrap(palette.thumbnailImage(size: CGSize(width: 120, height: 120)))

		let converted = try palette.copy(using: .RGB)
		//let cim = try XCTUnwrap(converted.thumbnailImage(size: CGSize(width: 120, height: 120)))

		XCTAssertEqual("fish", converted.name)
		XCTAssertEqual(3, converted.colors.count)
		XCTAssertEqual(["1", "2", "3"], converted.colors.map { $0.name })
		XCTAssertEqual(1, converted.groups.count)
		XCTAssertEqual(3, converted.groups[0].colors.count)
		XCTAssertEqual(["4", "5", "6g"], converted.groups[0].colors.map { $0.name })

		XCTAssertEqual([], converted.allColors().filter { $0.colorSpace != .RGB })
	}

	func testHSB() throws {
		let c1 = PAL.Color.hsb360(120, 100, 100)

		XCTAssertEqual(0, c1._r, accuracy: 0.05)
		XCTAssertEqual(1, c1._g, accuracy: 0.05)
		XCTAssertEqual(0, c1._b, accuracy: 0.05)

//		#if canImport(CoreGraphics)
//		let i1 = try XCTUnwrap(c1.cgColor)
//		Swift.print(i1)
//		#endif
	}
}
