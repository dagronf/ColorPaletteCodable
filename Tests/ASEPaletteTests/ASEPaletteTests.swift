import XCTest
@testable import ASEPalette

final class ASEPaletteTests: XCTestCase {

	// http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase

	func testBegin() throws {
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
		let palette = try ASE.Palette(fileURL: controlASE)

		XCTAssertEqual(1, palette.version0)
		XCTAssertEqual(0, palette.version1)

		XCTAssertEqual(0, palette.global.colors.count)
		XCTAssertEqual(1, palette.groups.count)
		XCTAssertEqual(2, palette.groups[0].colors.count)
	}

	func testNextUltraMattes() throws {
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "Ultra-Mattes Reverse", withExtension: "ase"))
		let palette = try ASE.Palette(fileURL: controlASE)
		//Swift.print(palette)
		XCTAssertEqual(0, palette.global.colors.count)
		XCTAssertEqual(1, palette.groups.count)
		XCTAssertEqual("Ultra-Mattes Reverse", palette.groups[0].name)
	}

	func testNextWisteric() throws {
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "wisteric-17", withExtension: "ase"))
		let palette = try ASE.Palette(fileURL: controlASE)
		// Swift.print(palette)
		XCTAssertEqual(0, palette.groups.count)
		XCTAssertEqual(17, palette.global.colors.count)
	}

	func testMulti() throws {
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "24 colour palettes", withExtension: "ase"))
		let palette = try ASE.Palette(fileURL: controlASE)
		// Swift.print(palette)
		XCTAssertEqual(0, palette.global.colors.count)
		XCTAssertEqual(24, palette.groups.count)
		XCTAssertEqual("PB 3dmaneu chinese umbrellas", palette.groups[0].name)
		XCTAssertEqual(5, palette.groups[0].colors.count)
		XCTAssertEqual("R=55 G=141 B=190", palette.groups[0].colors[0].name)
	}

	func testWriteReadRoundTripSampleFiles() throws {
		for name in [
			"wisteric-17",
			"Ultra-Mattes Reverse",
			"control",
			"Big-Red-Barn",
			"24 colour palettes",
			"palette_complex",
			"palette_pantones",
			"palette_simple",
		] {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "ase"))
			let origData = try Data(contentsOf: controlASE)

			// Attempt to load the ase file
			let palette = try ASE.Palette(fileURL: controlASE)

			// Write to a data stream and check that the bytes match the input
			let data = try palette.data()
			XCTAssertEqual(origData, data)

			// Re-create the ase structure from the written data ...
			let p2 = try ASE.Palette(data: data)

			// ... and check equality
			XCTAssertEqual(palette, p2)
		}
	}

	func testWriteRead() throws {
		do {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
			let palette = try ASE.Palette(fileURL: controlASE)

			XCTAssertEqual(0, palette.global.colors.count)
			XCTAssertEqual(1, palette.groups.count)
			XCTAssertEqual(2, palette.groups[0].colors.count)

			let data = try palette.data()
			try data.write(to: URL(fileURLWithPath: "/tmp/output.ase"))

			let p2 = try ASE.Palette(data: data)
			XCTAssertEqual(palette.global.colors.count, p2.global.colors.count)
			XCTAssertEqual(palette.groups.count, p2.groups.count)
			XCTAssertEqual(palette.groups[0].colors.count, p2.groups[0].colors.count)
		}

		do {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "24 colour palettes", withExtension: "ase"))
			let origData = try Data(contentsOf: controlASE)
			let palette = try ASE.Palette(fileURL: controlASE)

			XCTAssertEqual(0, palette.global.colors.count)
			XCTAssertEqual(24, palette.groups.count)
			XCTAssertEqual(5, palette.groups[0].colors.count)

			let data = try palette.data()
			XCTAssertEqual(origData, data)
			//try data.write(to: URL(fileURLWithPath: "/tmp/output2.ase"))

			let p2 = try ASE.Palette(data: data)
			XCTAssertEqual(palette.global.colors.count, p2.global.colors.count)
			XCTAssertEqual(palette.groups.count, p2.groups.count)
			XCTAssertEqual(palette.groups[0].colors.count, p2.groups[0].colors.count)
		}
	}

	func testFloatRoundTrip() throws {

		do {
			let data = try writeFloat32(1)
			let i = InputStream(data: data)
			i.open()

			let floatVal = try readFloat32(i)
			XCTAssertEqual(floatVal, 1)
		}

		do {
			var data = try writeUInt16(0)
			data.append(try writeUInt16(108))

			let i = InputStream(data: data)
			i.open()

			let readValue1: UInt16 = try readInteger(i)
			let readValue2: UInt16 = try readInteger(i)
			XCTAssertEqual(0, readValue1)
			XCTAssertEqual(108, readValue2)
		}

		do {
			var data = try writeUInt32(4)
			data.append(try writeUInt32(55))

			let i = InputStream(data: data)
			i.open()

			let readValue1: UInt32 = try readInteger(i)
			let readValue2: UInt32 = try readInteger(i)
			XCTAssertEqual(4, readValue1)
			XCTAssertEqual(55, readValue2)
		}
	}


	func testCGColorThings() throws {
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
		let palette = try ASE.Palette(fileURL: controlASE)

		let c1 = palette.groups[0].colors[0]
		let c2 = palette.groups[0].colors[1]

		let cg1 = try XCTUnwrap(c1.cgColor)
		let cg2 = try XCTUnwrap(c2.cgColor)
	}

	func testDoco1() throws {
		var palette = ASE.Palette()
		let c1 = try ASE.Color(name: "red", model: ASE.ColorModel.RGB, colorComponents: [1, 0, 0])
		let c2 = try ASE.Color(name: "green", model: ASE.ColorModel.RGB, colorComponents: [0, 1, 0])
		let c3 = try ASE.Color(name: "blue", model: ASE.ColorModel.RGB, colorComponents: [0, 0, 1])
		palette.global.colors.append(contentsOf: [c1, c2, c3])

		let rawData = try palette.data()
		XCTAssertFalse(rawData.isEmpty)

		let p2 = try ASE.Palette(data: rawData)
		XCTAssertEqual(3, p2.global.colors.count)

		XCTAssertEqual(p2.global.colors[0].colorComponents, [Float32(1.0), Float32(0.0), Float32(0.0)])
		XCTAssertEqual(p2.global.colors[1].colorComponents, [Float32(0.0), Float32(1.0), Float32(0.0)])
		XCTAssertEqual(p2.global.colors[2].colorComponents, [Float32(0.0), Float32(0.0), Float32(1.0)])
	}

	func testDoco2() throws {
		var palette = ASE.Palette()
		let c1 = try ASE.Color(name: "red", model: ASE.ColorModel.RGB, colorComponents: [1, 0, 0])
		let c2 = try ASE.Color(name: "green", model: ASE.ColorModel.RGB, colorComponents: [0, 1, 0])
		let c3 = try ASE.Color(name: "blue", model: ASE.ColorModel.RGB, colorComponents: [0, 0, 1])

		let grp = ASE.Group(name: "rgb", colors: [c1, c2, c3])
		palette.groups.append(grp)

		let rawData = try palette.data()
		XCTAssertFalse(rawData.isEmpty)

		let p2 = try ASE.Palette(data: rawData)
		XCTAssertTrue(p2.global.colors.isEmpty)
		XCTAssertEqual(1, p2.groups.count)
		XCTAssertEqual("rgb", p2.groups[0].name)

		XCTAssertEqual(p2.groups[0].colors[0].colorComponents, [Float32(1.0), Float32(0.0), Float32(0.0)])
		XCTAssertEqual(p2.groups[0].colors[1].colorComponents, [Float32(0.0), Float32(1.0), Float32(0.0)])
		XCTAssertEqual(p2.groups[0].colors[2].colorComponents, [Float32(0.0), Float32(0.0), Float32(1.0)])
	}
}
