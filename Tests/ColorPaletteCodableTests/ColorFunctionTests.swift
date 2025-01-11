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

	func testOkLab() throws {

		let c1 = Vec3<Float32>(0, 0, 1)
		let c2 = Vec3<Float32>(1, 1, 0)

		let x1 = OkLab.mix(c1, c2, t: 0)
		XCTAssertEqual(c1.x, x1.x, accuracy: 0.00001)
		XCTAssertEqual(c1.y, x1.y, accuracy: 0.00001)
		XCTAssertEqual(c1.z, x1.z, accuracy: 0.00001)

		let x2 = OkLab.mix(c1, c2, t: 1)
		XCTAssertEqual(c2.x, x2.x, accuracy: 0.00001)
		XCTAssertEqual(c2.y, x2.y, accuracy: 0.00001)
		XCTAssertEqual(c2.z, x2.z, accuracy: 0.00001)

		let x3 = OkLab.mix(c1, c2, t: 0.5)
		XCTAssertEqual(0.42255, x3.x, accuracy: 0.00001)
		XCTAssertEqual(0.67237, x3.y, accuracy: 0.00001)
		XCTAssertEqual(0.78054, x3.z, accuracy: 0.00001)

		do {
			// oklab mixing
			let p1 = try OkLab.palette(x1, x2, steps: 10)
			try outputFolder.write(p1, coder: PAL.Coder.GIMP(), filename: "oklab-mixing-basic.gpl")

#if canImport(CoreGraphics)
			// Simple srgb linear interpolation
			let p2 = try PAL.Palette(
				firstColor: CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1),
				lastColor: CGColor(srgbRed: 1, green: 1, blue: 0, alpha: 1),
				count: 10
			)
			try outputFolder.write(p2, coder: PAL.Coder.GIMP(), filename: "oklab-srgb-mixing.gpl")
#endif
		}

		do {
			// Map two PAL colors to a palette mixing with OkLab
			let c1 = PAL.Color.blue
			let c2 = PAL.Color.yellow
			let p1 = try OkLab.palette(c1, c2, steps: 10)
			try outputFolder.write(p1, coder: PAL.Coder.GIMP(), filename: "oklab-pal-color-mixing.gpl")
		}

		do {
			let c1 = try PAL.Color(r255: 185, g255: 27, b255: 77)
			let c2 = try PAL.Color(r255: 9, g255: 247, b255: 177)
			let p1 = try OkLab.palette(c1, c2, steps: 20)
			try outputFolder.write(p1, coder: PAL.Coder.GIMP(), filename: "oklab-mix-palette-oklab.gpl")

			let p2 = try PAL.Palette(firstColor: c1, lastColor: c2, count: 20)
			try outputFolder.write(p2, coder: PAL.Coder.GIMP(), filename: "oklab-mix-palette-rgb.gpl")
		}
	}

	func testApplyOnTopOf() throws {
		let c1 = try PAL.Color(rf: 0, gf: 1, bf: 0, af: 0.5)
		let c2 = try PAL.Color(rf: 1, gf: 0, bf: 0, af: 0.5)

		let c3 = try c2.applyOnTopOf(c1)
		Swift.print(c3)
		XCTAssertEqual(0.66666, c3.colorComponents[0], accuracy: 0.00001)
		XCTAssertEqual(0.33333, c3.colorComponents[1], accuracy: 0.00001)
		XCTAssertEqual(0.00000, c3.colorComponents[2], accuracy: 0.00001)
		XCTAssertEqual(0.75, c3.alpha, accuracy: 0.00001)
	}

	func testAdjustBrightness() throws {

		let c1 = try PAL.Color(rf: 0.5, gf: 0, bf: 0)

		do {
			let colors = try stride(from: 0.0, through: -1.0, by: -0.1).map {
				try c1.adjustBrightness(by: $0)
			}

			let p = PAL.Palette(colors: colors)
			try outputFolder.write(p, coder: PAL.Coder.GIMP(), filename: "darken-testing.gpl")
		}

		do {
			let colors = try stride(from: 0.0, through: 1.0, by: 0.1).map {
				try c1.adjustBrightness(by: $0)
			}

			let p = PAL.Palette(colors: colors)
			try outputFolder.write(p, coder: PAL.Coder.GIMP(), filename: "lighter-testing.gpl")
		}
	}

	func testContrastingTextColor() throws {
		do {
			let c1 = PAL.Color.yellow
			let c11 = try c1.contrastingTextColor()
			XCTAssertEqual(c11, .black)
		}
		do {
			let c1 = try PAL.Color(r255: 0, g255: 0, b255: 100)
			let c11 = try c1.contrastingTextColor()
			XCTAssertEqual(c11, .white)
		}
	}
}
