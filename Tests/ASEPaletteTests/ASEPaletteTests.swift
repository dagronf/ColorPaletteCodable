@testable import ASEPalette
import XCTest

final class ASEPaletteTests: XCTestCase {
	func testWriteReadRoundTripSampleFiles() throws {
		for name in [
			"wisteric-17",
			"Ultra-Mattes Reverse",
			"control",
			"Big-Red-Barn",
			"24 colour palettes",  // has multiple groups
			"palette_complex",
			"palette_pantones",
			"palette_simple",
			"1629367375_iColorpalette",
		] {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "ase"))
			let origData = try Data(contentsOf: controlASE)

			// Attempt to load the ase file
			let palette = try ASE.Palette(fileURL: controlASE)

			// Write to a data stream and check that the bytes match the input
			let data = try palette.data()

			// Check that the generated data matches the original data exactly
			XCTAssertEqual(origData, data)

			// Re-create the ase structure from the written data ...
			let p2 = try ASE.Palette(data: data)

			// ... and check equality
			XCTAssertEqual(palette, p2)
		}
	}

	func testBegin() throws {
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
		let palette = try ASE.Palette(fileURL: controlASE)
		
		XCTAssertEqual(1, palette.version0)
		XCTAssertEqual(0, palette.version1)
		
		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(1, palette.groups.count)
		XCTAssertEqual(2, palette.groups[0].colors.count)
	}
	
	func testNextUltraMattes() throws {
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "Ultra-Mattes Reverse", withExtension: "ase"))
		let palette = try ASE.Palette(fileURL: controlASE)
		// Swift.print(palette)
		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(1, palette.groups.count)
		XCTAssertEqual("Ultra-Mattes Reverse", palette.groups[0].name)
	}
	
	func testNextWisteric() throws {
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "wisteric-17", withExtension: "ase"))
		let palette = try ASE.Palette(fileURL: controlASE)
		// Swift.print(palette)
		XCTAssertEqual(0, palette.groups.count)
		XCTAssertEqual(17, palette.colors.count)
	}
	
	func testMulti() throws {
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "24 colour palettes", withExtension: "ase"))
		let palette = try ASE.Palette(fileURL: controlASE)
		// Swift.print(palette)
		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(24, palette.groups.count)
		XCTAssertEqual("PB 3dmaneu chinese umbrellas", palette.groups[0].name)
		XCTAssertEqual(5, palette.groups[0].colors.count)
		XCTAssertEqual("R=55 G=141 B=190", palette.groups[0].colors[0].name)
	}
	
	func testWriteRead() throws {
		do {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
			let palette = try ASE.Palette(fileURL: controlASE)
			
			XCTAssertEqual(0, palette.colors.count)
			XCTAssertEqual(1, palette.groups.count)
			XCTAssertEqual(2, palette.groups[0].colors.count)
			
			let data = try palette.data()
			try data.write(to: URL(fileURLWithPath: "/tmp/output.ase"))
			
			let p2 = try ASE.Palette(data: data)
			XCTAssertEqual(palette.colors.count, p2.colors.count)
			XCTAssertEqual(palette.groups.count, p2.groups.count)
			XCTAssertEqual(palette.groups[0].colors.count, p2.groups[0].colors.count)
		}
		
		do {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "24 colour palettes", withExtension: "ase"))
			let origData = try Data(contentsOf: controlASE)
			let palette = try ASE.Palette(fileURL: controlASE)
			
			XCTAssertEqual(0, palette.colors.count)
			XCTAssertEqual(24, palette.groups.count)
			XCTAssertEqual(5, palette.groups[0].colors.count)
			
			let data = try palette.data()
			XCTAssertEqual(origData, data)
			// try data.write(to: URL(fileURLWithPath: "/tmp/output2.ase"))
			
			let p2 = try ASE.Palette(data: data)
			XCTAssertEqual(palette.colors.count, p2.colors.count)
			XCTAssertEqual(palette.groups.count, p2.groups.count)
			XCTAssertEqual(palette.groups[0].colors.count, p2.groups[0].colors.count)
		}
	}
	
	func testFloatRoundTrip() throws {

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
	
	func testCGColorThings() throws {
		do {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
			let palette = try ASE.Palette(fileURL: controlASE)

			let c1 = palette.groups[0].colors[0]
			let c2 = palette.groups[0].colors[1]

			let cg1 = try XCTUnwrap(c1.cgColor)
			XCTAssertEqual(CGColorSpace.genericRGBLinear, cg1.colorSpace?.name)
			XCTAssertEqual(cg1.components, [1, 1, 1, 1])

			let cg2 = try XCTUnwrap(c2.cgColor)
			XCTAssertEqual(CGColorSpace.genericRGBLinear, cg2.colorSpace?.name)
			XCTAssertEqual(cg2.components, [0, 0, 0, 1])
		}

		do {
			let cmyk = CGColor(genericCMYKCyan: 1, magenta: 1, yellow: 0.5, black: 0.2, alpha: 1)
			let cc1 = try ASE.Color(cgColor: cmyk, name: "cmyk", colorType: .global)

			var p = ASE.Palette()
			p.colors.append(cc1)

			let d1 = try p.data()
			XCTAssertLessThan(0, d1.count)

			let p1 = try ASE.Palette(data: d1)
			XCTAssertEqual(1, p1.colors.count)
			XCTAssertEqual(.CMYK, p1.colors[0].model)
			XCTAssertEqual(4, p1.colors[0].colorComponents.count)
			XCTAssertEqual(1, p1.colors[0].colorComponents[0])
			XCTAssertEqual(1, p1.colors[0].colorComponents[1])
			XCTAssertEqual(0.5, p1.colors[0].colorComponents[2])
			XCTAssertEqual(0.2, p1.colors[0].colorComponents[3])
		}
	}
	
	func testDoco1() throws {
		var palette = ASE.Palette()
		let c1 = try ASE.Color(name: "red", model: ASE.ColorModel.RGB, colorComponents: [1, 0, 0])
		let c2 = try ASE.Color(name: "green", model: ASE.ColorModel.RGB, colorComponents: [0, 1, 0])
		let c3 = try ASE.Color(name: "blue", model: ASE.ColorModel.RGB, colorComponents: [0, 0, 1])
		palette.colors.append(contentsOf: [c1, c2, c3])
		
		let rawData = try palette.data()
		XCTAssertFalse(rawData.isEmpty)
		
		let p2 = try ASE.Palette(data: rawData)
		XCTAssertEqual(3, p2.colors.count)
		
		XCTAssertEqual(p2.colors[0].colorComponents, [Float32(1.0), Float32(0.0), Float32(0.0)])
		XCTAssertEqual(p2.colors[1].colorComponents, [Float32(0.0), Float32(1.0), Float32(0.0)])
		XCTAssertEqual(p2.colors[2].colorComponents, [Float32(0.0), Float32(0.0), Float32(1.0)])
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

		XCTAssertTrue(p2.colors.isEmpty)

		XCTAssertEqual(1, p2.groups.count)
		XCTAssertEqual("rgb", p2.groups[0].name)
		
		XCTAssertEqual(p2.groups[0].colors[0].colorComponents, [Float32(1.0), Float32(0.0), Float32(0.0)])
		XCTAssertEqual(p2.groups[0].colors[0].name, "red")
		XCTAssertEqual(p2.groups[0].colors[1].colorComponents, [Float32(0.0), Float32(1.0), Float32(0.0)])
		XCTAssertEqual(p2.groups[0].colors[1].name, "green")
		XCTAssertEqual(p2.groups[0].colors[2].colorComponents, [Float32(0.0), Float32(0.0), Float32(1.0)])
		XCTAssertEqual(p2.groups[0].colors[2].name, "blue")
	}

	func testColorLoading() throws {

		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "1629367375_iColorpalette", withExtension: "ase"))
		let palette = try ASE.Palette(fileURL: controlASE)

		do {
			// Validate round-trip. Write to a data stream and check that the bytes match the input file content
			let origData = try Data(contentsOf: controlASE)
			let data = try palette.data()

			// Check that the generated data matches the original data exactly
			XCTAssertEqual(origData, data)
		}

		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(1, palette.groups.count)

		XCTAssertEqual("Array_iColorpalette", palette.groups[0].name)
		XCTAssertEqual(5, palette.groups[0].colors.count)

		do {
			// Validate hex generation against the hex values obtained from https://carl.camera/sandbox/aseconvert/
			XCTAssertEqual("#523b50", palette.groups[0].colors[0].hexRGB)
			XCTAssertEqual("#b0ac89", palette.groups[0].colors[1].hexRGB)
			XCTAssertEqual("#815d72", palette.groups[0].colors[2].hexRGB)
			XCTAssertEqual("#a9b650", palette.groups[0].colors[3].hexRGB)
			XCTAssertEqual("#ebede9", palette.groups[0].colors[4].hexRGB)
		}
	}

	func testColorInit() throws {
		do {
			let c1 = try ASE.Color(name: "c1", rgbHexString: "1122FE")
			XCTAssertEqual(c1.model, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3)
			XCTAssertEqual(c1.colorComponents[0], 0.06666, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], 0.13333, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], 0.99607, accuracy: 0.00001)
		}

		do {
			let c1 = try ASE.Color(name: "c1", rgbaHexString: "#54efaa11")
			XCTAssertEqual(c1.model, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3)	// alpha is stripped
			XCTAssertEqual(c1.colorComponents[0], 0.32941, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], 0.93725, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], 0.66666, accuracy: 0.00001)
		}
	}

	func testColorInitHexInvalid() throws {
		do {
			XCTAssertThrowsError(try ASE.Color(name: "c1", rgbHexString: "#5e34"))
			XCTAssertThrowsError(try ASE.Color(name: "c1", rgbHexString: "5e34"))
			XCTAssertThrowsError(try ASE.Color(name: "c1", rgbHexString: "1122F"))
			XCTAssertThrowsError(try ASE.Color(name: "c1", rgbHexString: "1122FEE"))
			XCTAssertThrowsError(try ASE.Color(name: "c1", rgbHexString: "#1SS122F"))

			XCTAssertNoThrow(try ASE.Color(name: "c1", rgbHexString: "#1122FE"))
			XCTAssertNoThrow(try ASE.Color(name: "c1", rgbHexString: "1122FE"))
		}

		do {
			XCTAssertThrowsError(try ASE.Color(name: "c1", rgbHexString: "1122F"))
			XCTAssertThrowsError(try ASE.Color(name: "c1", rgbaHexString: "#1SS122Faa"))
			XCTAssertThrowsError(try ASE.Color(name: "c1", rgbaHexString: "E1122FE23"))

			XCTAssertNoThrow(try ASE.Color(name: "c1", rgbaHexString: "#1122FE23"))
			XCTAssertNoThrow(try ASE.Color(name: "c1", rgbaHexString: "1122FE32"))
			XCTAssertNoThrow(try ASE.Color(name: "c1", rgbaHexString: "#1122FEaa"))
			XCTAssertNoThrow(try ASE.Color(name: "c1", rgbaHexString: "1122FEaa"))
		}
	}
}
