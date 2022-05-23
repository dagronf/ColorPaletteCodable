@testable import ASEPalette
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

		// Load from an ase file
		let p1 = try ASE.Factory.shared.load(fileURL: aseFile)
		XCTAssertEqual(p1.colors.count, 17)

		// Load from an aco file
		let p2 = try ASE.Factory.shared.load(fileURL: acoFile)
		XCTAssertEqual(p2.colors.count, 256)

		#if os(macOS)
		// Load from a clr file
		let p3 = try ASE.Factory.shared.load(fileURL: clrFile)
		XCTAssertEqual(p3.colors.count, 12)
		#else
		// NSColorList not supported on ios/tvos. Check that we throw correctly
		XCTAssertThrowsError(try ASE.Factory.shared.load(fileURL: clrFile))
		#endif
	}

	func testRGB() throws {
		let rgbURL = try XCTUnwrap(Bundle.module.url(forResource: "basic1", withExtension: "txt"))
		let origData = try Data(contentsOf: rgbURL)

		let palette = try ASE.Factory.shared.load(fileURL: rgbURL, usingExtension: "rgb")
		XCTAssertEqual(palette.colors.count, 7)

		let data = try ASE.Factory.shared.data(palette, "rgb")
		XCTAssertEqual(origData, data)
	}

	func testRGBA() throws {
		let rgbaURL = try XCTUnwrap(Bundle.module.url(forResource: "basic1alpha", withExtension: "txt"))
		let origData = try Data(contentsOf: rgbaURL)

		// Read in as RGBA
		let palette = try ASE.Factory.shared.load(fileURL: rgbaURL, usingExtension: "rgba")
		XCTAssertEqual(palette.colors.count, 7)

		// Check some alpha values that they are correctly loaded
		XCTAssertEqual(palette.colors[0].alpha, 0.6666, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[1].alpha, 0.7333, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[2].alpha, 0.0705, accuracy: 0.0001)
		XCTAssertEqual(palette.colors[6].alpha, 0.7019, accuracy: 0.0001)

		// Write out as RGBA
		let data = try ASE.Factory.shared.data(palette, "rgba")

		// The input and output files should be identical
		XCTAssertEqual(origData, data)
	}
}
