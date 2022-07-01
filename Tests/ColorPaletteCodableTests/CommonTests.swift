@testable import ColorPaletteCodable
import XCTest

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

	func testUnknownFormat() throws {
		let txtFile = try XCTUnwrap(Bundle.module.url(forResource: "basic1", withExtension: "txt"))

		// Attempt to load from a file type we can't autodetect
		XCTAssertThrowsError(try PAL.Palette.Decode(from: txtFile))
	}

	func testColors() throws {
		let c1 = PAL.Color.rgb(1, 0, 0, 0.5)
		let c2 = PAL.Color.cmyk(1, 1, 0, 0, 0.5)
		let c3 = PAL.Color.gray(white: 0.5)

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

		let c1 = NaiveConversions.RGB2CMYK((r: 139.0 / 255.0, g: 0, b: 22.0 / 255.0))
		XCTAssertEqual(c1.0, 0, accuracy: 0.01)
		XCTAssertEqual(c1.1, 1, accuracy: 0.01)
		XCTAssertEqual(c1.2, 0.84, accuracy: 0.01)
		XCTAssertEqual(c1.3, 0.45, accuracy: 0.01)

		let r1 = NaiveConversions.CMYK2RGB((c: 0, m: 1, y: 0.84, k: 0.45))
		XCTAssertEqual(r1.0, 139.0 / 255.0, accuracy: 0.01)
		XCTAssertEqual(r1.1, 0, accuracy: 0.01)
		XCTAssertEqual(r1.2, 22.0 / 255.0, accuracy: 0.01)

		let c2 = NaiveConversions.RGB2CMYK((r: 110 / 255.0, g: 195 / 255.0, b: 201 / 255.0))
		XCTAssertEqual(c2.0, 0.45, accuracy: 0.01)
		XCTAssertEqual(c2.1, 0.03, accuracy: 0.01)
		XCTAssertEqual(c2.2, 0.0, accuracy: 0.01)
		XCTAssertEqual(c2.3, 0.21, accuracy: 0.01)

		let r2 = NaiveConversions.CMYK2RGB((c: 0.45, m: 0.03, y: 0.0, k: 0.21))
		XCTAssertEqual(r2.0, 110 / 255.0, accuracy: 0.01)
		XCTAssertEqual(r2.1, 195 / 255.0, accuracy: 0.01)
		XCTAssertEqual(r2.2, 201 / 255.0, accuracy: 0.01)

		let c3 = NaiveConversions.RGB2CMYK((r: 0, g: 0, b: 1))
		XCTAssertEqual(c3.0, 1, accuracy: 0.01)
		XCTAssertEqual(c3.1, 1, accuracy: 0.01)
		XCTAssertEqual(c3.2, 0, accuracy: 0.01)
		XCTAssertEqual(c3.3, 0, accuracy: 0.01)

		let r3 = NaiveConversions.CMYK2RGB((c: 1, m: 1, y: 0, k: 0))
		XCTAssertEqual(r3.0, 0, accuracy: 0.01)
		XCTAssertEqual(r3.1, 0, accuracy: 0.01)
		XCTAssertEqual(r3.2, 1, accuracy: 0.01)
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
}
