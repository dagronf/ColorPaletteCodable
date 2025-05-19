@testable import ColorPaletteCodable
import XCTest

@testable import BytesParser

let testResultsContainer = try! TestFilesContainer(named: "ColorPaletteCodableTests")

final class CommonTests: XCTestCase {

	func testSimpleColorspaceConversion() throws {

		let rgb = rgbf(1, 0, 0)

		let cmyk = try rgb.converted(to: .CMYK)
		XCTAssertEqual(cmyk.colorSpace, .CMYK)
		XCTAssertEqual(cmyk.colorComponents.count, 4)

		// Make sure we don't barf if converting to the same colorspace (some coders rely on it)
		let converted = try rgb.converted(to: .RGB)
		XCTAssertEqual(converted.colorSpace, .RGB)
	}

	func testAutoDetectFile() throws {
		let aseFile = try XCTUnwrap(Bundle.module.url(forResource: "wisteric-17", withExtension: "ase"))
		let acoFile = try XCTUnwrap(Bundle.module.url(forResource: "Material Palette", withExtension: "aco"))
		let clrFile = try XCTUnwrap(Bundle.module.url(forResource: "DarkMailTopBar", withExtension: "clr"))
		let txtFile = try XCTUnwrap(Bundle.module.url(forResource: "basic1", withExtension: "txt"))

		// Load from an ase file
		let p1 = try PAL.Palette.Decode(from: aseFile)
		XCTAssertEqual(p1.colors.count, 17)

		// Load from an aco file
		let p2 = try PAL.Palette.Decode(from: acoFile)
		XCTAssertEqual(p2.colors.count, 256)

		#if os(macOS)
		// Load from a clr file
		let p3 = try PAL.Palette.Decode(from: clrFile)
		XCTAssertEqual(p3.colors.count, 12)
		#else
		// NSColorList not supported on ios/tvos. Check that we throw correctly
		XCTAssertThrowsError(try PAL.Palette.Decode(from: clrFile))
		#endif

		// The RGB format uses .txt extension, so to load it we need to overload the extension
		let p4 = try PAL.Palette.Decode(from: txtFile, usingCoder: PAL.Coder.RGB())
		XCTAssertEqual(p4.colors.count, 7)
	}

	func testColors() throws {
		let c1 = rgbf(1, 0, 0, 0.5)
		let c2 = cmykf(1, 1, 0, 0, 0.5)
		let c3 = grayf(0.5)

		XCTAssertEqual(c1.colorSpace, .RGB)
		XCTAssertEqual(c2.colorSpace, .CMYK)
		XCTAssertEqual(c3.colorSpace, .Gray)

		let palette = PAL.Palette(colors: [c1, c2, c3])

		// This will trip off the alpha components here
		let aseData = try PAL.Coder.ASE().encode(palette)

		// Reload from the ase data
		let reloaded = try PAL.Coder.ASE().decode(from: aseData)

		XCTAssertEqual(1.0, reloaded.colors[0].alpha)
		XCTAssertEqual(.RGB, reloaded.colors[0].colorSpace)
		XCTAssertEqual(1.0, reloaded.colors[1].alpha)
		XCTAssertEqual(.CMYK, reloaded.colors[1].colorSpace)
		XCTAssertEqual(1.0, reloaded.colors[2].alpha)
		XCTAssertEqual(.Gray, reloaded.colors[2].colorSpace)
	}


	func testCMKYRBGNaiveConversions() throws {

		let c1 = NaiveConversions.RGB2CMYK(PAL.Color.RGB(rf: 139.0 / 255.0, gf: 0, bf: 22.0 / 255.0))
		XCTAssertEqual(c1, PAL.Color.CMYK(cf: 0, mf: 1, yf: 0.84, kf: 0.45))

		let r1 = NaiveConversions.CMYK2RGB(PAL.Color.CMYK(cf: 0, mf: 1, yf: 0.84, kf: 0.45))
		XCTAssertEqual(r1.rf, 139.0 / 255.0, accuracy: 0.01)
		XCTAssertEqual(r1.gf, 0, accuracy: 0.01)
		XCTAssertEqual(r1.bf, 22.0 / 255.0, accuracy: 0.01)

		let c2 = NaiveConversions.RGB2CMYK(PAL.Color.RGB(rf: 110 / 255.0, gf: 195 / 255.0, bf: 201 / 255.0))
		XCTAssertEqual(c2.cf, 0.45, accuracy: 0.01)
		XCTAssertEqual(c2.mf, 0.03, accuracy: 0.01)
		XCTAssertEqual(c2.yf, 0.0, accuracy: 0.01)
		XCTAssertEqual(c2.kf, 0.21, accuracy: 0.01)

		let r2 = NaiveConversions.CMYK2RGB(PAL.Color.CMYK(cf: 0.45, mf: 0.03, yf: 0.0, kf: 0.21))
		XCTAssertEqual(r2.rf, 110 / 255.0, accuracy: 0.01)
		XCTAssertEqual(r2.gf, 195 / 255.0, accuracy: 0.01)
		XCTAssertEqual(r2.bf, 201 / 255.0, accuracy: 0.01)

		let c3 = NaiveConversions.RGB2CMYK(PAL.Color.RGB(rf: 0, gf: 0, bf: 1))
		XCTAssertEqual(c3.cf, 1, accuracy: 0.01)
		XCTAssertEqual(c3.mf, 1, accuracy: 0.01)
		XCTAssertEqual(c3.yf, 0, accuracy: 0.01)
		XCTAssertEqual(c3.kf, 0, accuracy: 0.01)

		let r3 = NaiveConversions.CMYK2RGB(PAL.Color.CMYK(cf: 1, mf: 1, yf: 0, kf: 0))
		XCTAssertEqual(r3.rf, 0, accuracy: 0.01)
		XCTAssertEqual(r3.gf, 0, accuracy: 0.01)
		XCTAssertEqual(r3.bf, 1, accuracy: 0.01)
	}

	func testDefaultColors() throws {
		let r1 = PAL.Color.red
		XCTAssertEqual(r1.colorSpace, .RGB)
		let rc = try r1.rgb()
		XCTAssertEqual(rc.rf, 1, accuracy: 0.001)
		XCTAssertEqual(rc.gf, 0, accuracy: 0.001)
		XCTAssertEqual(rc.bf, 0, accuracy: 0.001)
		XCTAssertEqual(r1.alpha, 1, accuracy: 0.001)

		#if canImport(CoreGraphics)
		let rx = r1.cgColor
		XCTAssertNotNil(rx)
		#endif

		let c1 = PAL.Color.cyan
		XCTAssertEqual(c1.colorSpace, .CMYK)
		XCTAssertEqual(try c1.c(), 1, accuracy: 0.001)
		XCTAssertEqual(try c1.m(), 0, accuracy: 0.001)
		XCTAssertEqual(try c1.y(), 0, accuracy: 0.001)
		XCTAssertEqual(try c1.k(), 0, accuracy: 0.001)
		XCTAssertEqual(c1.alpha, 1, accuracy: 0.001)

		#if canImport(CoreGraphics)
		XCTAssertEqual(PAL.ColorSpace.CMYK, c1.colorSpace)
		let cr = try c1.rgb()
		XCTAssertEqual(cr.rf, 0, accuracy: 0.001)
		XCTAssertEqual(cr.gf, 0.640, accuracy: 0.001)
		XCTAssertEqual(cr.bf, 0.855, accuracy: 0.001)
		#endif
	}

	func testHSB() throws {
		do {
			#if os(macOS)
			// random device rgb color

			let r1 = CGFloat.random(in: 0...1)
			let g1 = CGFloat.random(in: 0...1)
			let b1 = CGFloat.random(in: 0...1)

			// convert to hsb using NSColor
			let c = NSColor(deviceRed: r1, green: g1, blue: b1, alpha: 1)
			let h1 = c.hueComponent
			let s1 = c.saturationComponent
			let v1 = c.brightnessComponent

			// convert to hsb using routine
			let hsb1 = RGB_to_HSB(r: r1, g: g1, b: b1)

			// Verify our routine matches the NSColor routines
			XCTAssertEqual(h1, hsb1.h, accuracy: 0.00001)
			XCTAssertEqual(s1, hsb1.s, accuracy: 0.00001)
			XCTAssertEqual(v1, hsb1.b, accuracy: 0.00001)

			// Verify our routine reverses correctly
			let rgb2 = HSB_to_RGB(h: h1, s: s1, b: v1)
			XCTAssertEqual(r1, rgb2.r, accuracy: 0.00001)
			XCTAssertEqual(g1, rgb2.g, accuracy: 0.00001)
			XCTAssertEqual(b1, rgb2.b, accuracy: 0.00001)

			#endif
		}
		do {
			let color = PAL.Color(r255: 0, g255: 255, b255: 0)
			let hsb1 = try color.hsb()
			XCTAssertEqual(hsb1.hf, Double(0.3333), accuracy: 0.0001)
			XCTAssertEqual(hsb1.sf, Double(1))
			XCTAssertEqual(hsb1.bf, Double(1))
		}
		do {
			let color = PAL.Color(r255: 50, g255: 216, b255: 164)
			let hsb1 = try color.hsb()
			XCTAssertEqual(hsb1.hf, 161.2 / 360.0, accuracy: 0.0001)	// 0...360
			XCTAssertEqual(hsb1.sf, 76.85 / 100.0, accuracy: 0.0001)	// 0...100
			XCTAssertEqual(hsb1.bf, 84.71 / 100.0, accuracy: 0.0001)	// 0...100
		}
	}

	func testUnitWrapped() throws {
		XCTAssertEqual(0, (0).wrappingToUnitValue())
		XCTAssertEqual(0.4, (1.4).wrappingToUnitValue(), accuracy: 0.0001)
		XCTAssertEqual(0.8, (6.8).wrappingToUnitValue(), accuracy: 0.0001)
		XCTAssertEqual(0.6, (-0.4).wrappingToUnitValue(), accuracy: 0.0001)
		XCTAssertEqual(0.6, (-10.4).wrappingToUnitValue(), accuracy: 0.0001)
	}

	func testUnitWrapped2() throws {
		do {
			struct S: Codable, Equatable {
				let s: String
				let v: UnitValue<Double>
			}

			let s1 = S(s: "testing1", v: (0.85).unitValue)
			let d1 = try JSONEncoder().encode(s1)
			let _ = try XCTUnwrap(String(data: d1, encoding: .utf8))
			let s11 = try JSONDecoder().decode(S.self, from: d1)
			XCTAssertEqual("testing1", s11.s)
			XCTAssertEqual(0.85, s11.v.value)
			XCTAssertEqual(s1, s11)
		}

		do {
			struct S: Codable, Equatable {
				let s: String
				@UnitClamped var v: Double
			}

			let s1 = S(s: "testing1", v: 0.85)
			let d1 = try JSONEncoder().encode(s1)
			let _ = try XCTUnwrap(String(data: d1, encoding: .utf8))
			let s11 = try JSONDecoder().decode(S.self, from: d1)
			XCTAssertEqual("testing1", s11.s)
			XCTAssertEqual(0.85, s11.v, accuracy: 0.0001)
			XCTAssertEqual(s1, s11)
		}
	}

	func testCSSColorGeneration() throws {
		let color = PAL.Color(r255: 50, g255: 216, b255: 164)
		XCTAssertEqual("rgba(50, 216, 164, 1.0)", try color.css())
		XCTAssertEqual("rgb(50, 216, 164)", try color.css(includeAlpha: false))
	}

	func testXMLStringEncoding() throws {
		let unescapedString = #"This is a test & <example> "string" with 'special' characters."#
		let enc = unescapedString.xmlEscaped()

		let expected = "This is a test &amp; &lt;example&gt; &quot;string&quot; with &apos;special&apos; characters."
		XCTAssertEqual(expected, enc)

		let dec = enc.xmlDecoded()
		XCTAssertEqual(unescapedString, dec)
	}

	func testHexDecode() throws {
		do {
			let c1 = try PAL.Color(rgbHexString: "B0C4DEFF", format: .rgba)
			XCTAssertEqual(_p2f(0xB0), c1.colorComponents[0], accuracy: 0.000001)
			XCTAssertEqual(_p2f(0xC4), c1.colorComponents[1], accuracy: 0.000001)
			XCTAssertEqual(_p2f(0xDE), c1.colorComponents[2], accuracy: 0.000001)
			XCTAssertEqual(1.0, c1.alpha, accuracy: 0.000001)
		}
		do {
			let c1 = try PAL.Color(rgbHexString: "B0C4DEFF", format: .argb)
			XCTAssertEqual(_p2f(0xC4), c1.colorComponents[0], accuracy: 0.000001)
			XCTAssertEqual(_p2f(0xDE), c1.colorComponents[1], accuracy: 0.000001)
			XCTAssertEqual(_p2f(0xFF), c1.colorComponents[2], accuracy: 0.000001)
			XCTAssertEqual(_p2f(0xB0), c1.alpha, accuracy: 0.000001)
		}

		do {
			let c1 = try PAL.Color(rgbHexString: "#FFFFF0", format: .argb)
			XCTAssertEqual(1.0, c1.colorComponents[0], accuracy: 0.000001)
			XCTAssertEqual(1.0, c1.colorComponents[1], accuracy: 0.000001)
			XCTAssertEqual(_p2f(0xF0), c1.colorComponents[2], accuracy: 0.000001)
			XCTAssertEqual(1.0, c1.alpha, accuracy: 0.000001)
		}

		do {
			let c2 = try PAL.Color(rgbHexString: "#1122FE", format: .rgba, name: "c2")
			XCTAssertEqual(c2.colorSpace, .RGB)
			XCTAssertEqual(c2.colorComponents.count, 3)
			XCTAssertEqual(c2.colorComponents[0], _p2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[1], _p2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[2], _p2f(0xFE), accuracy: 0.00001)
		}

		do {
			let c3 = try PAL.Color(rgbHexString: "0x1122FE", format: .rgba, name: "c3")
			XCTAssertEqual(c3.colorSpace, .RGB)
			XCTAssertEqual(c3.colorComponents.count, 3)
			XCTAssertEqual(c3.colorComponents[0], _p2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c3.colorComponents[1], _p2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c3.colorComponents[2], _p2f(0xFE), accuracy: 0.00001)
		}

		do {
			let c1 = try PAL.Color(rgbHexString: "0x1122FE", format: .rgba, name: "c1")
			XCTAssertEqual(c1.colorSpace, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3)
			XCTAssertEqual(c1.colorComponents[0], _p2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], _p2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], _p2f(0xFE), accuracy: 0.00001)
			XCTAssertEqual(c1.alpha, 1.0, accuracy: 0.00001)

			let c2 = try PAL.Color(rgbHexString: "0xBB1122FE", format: .argb, name: "c2")
			XCTAssertEqual(c2.colorSpace, .RGB)
			XCTAssertEqual(c2.colorComponents.count, 3)
			XCTAssertEqual(c2.colorComponents[0], _p2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[1], _p2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[2], _p2f(0xFE), accuracy: 0.00001)
			XCTAssertEqual(c2.alpha, _p2f(0xBB), accuracy: 0.00001)
		}

		do {
			let c1 = try PAL.Color(rgbHexString: "#BB1122FE", format: .bgra, name: "c1")
			XCTAssertEqual(c1.colorSpace, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3)
			XCTAssertEqual(c1.colorComponents[0], _p2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], _p2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], _p2f(0xBB), accuracy: 0.00001)
			XCTAssertEqual(c1.alpha, _p2f(0xFE), accuracy: 0.00001)

			let c2 = try PAL.Color(rgbHexString: "#BB1122", format: .bgra, name: "c1")
			XCTAssertEqual(c2.colorSpace, .RGB)
			XCTAssertEqual(c2.colorComponents.count, 3)
			XCTAssertEqual(c2.colorComponents[0], _p2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[1], _p2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[2], _p2f(0xBB), accuracy: 0.00001)
			XCTAssertEqual(c2.alpha, 1.0, accuracy: 0.00001)
		}

		do {
			let c1 = try PAL.Color(rgbHexString: "#BB1122FE", format: .abgr, name: "c1")
			XCTAssertEqual(c1.colorSpace, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3)
			XCTAssertEqual(c1.colorComponents[0], _p2f(0xFE), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], _p2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], _p2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c1.alpha, _p2f(0xBB), accuracy: 0.00001)

			let c2 = try PAL.Color(rgbHexString: "#BB1122", format: .abgr, name: "c1")
			XCTAssertEqual(c2.colorSpace, .RGB)
			XCTAssertEqual(c2.colorComponents.count, 3)
			XCTAssertEqual(c2.colorComponents[0], _p2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[1], _p2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[2], _p2f(0xBB), accuracy: 0.00001)
			XCTAssertEqual(c2.alpha, 1.0, accuracy: 0.00001)
		}
	}

	func testUIntConversion() throws {
		do {
			let u1: UInt32 = 0xBB1122FE
			let c1 = extractRGBA(u1, format: .rgba)
			XCTAssertEqual(c1.r, 0xBB)
			XCTAssertEqual(c1.g, 0x11)
			XCTAssertEqual(c1.b, 0x22)
			XCTAssertEqual(c1.a, 0xFE)
			let u11 = convertToUInt32(r255: c1.r, g255: c1.g, b255: c1.b, a255: c1.a, colorByteFormat: .rgba)
			XCTAssertEqual(u11, u1)

			let u12 = convertToUInt32(r255: c1.r, g255: c1.g, b255: c1.b, a255: c1.a, colorByteFormat: .rgb)
			XCTAssertEqual(u12, 0x00BB1122)

			let c2 = extractRGBA(u1, format: .argb)
			XCTAssertEqual(c2.r, 0x11)
			XCTAssertEqual(c2.g, 0x22)
			XCTAssertEqual(c2.b, 0xFE)
			XCTAssertEqual(c2.a, 0xBB)
			let u22 = convertToUInt32(r255: c1.r, g255: c1.g, b255: c1.b, a255: c1.a, colorByteFormat: .rgba)
			XCTAssertEqual(u22, u1)

			let c3 = extractRGBA(u1, format: .bgra)
			XCTAssertEqual(c3.r, 0x22)
			XCTAssertEqual(c3.g, 0x11)
			XCTAssertEqual(c3.b, 0xBB)
			XCTAssertEqual(c3.a, 0xFE)
			let u33 = convertToUInt32(r255: c1.r, g255: c1.g, b255: c1.b, a255: c1.a, colorByteFormat: .rgba)
			XCTAssertEqual(u33, u1)

			let u44 = convertToUInt32(r255: c3.r, g255: c3.g, b255: c3.b, a255: c3.a, colorByteFormat: .bgr)
			XCTAssertEqual(u44, 0x00BB1122)
		}
	}

	func testConvertRGB2HSL() throws {
		let mapped = [
			(PAL.Color.RGB(r255: 255, g255: 0, b255: 0), PAL.Color.HSL(hf: 0, sf: 1.0, lf: 0.5, af: 1.0)),
			(PAL.Color.RGB(r255: 187, g255: 67, b255: 180), PAL.Color.HSL(hf: 0.84305, sf: 0.47244, lf: 0.49803, af: 1.0)),
			(PAL.Color.RGB(r255: 157, g255: 166, b255: 190), PAL.Color.HSL(h360: 223, s100: 20, l100: 68, af: 1.0))
		]

		mapped.forEach {
			// Convert rgb -> hsl
			let hsl = $0.hsl()
			XCTAssertEqual(hsl, $1)

			// Convert back hsl -> rgb
			let convertBack = hsl.rgb()
			XCTAssertEqual($0, convertBack)
		}
	}

	let functionTestsFolder = try! testResultsContainer.subfolder(with: "function-tests")

	func testCalculateTetradicColors() throws {
		do {
			let red = PAL.Color.red
			let tetradic = try red.tetradic()
			XCTAssertEqual(tetradic.count, 4)
			XCTAssertEqual(try tetradic[0].rgb(), PAL.Color.RGB(rf: 1.0, gf: 0.0, bf: 0.0))
			XCTAssertEqual(try tetradic[1].rgb(), PAL.Color.RGB(rf: 1.0, gf: 0.0, bf: 0.5))
			XCTAssertEqual(try tetradic[2].rgb(), PAL.Color.RGB(rf: 0.0, gf: 1.0, bf: 1.0))
			XCTAssertEqual(try tetradic[3].rgb(), PAL.Color.RGB(rf: 0.0, gf: 1.0, bf: 0.5))
			try functionTestsFolder.write(tetradic, coder: PAL.Coder.GIMP(), filename: "red-tetradic.gpl")
		}
		do {
			let green = PAL.Color.green
			let tetradic = try green.tetradic()
			XCTAssertEqual(tetradic.count, 4)
			XCTAssertEqual(try tetradic[0].rgb(), PAL.Color.RGB(rf: 0.0, gf: 1.0, bf: 0.0))
			XCTAssertEqual(try tetradic[1].rgb(), PAL.Color.RGB(rf: 0.5, gf: 1.0, bf: 0.0))
			XCTAssertEqual(try tetradic[2].rgb(), PAL.Color.RGB(rf: 1.0, gf: 0.0, bf: 1.0))
			XCTAssertEqual(try tetradic[3].rgb(), PAL.Color.RGB(rf: 0.5, gf: 0.0, bf: 1.0))
			try functionTestsFolder.write(tetradic, coder: PAL.Coder.GIMP(), filename: "green-tetradic.gpl")
		}
	}

	func testRGB2HSB() throws {
		XCTAssertEqual(PAL.Color.RGB(rf: 1, gf: 0, bf: 0).hsb(), PAL.Color.HSB(hf: 1, sf: 1, bf: 1))
		XCTAssertEqual(PAL.Color.RGB(rf: 0, gf: 1, bf: 0).hsb(), PAL.Color.HSB(hf: 0.33333333, sf: 1, bf: 1))
		XCTAssertEqual(PAL.Color.RGB(r255: 39, g255: 0, b255: 102).hsb(), PAL.Color.HSB(h360: 263, s100: 100, b100: 40))
	}

	func testSwiftExport() throws {
		let palette  = try loadResourcePalette(named: "Default.gpl")
		try functionTestsFolder.write(palette, coder: PAL.Coder.SwiftCoder(), filename: "default.swift")

		let palette2 = try loadResourcePalette(named: "ADG3-CMYK.ase")
		try functionTestsFolder.write(palette2, coder: PAL.Coder.SwiftCoder(), filename: "ADG3-CMYK.swift")
	}

	func testRandomColorGeneration() throws {
		let rgb1 = PAL.Color.random()
		XCTAssertEqual(rgb1.colorSpace, .RGB)
		let cmyk1 = PAL.Color.random(colorSpace: .CMYK)
		XCTAssertEqual(cmyk1.colorSpace, .CMYK)
		let gray1 = PAL.Color.random(colorSpace: .Gray)
		XCTAssertEqual(gray1.colorSpace, .Gray)

		let colors12 = PAL.Palette.random(12)
		XCTAssertEqual(colors12.colors.count, 12)
		XCTAssertEqual(colors12.colors[0].colorSpace, .RGB)
		XCTAssertEqual(colors12.colors[11].colorSpace, .RGB)

		let colors8 = PAL.Palette.random(8, colorSpace: .Gray)
		XCTAssertEqual(colors8.colors.count, 8)
		XCTAssertEqual(colors8.colors[0].colorSpace, .Gray)
		XCTAssertEqual(colors8.colors[7].colorSpace, .Gray)
	}

	func testHexExport() throws {
		let c1 = PAL.Color(0xAABBCCDD, format: .rgba)
		XCTAssertEqual(try c1.hexString(.rgb, hashmark: true, uppercase: false), "#aabbcc")
		XCTAssertEqual(try c1.hexString(.bgr, hashmark: true, uppercase: false), "#ccbbaa")
		XCTAssertEqual(try c1.hexString(.rgba, hashmark: true, uppercase: false), "#aabbccdd")
		XCTAssertEqual(try c1.hexString(.argb, hashmark: true, uppercase: false), "#ddaabbcc")
		XCTAssertEqual(try c1.hexString(.bgra, hashmark: true, uppercase: false), "#ccbbaadd")
		XCTAssertEqual(try c1.hexString(.abgr, hashmark: true, uppercase: false), "#ddccbbaa")

		XCTAssertEqual(try c1.hexString(.rgb, hashmark: false, uppercase: false), "aabbcc")
		XCTAssertEqual(try c1.hexString(.bgr, hashmark: false, uppercase: false), "ccbbaa")
		XCTAssertEqual(try c1.hexString(.rgba, hashmark: false, uppercase: false), "aabbccdd")
		XCTAssertEqual(try c1.hexString(.argb, hashmark: false, uppercase: false), "ddaabbcc")
		XCTAssertEqual(try c1.hexString(.bgra, hashmark: false, uppercase: false), "ccbbaadd")
		XCTAssertEqual(try c1.hexString(.abgr, hashmark: false, uppercase: false), "ddccbbaa")

		XCTAssertEqual(try c1.hexString(.rgb, hashmark: true, uppercase: true), "#AABBCC")
		XCTAssertEqual(try c1.hexString(.bgr, hashmark: true, uppercase: true), "#CCBBAA")
		XCTAssertEqual(try c1.hexString(.rgba, hashmark: true, uppercase: true), "#AABBCCDD")
		XCTAssertEqual(try c1.hexString(.argb, hashmark: true, uppercase: true), "#DDAABBCC")
		XCTAssertEqual(try c1.hexString(.bgra, hashmark: true, uppercase: true), "#CCBBAADD")
		XCTAssertEqual(try c1.hexString(.abgr, hashmark: true, uppercase: true), "#DDCCBBAA")

		XCTAssertEqual(try c1.hexString(.rgb, hashmark: false, uppercase: true), "AABBCC")
		XCTAssertEqual(try c1.hexString(.bgr, hashmark: false, uppercase: true), "CCBBAA")
		XCTAssertEqual(try c1.hexString(.rgba, hashmark: false, uppercase: true), "AABBCCDD")
		XCTAssertEqual(try c1.hexString(.argb, hashmark: false, uppercase: true), "DDAABBCC")
		XCTAssertEqual(try c1.hexString(.bgra, hashmark: false, uppercase: true), "CCBBAADD")
		XCTAssertEqual(try c1.hexString(.abgr, hashmark: false, uppercase: true), "DDCCBBAA")
	}

	func testColorGroupingRawIndexTests() throws {
		XCTAssertEqual(PAL.ColorGrouping(rawGroupIndex: 0), PAL.ColorGrouping.global)
		XCTAssertEqual(PAL.ColorGrouping(rawGroupIndex: 1), PAL.ColorGrouping.group(0))
		XCTAssertEqual(PAL.ColorGrouping(rawGroupIndex: 2), PAL.ColorGrouping.group(1))
	}

	func testModifyPalette() throws {
		var palette = try loadResourcePalette(named: "24 colour palettes.ase")

		// No global colors
		XCTAssertThrowsError(try palette.color(colorIndex: 0))
		// Only 5 colors in the first group
		XCTAssertThrowsError(try palette.color(group: .group(0), colorIndex: 5))
		// Only 5 colors in the first group
		XCTAssertNoThrow(try palette.color(group: .group(0), colorIndex: 4))

		try palette.updateColor(group: .group(1), colorIndex: 1, color: rgb255(255, 0, 0))
		try palette.updateColor(group: .group(1), colorIndex: 2, color: rgb255(255, 0, 0))
		try palette.updateColor(group: .group(1), colorIndex: 3, color: rgb255(255, 0, 0))

		let d = try palette.export(format: .ase)
		try d.write(to: URL(fileURLWithPath: "/tmp/modified.ase"))
	}
}



