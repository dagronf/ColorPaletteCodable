@testable import ColorPaletteCodable
import XCTest

final class CommonTests: XCTestCase {
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

		XCTAssertEqual(c1.model, .RGB)
		XCTAssertEqual(c2.model, .CMYK)
		XCTAssertEqual(c3.model, .Gray)

		let palette = PAL.Palette(colors: [c1, c2, c3])

		// This will trip off the alpha components here
		let aseData = try PAL.Coder.ASE().encode(palette)

		// Reload from the ase data
		let reloaded = try PAL.Coder.ASE().decode(from: aseData)

		XCTAssertEqual(1.0, reloaded.colors[0].alpha)
		XCTAssertEqual(.RGB, reloaded.colors[0].model)
		XCTAssertEqual(1.0, reloaded.colors[1].alpha)
		XCTAssertEqual(.CMYK, reloaded.colors[1].model)
		XCTAssertEqual(1.0, reloaded.colors[2].alpha)
		XCTAssertEqual(.Gray, reloaded.colors[2].model)
	}
}
