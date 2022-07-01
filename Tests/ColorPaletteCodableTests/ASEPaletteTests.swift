@testable import ColorPaletteCodable
import XCTest

let ase_resources = [
	"wisteric-17",
	"Ultra-Mattes Reverse",
	"control",
	"Big-Red-Barn",
	"24 colour palettes", // has multiple groups
	"palette_complex",
	"palette_pantones",
	"palette_simple",
	"1629367375_iColorpalette",
	"sw-colors-name-ede-ase",
	"zenit-241",
	"color-cubes",
]

final class ASEPaletteTests: XCTestCase {
	func testWriteReadRoundTripSampleFiles() throws {
		// Loop through all the resource files
		Swift.print("Round-tripping ASE files...'")
		
		let coder = try XCTUnwrap(PAL.Palette.coder(for: "ase"))
		
		for name in ase_resources {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "ase"))
			let origData = try Data(contentsOf: controlASE)
			
			Swift.print("Validating '\(name)...'")
			
			// Attempt to load the ase file
			let palette = try coder.decode(from: controlASE)
			
			// Write to a data stream
			let data = try coder.encode(palette)
			
			// Check that the generated data matches the original data exactly
			XCTAssertEqual(origData, data)
			
			// Re-create the ase structure from the written data ...
			let reconstitutedPalette = try coder.decode(from: data)
			
			// ... and check equality between the original file and our reconstituted one.
			XCTAssertEqual(palette, reconstitutedPalette)
		}
	}
	
	func testBasic() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.coder(for: "ase"))
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
		let origData = try Data(contentsOf: controlASE)
		let palette = try paletteCoder.decode(from: controlASE)
		let data = try paletteCoder.encode(palette)
		XCTAssertEqual(origData, data)
		let reconstitutedPalette = try paletteCoder.decode(from: data)
		XCTAssertEqual(palette, reconstitutedPalette)
	}
	
	func testSimpleLoad() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.coder(for: "ase"))
		
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
		let palette = try paletteCoder.decode(from: controlASE)
		
		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(1, palette.groups.count)
		XCTAssertEqual(2, palette.groups[0].colors.count)
	}
	
	func testNextUltraMattes() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.coder(for: "ase"))
		
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "Ultra-Mattes Reverse", withExtension: "ase"))
		let palette = try paletteCoder.decode(from: controlASE)
		
		// Swift.print(palette)
		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(1, palette.groups.count)
		XCTAssertEqual("Ultra-Mattes Reverse", palette.groups[0].name)
	}
	
	func testNextWisteric() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.coder(for: "ase"))
		
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "wisteric-17", withExtension: "ase"))
		let palette = try paletteCoder.decode(from: controlASE)
		// Swift.print(palette)
		XCTAssertEqual(0, palette.groups.count)
		XCTAssertEqual(17, palette.colors.count)
	}
	
	func testMulti() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.coder(for: "ase"))
		
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "24 colour palettes", withExtension: "ase"))
		let palette = try paletteCoder.decode(from: controlASE)
		// Swift.print(palette)
		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(24, palette.groups.count)
		XCTAssertEqual("PB 3dmaneu chinese umbrellas", palette.groups[0].name)
		XCTAssertEqual(5, palette.groups[0].colors.count)
		XCTAssertEqual("R=55 G=141 B=190", palette.groups[0].colors[0].name)
	}
	
	func testWriteRead() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.coder(for: "ase"))
		
		do {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
			let palette = try paletteCoder.decode(from: controlASE)
			
			XCTAssertEqual(0, palette.colors.count)
			XCTAssertEqual(1, palette.groups.count)
			XCTAssertEqual(2, palette.groups[0].colors.count)
			
			let data = try paletteCoder.encode(palette)
			
			let p2 = try paletteCoder.decode(from: data)
			XCTAssertEqual(palette.colors.count, p2.colors.count)
			XCTAssertEqual(palette.groups.count, p2.groups.count)
			XCTAssertEqual(palette.groups[0].colors.count, p2.groups[0].colors.count)
		}
		
		do {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "24 colour palettes", withExtension: "ase"))
			let origData = try Data(contentsOf: controlASE)
			let palette = try paletteCoder.decode(from: controlASE)
			
			XCTAssertEqual(0, palette.colors.count)
			XCTAssertEqual(24, palette.groups.count)
			XCTAssertEqual(5, palette.groups[0].colors.count)
			
			let data = try paletteCoder.encode(palette)
			XCTAssertEqual(origData, data)
			// try data.write(to: URL(fileURLWithPath: "/tmp/output2.ase"))
			
			let p2 = try paletteCoder.decode(from: data)
			XCTAssertEqual(palette.colors.count, p2.colors.count)
			XCTAssertEqual(palette.groups.count, p2.groups.count)
			XCTAssertEqual(palette.groups[0].colors.count, p2.groups[0].colors.count)
		}
	}
	
	func testDoco1() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.coder(for: "ase"))
		
		var palette = PAL.Palette()
		let c1 = try PAL.Color(name: "red", colorSpace: .RGB, colorComponents: [1, 0, 0])
		let c2 = try PAL.Color(name: "green", colorSpace: .RGB, colorComponents: [0, 1, 0])
		let c3 = try PAL.Color(name: "blue", colorSpace: .RGB, colorComponents: [0, 0, 1])
		palette.colors.append(contentsOf: [c1, c2, c3])
		
		let rawData = try paletteCoder.encode(palette)
		XCTAssertFalse(rawData.isEmpty)
		
		let p2 = try paletteCoder.decode(from: rawData)
		XCTAssertEqual(3, p2.colors.count)
		
		XCTAssertEqual(p2.colors[0].colorComponents, [Float32(1.0), Float32(0.0), Float32(0.0)])
		XCTAssertEqual(p2.colors[1].colorComponents, [Float32(0.0), Float32(1.0), Float32(0.0)])
		XCTAssertEqual(p2.colors[2].colorComponents, [Float32(0.0), Float32(0.0), Float32(1.0)])
	}
	
	func testDoco2() throws {
		let paletteCoder = PAL.Coder.ASE()
		
		var palette = PAL.Palette()
		let c1 = try PAL.Color(name: "red", colorSpace: PAL.ColorSpace.RGB, colorComponents: [1, 0, 0])
		let c2 = try PAL.Color(name: "green", colorSpace: PAL.ColorSpace.RGB, colorComponents: [0, 1, 0])
		let c3 = try PAL.Color(name: "blue", colorSpace: PAL.ColorSpace.RGB, colorComponents: [0, 0, 1])
		
		let grp = PAL.Group(name: "rgb", colors: [c1, c2, c3])
		palette.groups.append(grp)
		
		let rawData = try paletteCoder.encode(palette)
		XCTAssertFalse(rawData.isEmpty)
		
		let p2 = try paletteCoder.decode(from: rawData)
		
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
		let paletteCoder = PAL.Coder.ASE()
		
		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "1629367375_iColorpalette", withExtension: "ase"))
		let palette = try paletteCoder.decode(from: controlASE)
		
		do {
			// Validate round-trip. Write to a data stream and check that the bytes match the input file content
			let origData = try Data(contentsOf: controlASE)
			let data = try paletteCoder.encode(palette)
			
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
			let c1 = try PAL.Color(name: "c1", rgbHexString: "1122FE")
			XCTAssertEqual(c1.colorSpace, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3)
			XCTAssertEqual(c1.colorComponents[0], 0.06666, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], 0.13333, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], 0.99607, accuracy: 0.00001)
		}
		
		do {
			let c1 = try PAL.Color(name: "c1", rgbHexString: "#54efaa11")
			XCTAssertEqual(c1.colorSpace, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3) // alpha is stripped
			XCTAssertEqual(c1.colorComponents[0], 0.32941, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], 0.93725, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], 0.66666, accuracy: 0.00001)
		}
	}
	
	func testColorInitHexInvalid() throws {
		do {
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbHexString: "1122F"))
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbHexString: "1122FEE"))
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbHexString: "#1SS122F"))
			
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbHexString: "#1122FE"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbHexString: "1122FE"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbHexString: "#5e34"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbHexString: "5e34"))
		}
		
		do {
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbHexString: "1122F"))
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbHexString: "#1SS122Faa"))
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbHexString: "E1122FE23"))
			
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbHexString: "#1122FE23"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbHexString: "1122FE32"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbHexString: "#1122FEaa"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbHexString: "1122FEaa"))
		}
	}
}
