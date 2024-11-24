@testable import ColorPaletteCodable
import XCTest

let testResultsContainer = try! TestFilesContainer(named: "ColorPaletteCodableTests")

final class CommonTests: XCTestCase {

	func testSimpleColorspaceConversion() throws {

		let rgb = PAL.Color.rgb(1, 0, 0)

		let cmyk = try rgb.converted(to: .CMYK)
		XCTAssertEqual(cmyk.colorSpace, .CMYK)
		XCTAssertEqual(cmyk.colorComponents.count, 4)

		// Make sure we don't barf if converting to the same colorspace (some coders rely on it)
		let converted = try rgb.converted(to: .RGB)
		XCTAssertEqual(converted.colorSpace, .RGB)
	}

	func testRoundTripValueEncodingDecoding() throws {

		// Round-trip Float32
		do {
			let data = try writeFloat32(1)
			let i = InputStream(data: data)
			i.open()

			let floatVal = try readFloat32(i)
			XCTAssertEqual(floatVal, 1)
		}

		// Round-trip UInt16
		do {
			var data = try writeUInt16BigEndian(0)
			data.append(try writeUInt16BigEndian(108))

			let i = InputStream(data: data)
			i.open()

			let readValue1: UInt16 = try readIntegerBigEndian(i)
			let readValue2: UInt16 = try readIntegerBigEndian(i)
			XCTAssertEqual(0, readValue1)
			XCTAssertEqual(108, readValue2)
		}

		// Round-trip UInt32
		do {
			var data = try writeUInt32BigEndian(4)
			data.append(try writeUInt32BigEndian(55))

			let i = InputStream(data: data)
			i.open()

			let readValue1: UInt32 = try readIntegerBigEndian(i)
			let readValue2: UInt32 = try readIntegerBigEndian(i)
			XCTAssertEqual(4, readValue1)
			XCTAssertEqual(55, readValue2)
		}
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
		let c1 = PAL.Color.rgb(1, 0, 0, 0.5)
		let c2 = PAL.Color.cmyk(1, 1, 0, 0, 0.5)
		let c3 = PAL.Color.gray(0.5)

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

		let c1 = NaiveConversions.RGB2CMYK(PAL.Color.RGB(r: 139.0 / 255.0, g: 0, b: 22.0 / 255.0))
		XCTAssertEqual(c1, PAL.Color.CMYK(c: 0, m: 1, y: 0.84, k: 0.45))

		let r1 = NaiveConversions.CMYK2RGB(PAL.Color.CMYK(c: 0, m: 1, y: 0.84, k: 0.45))
		XCTAssertEqual(r1.r, 139.0 / 255.0, accuracy: 0.01)
		XCTAssertEqual(r1.g, 0, accuracy: 0.01)
		XCTAssertEqual(r1.b, 22.0 / 255.0, accuracy: 0.01)

		let c2 = NaiveConversions.RGB2CMYK(PAL.Color.RGB(r: 110 / 255.0, g: 195 / 255.0, b: 201 / 255.0))
		XCTAssertEqual(c2.c, 0.45, accuracy: 0.01)
		XCTAssertEqual(c2.m, 0.03, accuracy: 0.01)
		XCTAssertEqual(c2.y, 0.0, accuracy: 0.01)
		XCTAssertEqual(c2.k, 0.21, accuracy: 0.01)

		let r2 = NaiveConversions.CMYK2RGB(PAL.Color.CMYK(c: 0.45, m: 0.03, y: 0.0, k: 0.21))
		XCTAssertEqual(r2.r, 110 / 255.0, accuracy: 0.01)
		XCTAssertEqual(r2.g, 195 / 255.0, accuracy: 0.01)
		XCTAssertEqual(r2.b, 201 / 255.0, accuracy: 0.01)

		let c3 = NaiveConversions.RGB2CMYK(PAL.Color.RGB(r: 0, g: 0, b: 1))
		XCTAssertEqual(c3.c, 1, accuracy: 0.01)
		XCTAssertEqual(c3.m, 1, accuracy: 0.01)
		XCTAssertEqual(c3.y, 0, accuracy: 0.01)
		XCTAssertEqual(c3.k, 0, accuracy: 0.01)

		let r3 = NaiveConversions.CMYK2RGB(PAL.Color.CMYK(c: 1, m: 1, y: 0, k: 0))
		XCTAssertEqual(r3.r, 0, accuracy: 0.01)
		XCTAssertEqual(r3.g, 0, accuracy: 0.01)
		XCTAssertEqual(r3.b, 1, accuracy: 0.01)
	}

	func testDefaultColors() throws {
		let r1 = PAL.Color.red
		XCTAssertEqual(r1.colorSpace, .RGB)
		XCTAssertEqual(try r1.r(), 1, accuracy: 0.001)
		XCTAssertEqual(try r1.g(), 0, accuracy: 0.001)
		XCTAssertEqual(try r1.b(), 0, accuracy: 0.001)
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
		let cr = try c1.converted(to: .RGB)
		XCTAssertEqual(cr.colorSpace, .RGB)
		XCTAssertEqual(try cr.r(), 0, accuracy: 0.001)
		XCTAssertEqual(try cr.g(), 0.640, accuracy: 0.001)
		XCTAssertEqual(try cr.b(), 0.855, accuracy: 0.001)
		#endif
	}

	func testMidpoint() throws {
		let c1 = PAL.Color.rgb(1, 0, 0, 0.2)
		let c2 = PAL.Color.rgb(0, 0, 1, 0.8)
		let c3 = try c1.midpoint(c2, t: 0.5.unitValue)
		XCTAssertEqual([0.5, 0, 0.5], c3.colorComponents)
		XCTAssertEqual(0.5, c3.alpha)
		#if canImport(CoreGraphics)
		let rx = c3.cgColor
		XCTAssertNotNil(rx)
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
			let hsb1 = RGB_to_HSB(RGB: (r: r1, g: g1, b: b1))

			// Verify our routine matches the NSColor routines
			XCTAssertEqual(h1, hsb1.h, accuracy: 0.00001)
			XCTAssertEqual(s1, hsb1.s, accuracy: 0.00001)
			XCTAssertEqual(v1, hsb1.b, accuracy: 0.00001)

			// Verify our routine reverses correctly
			let rgb2 = HSB_to_RGB((h: h1, s: s1, b: v1))
			XCTAssertEqual(r1, rgb2.r, accuracy: 0.00001)
			XCTAssertEqual(g1, rgb2.g, accuracy: 0.00001)
			XCTAssertEqual(b1, rgb2.b, accuracy: 0.00001)

			#endif
		}
		do {
			let color = try PAL.Color(r255: 0, g255: 255, b255: 0)
			let hsb1 = try color.hsb()
			XCTAssertEqual(hsb1.h, Float32(0.3333), accuracy: 0.0001)
			XCTAssertEqual(hsb1.s, Float32(1))
			XCTAssertEqual(hsb1.b, Float32(1))
		}
		do {
			let color = try PAL.Color(r255: 50, g255: 216, b255: 164)
			let hsb1 = try color.hsb()
			XCTAssertEqual(hsb1.h, Float32(161.2 / 360.0), accuracy: 0.0001)	// 0...360
			XCTAssertEqual(hsb1.s, Float32(76.85 / 100.0), accuracy: 0.0001)	// 0...100
			XCTAssertEqual(hsb1.b, Float32(84.71 / 100.0), accuracy: 0.0001)	// 0...100
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
		let color = try PAL.Color(r255: 50, g255: 216, b255: 164)
		XCTAssertEqual("rgba(50, 216, 164, 1.0)", try color.css())
		XCTAssertEqual("rgb(50, 216, 164)", try color.css(includeAlpha: false))
	}

	func testBucketColor() throws {
		// No colors, this should throw an error
		XCTAssertThrowsError(try [PAL.Color]().bucketedColor(at: 0.unitValue))

		let colors: [PAL.Color] = [
			try PAL.Color(name: "r", r255: 255, g255: 0, b255: 0),
			try PAL.Color(name: "g", r255: 0, g255: 255, b255: 0),
			try PAL.Color(name: "b", r255: 0, g255: 0, b255: 255),
		]
		let p1 = PAL.Palette(colors: colors)

		XCTAssertEqual("r", try p1.colors.bucketedColor(at: 0.unitValue).name)
		XCTAssertEqual("r", try p1.colors.bucketedColor(at: 0.32.unitValue).name)

		XCTAssertEqual("g", try p1.colors.bucketedColor(at: 0.34.unitValue).name)
		XCTAssertEqual("g", try p1.colors.bucketedColor(at: 0.5.unitValue).name)
		XCTAssertEqual("g", try p1.colors.bucketedColor(at: 0.65.unitValue).name)

		XCTAssertEqual("b", try p1.colors.bucketedColor(at: 0.67.unitValue).name)
		XCTAssertEqual("b", try p1.colors.bucketedColor(at: 1.unitValue).name)
	}

	func testLinearColor2() throws {
		// No colors, this should throw an error
		XCTAssertThrowsError(try [PAL.Color]().bucketedColor(at: 0.unitValue))

		let colors: [PAL.Color] = [
			try PAL.Color(name: "r", r255: 255, g255: 0, b255: 0),
			try PAL.Color(name: "b", r255: 0, g255: 0, b255: 255),
		]

		XCTAssertEqual(colors[0], try colors.interpolatedColor(at: 0.unitValue))
		XCTAssertEqual(colors[1], try colors.interpolatedColor(at: 1.unitValue))

		XCTAssertEqual(
			try PAL.Color(rf: 0.75, gf: 0, bf: 0.25),
			try colors.interpolatedColor(at: 0.25.unitValue)
		)

		XCTAssertEqual(
			try PAL.Color(rf: 0.5, gf: 0, bf: 0.5),
			try colors.interpolatedColor(at: 0.5.unitValue)
		)

		XCTAssertEqual(
			try PAL.Color(rf: 0.25, gf: 0, bf: 0.75),
			try colors.interpolatedColor(at: 0.75.unitValue)
		)
	}

	func testLinearColor3() throws {
		// No colors, this should throw an error
		XCTAssertThrowsError(try [PAL.Color]().bucketedColor(at: 0.unitValue))

		// Single color, should just return the color
		let color = try PAL.Color(r255: 255, g255: 255, b255: 0)
		XCTAssertEqual(color, try [color].bucketedColor(at: 0.unitValue))
		XCTAssertEqual(color, try [color].bucketedColor(at: 1.unitValue))

		// Color array
		let colors: [PAL.Color] = [
			try PAL.Color(r255: 255, g255: 0, b255: 0),
			try PAL.Color(r255: 0, g255: 255, b255: 0),
			try PAL.Color(r255: 0, g255: 0, b255: 255),
		]

		XCTAssertEqual(colors[0], try colors.interpolatedColor(at: 0.unitValue))
		XCTAssertEqual(colors[1], try colors.interpolatedColor(at: 0.5.unitValue))
		XCTAssertEqual(colors[2], try colors.interpolatedColor(at: 1.unitValue))

		XCTAssertEqual(
			try PAL.Color(rf: 0.75, gf: 0.25, bf: 0.0),
			try colors.bucketedColor(at: 0.125.unitValue, interpolate: true)
		)

		XCTAssertEqual(
			try PAL.Color(rf: 0.5, gf: 0.5, bf: 0.0),
			try colors.bucketedColor(at: 0.25.unitValue, interpolate: true)
		)

		XCTAssertEqual(
			try PAL.Color(rf: 0.0, gf: 0.5, bf: 0.5),
			try colors.bucketedColor(at: 0.75.unitValue, interpolate: true)
		)
	}

	func testInterpolateBetweenTwoColors() throws {

		do {
			let priceColors = try PAL.Color.interpolate(
				firstColor: .red,
				lastColor: .green,
				count: 3
			)

			XCTAssertEqual(PAL.Color.red, priceColors[0])
			XCTAssertEqual(try PAL.Color(rf: 0.5, gf: 0.5, bf: 0), priceColors[1])
			XCTAssertEqual(PAL.Color.green, priceColors[2])
			XCTAssertEqual(3, priceColors.count)
		}

		do {
			let priceColors = try PAL.Color.interpolate(
				firstColor: PAL.Color(rf: 1, gf: 0.5, bf: 1),
				lastColor: PAL.Color(rf: 0, gf: 0.5, bf: 0.5),
				count: 3
			)

			XCTAssertEqual(try PAL.Color(rf: 1, gf: 0.5, bf: 1), priceColors[0])
			XCTAssertEqual(try PAL.Color(rf: 0.5, gf: 0.5, bf: 0.75), priceColors[1])
			XCTAssertEqual(try PAL.Color(rf: 0, gf: 0.5, bf: 0.5), priceColors[2])
			XCTAssertEqual(3, priceColors.count)
		}

		do {
			XCTAssertThrowsError(try PAL.Colors.blackToWhite(count: 0))
			let g = try PAL.Colors.blackToWhite(count: 1)
			// Single count means only white
			XCTAssertEqual([.white], g)
		}

		do {
			let grays = try PAL.Colors.blackToWhite(count: 3)
			XCTAssertEqual(3, grays.count)
			XCTAssertEqual(try PAL.Color(rf: 0, gf: 0, bf: 0), grays[0])
			XCTAssertEqual(try PAL.Color(rf: 0.5, gf: 0.5, bf: 0.5), grays[1])
			XCTAssertEqual(try PAL.Color(rf: 1, gf: 1, bf: 1), grays[2])
		}

		do {
			let c = try PAL.Colors.colorToClear(.green, count: 4)
			XCTAssertEqual(4, c.count)
			XCTAssertTrue(try PAL.Color(rf: 0, gf: 1, bf: 0, af: 1).isEqual(to: c[0], precision: 8))
			XCTAssertTrue(try PAL.Color(rf: 0, gf: 1, bf: 0, af: 0.666666666).isEqual(to: c[1], precision: 8))
			XCTAssertTrue(try PAL.Color(rf: 0, gf: 1, bf: 0, af: 0.333333333).isEqual(to: c[2], precision: 8))
			XCTAssertTrue(try PAL.Color(rf: 0, gf: 1, bf: 0, af: 0.0).isEqual(to: c[3], precision: 8))
		}
	}
}
