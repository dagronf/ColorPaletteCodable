@testable import ColorPaletteCodable
import XCTest

let ase_resources = [
	"wisteric-17.ase",
	"Ultra-Mattes Reverse.ase",
	"control.ase",
	"Big-Red-Barn.ase",
	"24 colour palettes.ase", // has multiple groups
	"palette_complex.ase",
	"palette_pantones.ase",
	"palette_simple.ase",
	"1629367375_iColorpalette.ase",
	"sw-colors-name-ede-ase.ase",
	"zenit-241.ase",
	"color-cubes.ase",
	"ADG3-CMYK.ase",
]

final class ASEPaletteTests: XCTestCase {
	func testWriteReadRoundTripSampleFiles() throws {
		// Loop through all the resource files
		Swift.print("Round-tripping ASE files...'")
		
		let coder = try XCTUnwrap(PAL.Palette.firstCoder(for: "ase"))
		
		for name in ase_resources {
			Swift.print("Validating '\(name)...'")

			let origData = try loadResourceData(named: name)

			// Attempt to load the ase file
			let palette = try loadResourcePalette(named: name)

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
		let origData = try loadResourceData(named: "control.ase")
		let palette = try loadResourcePalette(named: "control.ase")
		let paletteCoder = try XCTUnwrap(PAL.Palette.firstCoder(for: "ase"))

		let data = try paletteCoder.encode(palette)
		XCTAssertEqual(origData, data)
		let reconstitutedPalette = try paletteCoder.decode(from: data)
		XCTAssertEqual(palette, reconstitutedPalette)
	}
	
	func testSimpleLoad() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.firstCoder(for: "ase"))

		let controlASE = try resourceURL(for: "control.ase")
		let palette = try paletteCoder.decode(from: controlASE)
		
		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(1, palette.groups.count)
		XCTAssertEqual(2, palette.groups[0].colors.count)
	}
	
	func testNextUltraMattes() throws {
		let palette = try loadResourcePalette(named: "Ultra-Mattes Reverse.ase")
		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(1, palette.groups.count)
		XCTAssertEqual("Ultra-Mattes Reverse", palette.groups[0].name)
	}
	
	func testNextWisteric() throws {
		let palette = try loadResourcePalette(named: "wisteric-17.ase")
		XCTAssertEqual(0, palette.groups.count)
		XCTAssertEqual(17, palette.colors.count)
	}
	
	func testMulti() throws {
		let palette = try loadResourcePalette(named: "24 colour palettes.ase")
		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(24, palette.groups.count)
		XCTAssertEqual("PB 3dmaneu chinese umbrellas", palette.groups[0].name)
		XCTAssertEqual(5, palette.groups[0].colors.count)
		XCTAssertEqual("R=55 G=141 B=190", palette.groups[0].colors[0].name)
	}
	
	func testWriteRead() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.firstCoder(for: "ase"))
		
		do {
			let palette = try loadResourcePalette(named: "control.ase", using: paletteCoder)

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
		let paletteCoder = try XCTUnwrap(PAL.Palette.firstCoder(for: "ase"))
		
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
			XCTAssertEqual("#523b50", try palette.groups[0].colors[0].hexRGB(hashmark: true))
			XCTAssertEqual("#b0ac89", try palette.groups[0].colors[1].hexRGB(hashmark: true))
			XCTAssertEqual("#815d72", try palette.groups[0].colors[2].hexRGB(hashmark: true))
			XCTAssertEqual("#a9b650", try palette.groups[0].colors[3].hexRGB(hashmark: true))
			XCTAssertEqual("#ebede9", try palette.groups[0].colors[4].hexRGB(hashmark: true))
		}
	}
	
	func testColorInit() throws {
		do {
			let c1 = try PAL.Color(name: "c1", rgbaHexString: "1122FE")
			XCTAssertEqual(c1.colorSpace, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3)
			XCTAssertEqual(c1.colorComponents[0], 0.06666, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], 0.13333, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], 0.99607, accuracy: 0.00001)
		}
		
		do {
			let c1 = try PAL.Color(name: "c1", rgbaHexString: "#54efaa11")
			XCTAssertEqual(c1.colorSpace, .RGB)
			XCTAssertEqual(c1.colorComponents.count, 3) // alpha is stripped
			XCTAssertEqual(c1.colorComponents[0], 0.32941, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[1], 0.93725, accuracy: 0.00001)
			XCTAssertEqual(c1.colorComponents[2], 0.66666, accuracy: 0.00001)
		}
	}
	
	func testColorInitHexInvalid() throws {
		do {
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbaHexString: "1122F"))
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbaHexString: "1122FEE"))
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbaHexString: "#1SS122F"))
			
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbaHexString: "#1122FE"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbaHexString: "1122FE"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbaHexString: "#5e34"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbaHexString: "5e34"))
		}
		
		do {
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbaHexString: "1122F"))
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbaHexString: "#1SS122Faa"))
			XCTAssertThrowsError(try PAL.Color(name: "c1", rgbaHexString: "E1122FE23"))
			
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbaHexString: "#1122FE23"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbaHexString: "1122FE32"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbaHexString: "#1122FEaa"))
			XCTAssertNoThrow(try PAL.Color(name: "c1", rgbaHexString: "1122FEaa"))
		}
	}
}
