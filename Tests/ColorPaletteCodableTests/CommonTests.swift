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

	func testDataParsing() throws {

		do {
			let data = Data([0xAE])
			let parser = DataParser(data: data)

			// Should not be able to seek beyond the end of the data
			XCTAssertThrowsError(try parser.seek(1, .current))
			XCTAssertThrowsError(try parser.seek(1, .end))
			XCTAssertThrowsError(try parser.seek(1, .start))


			let value: UInt8 = try parser.readUInt8()
			XCTAssertEqual(0xAE, value)
			XCTAssertFalse(parser.hasMoreData())

			try parser.seekSet(0)
			let value2: Int8 = try parser.readInt8()

			// https://simonv.fr/TypesConvert/?integers
			XCTAssertEqual(-82, value2)
		}


		do {
			let data = Data([0x11, 0x22, 0x33, 0x44])
			let parser = DataParser(data: data)
			let value: UInt32 = try parser.readInteger(.big)
			XCTAssertEqual(0x11223344, value)
			XCTAssertFalse(parser.hasMoreData())
			try parser.seekSet(0)
			let value2: UInt32 = try parser.readInteger(.little)
			XCTAssertEqual(0x44332211, value2)
			XCTAssertFalse(parser.hasMoreData())
			XCTAssertThrowsError(try parser.readByte())
			
			try parser.seekSet(2)
			XCTAssertEqual(0x33, try parser.readByte())
			XCTAssertEqual(0x44, try parser.readByte())
			XCTAssertFalse(parser.hasMoreData())
		}

		do {
			let data2 = Data([0x11, 0x22, 0x33, 0x44])
			let parser2 = DataParser(data: data2)
			XCTAssertEqual(0x11, try parser2.readByte())
			XCTAssertEqual(0x22, try parser2.readByte())
			XCTAssertEqual(0x33, try parser2.readByte())
			XCTAssertEqual(0x44, try parser2.readByte())
			XCTAssertFalse(parser2.hasMoreData())
		}

		do {
			let data3 = Data([0x11, 0x22, 0x33, 0x44])
			let parser3 = DataParser(data: data3)
			let datar = try parser3.readData(count: 4)
			XCTAssertEqual([0x11, 0x22, 0x33, 0x44], Array(datar))
			XCTAssertFalse(parser3.hasMoreData())
			XCTAssertThrowsError(try parser3.readByte())
		}

		do {
			let data3 = Data([0x11, 0x22, 0x33, 0x44])
			let parser3 = DataParser(data: data3)
			let data1 = try parser3.readData(count: 2)
			let data2 = try parser3.readData(count: 2)
			XCTAssertFalse(parser3.hasMoreData())
			XCTAssertThrowsError(try parser3.readByte())

			XCTAssertEqual([0x11, 0x22], Array(data1))
			XCTAssertEqual([0x33, 0x44], Array(data2))
		}

		do {
			let data3 = Data([0x11, 0x22, 0x33, 0x44])
			let parser3 = DataParser(data: data3)
			let data1 = try parser3.readData(count: 1)
			let data2 = try parser3.readToEndOfData()
			XCTAssertFalse(parser3.hasMoreData())
			XCTAssertThrowsError(try parser3.readByte())

			XCTAssertEqual([0x11], Array(data1))
			XCTAssertEqual([0x22, 0x33, 0x44], Array(data2))
		}
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
			let c1 = try PAL.Color(rgbaHexString: "B0C4DEFF")
			XCTAssertEqual(_u2f(0xB0), c1.colorComponents[0], accuracy: 0.000001)
			XCTAssertEqual(_u2f(0xC4), c1.colorComponents[1], accuracy: 0.000001)
			XCTAssertEqual(_u2f(0xDE), c1.colorComponents[2], accuracy: 0.000001)
			XCTAssertEqual(1.0, c1.alpha, accuracy: 0.000001)
		}
		do {
			let c1 = try PAL.Color(argbHexString: "B0C4DEFF")
			XCTAssertEqual(_u2f(0xC4), c1.colorComponents[0], accuracy: 0.000001)
			XCTAssertEqual(_u2f(0xDE), c1.colorComponents[1], accuracy: 0.000001)
			XCTAssertEqual(_u2f(0xFF), c1.colorComponents[2], accuracy: 0.000001)
			XCTAssertEqual(_u2f(0xB0), c1.alpha, accuracy: 0.000001)
		}

		do {
			let c1 = try PAL.Color(argbHexString: "#FFFFF0")
			XCTAssertEqual(1.0, c1.colorComponents[0], accuracy: 0.000001)
			XCTAssertEqual(1.0, c1.colorComponents[1], accuracy: 0.000001)
			XCTAssertEqual(_u2f(0xF0), c1.colorComponents[2], accuracy: 0.000001)
			XCTAssertEqual(1.0, c1.alpha, accuracy: 0.000001)
		}

		do {
			let c2 = try PAL.Color(name: "c2", rgbaHexString: "#1122FE")
			XCTAssertEqual(c2.colorSpace, .RGB)
			XCTAssertEqual(c2.colorComponents.count, 3)
			XCTAssertEqual(c2.colorComponents[0], _u2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[1], _u2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[2], _u2f(0xFE), accuracy: 0.00001)
		}

		do {
			let c3 = try PAL.Color(name: "c3", rgbaHexString: "0x1122FE")
			XCTAssertEqual(c3.colorSpace, .RGB)
			XCTAssertEqual(c3.colorComponents.count, 3)
			XCTAssertEqual(c3.colorComponents[0], _u2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c3.colorComponents[1], _u2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c3.colorComponents[2], _u2f(0xFE), accuracy: 0.00001)
		}

		do {
			let c1 = try PAL.Color(name: "c1", argbHexString: "0x1122FE")
			XCTAssertEqual(c1.colorSpace, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3)
			XCTAssertEqual(c1.colorComponents[0], _u2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], _u2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], _u2f(0xFE), accuracy: 0.00001)
			XCTAssertEqual(c1.alpha, 1.0, accuracy: 0.00001)

			let c2 = try PAL.Color(name: "c2", argbHexString: "0xBB1122FE")
			XCTAssertEqual(c2.colorSpace, .RGB)
			XCTAssertEqual(c2.colorComponents.count, 3)
			XCTAssertEqual(c2.colorComponents[0], _u2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[1], _u2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[2], _u2f(0xFE), accuracy: 0.00001)
			XCTAssertEqual(c2.alpha, _u2f(0xBB), accuracy: 0.00001)
		}

		do {
			let c1 = try PAL.Color(name: "c1", hexString: "#BB1122FE", hexRGBFormat: .bgra)
			XCTAssertEqual(c1.colorSpace, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3)
			XCTAssertEqual(c1.colorComponents[0], _u2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], _u2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], _u2f(0xBB), accuracy: 0.00001)
			XCTAssertEqual(c1.alpha, _u2f(0xFE), accuracy: 0.00001)

			let c2 = try PAL.Color(name: "c1", hexString: "#BB1122", hexRGBFormat: .bgra)
			XCTAssertEqual(c2.colorSpace, .RGB)
			XCTAssertEqual(c2.colorComponents.count, 3)
			XCTAssertEqual(c2.colorComponents[0], _u2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[1], _u2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[2], _u2f(0xBB), accuracy: 0.00001)
			XCTAssertEqual(c2.alpha, 1.0, accuracy: 0.00001)
		}

		do {
			let c1 = try PAL.Color(name: "c1", hexString: "#BB1122FE", hexRGBFormat: .abgr)
			XCTAssertEqual(c1.colorSpace, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3)
			XCTAssertEqual(c1.colorComponents[0], _u2f(0xFE), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], _u2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], _u2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c1.alpha, _u2f(0xBB), accuracy: 0.00001)

			let c2 = try PAL.Color(name: "c1", hexString: "#BB1122", hexRGBFormat: .abgr)
			XCTAssertEqual(c2.colorSpace, .RGB)
			XCTAssertEqual(c2.colorComponents.count, 3)
			XCTAssertEqual(c2.colorComponents[0], _u2f(0x22), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[1], _u2f(0x11), accuracy: 0.00001)
			XCTAssertEqual(c2.colorComponents[2], _u2f(0xBB), accuracy: 0.00001)
			XCTAssertEqual(c2.alpha, 1.0, accuracy: 0.00001)
		}
	}

	#if !os(Linux)
	func testSwiftExport() throws {
		let palette  = try loadResourcePalette(named: "Default.gpl")
		let d = try PAL.Coder.SwiftCoder().encode(palette)
		try d.write(to: URL(fileURLWithPath: "/tmp/palette.swift"))

		let palette2 = try loadResourcePalette(named: "ADG3-CMYK.ase")
		let d2 = try PAL.Coder.SwiftCoder().encode(palette2)
		try d2.write(to: URL(fileURLWithPath: "/tmp/palette2.swift"))
	}
	#endif
}
