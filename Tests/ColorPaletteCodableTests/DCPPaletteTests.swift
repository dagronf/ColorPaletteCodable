@testable import ColorPaletteCodable
import XCTest

final class DCPPaletteTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}


	func testBasicRoundTrip() throws {

		let c = PAL.Coder.DCP()

		var palette = PAL.Palette()
		let c1 = try PAL.Color(colorSpace: .RGB, colorComponents: [1, 0, 0], name: "red")
		let c2 = try PAL.Color(colorSpace: .RGB, colorComponents: [0, 1, 0], name: "green")
		let c3 = try PAL.Color(colorSpace: .RGB, colorComponents: [0, 0, 1], name: "blue")
		palette.colors.append(contentsOf: [c1, c2, c3])

		let d = try c.encode(palette)
		let cd = try c.decode(from: d)

		XCTAssertEqual(palette, cd)
	}

	func testBasicRoundTripEmojiNames() throws {

		let c = PAL.Coder.DCP()

		var palette = PAL.Palette()
		palette.name = "🫥 Spooky stuff パレット"
		let c1 = try PAL.Color(colorSpace: .RGB, colorComponents: [1, 0, 0], alpha: 0.5, name: "red 🔴", colorType: .global)
		let c2 = try PAL.Color(colorSpace: .RGB, colorComponents: [0, 1, 0], alpha: 0.98, name: "green 🧩", colorType: .spot)
		let c3 = try PAL.Color(colorSpace: .RGB, colorComponents: [0, 0, 1], alpha: 0.12, name: "blue 🐋", colorType: .normal)
		palette.colors.append(contentsOf: [c1, c2, c3])

		let data = try c.encode(palette)
		let decoded = try c.decode(from: data)

		XCTAssertEqual(palette, decoded)
		XCTAssertEqual(0.5, decoded.colors[0].alpha)
		XCTAssertEqual(PAL.ColorType.spot, decoded.colors[1].colorType)
		XCTAssertEqual("blue 🐋", decoded.colors[2].name)
	}

	func testMoreBasicRoundTrip() throws {
		let palette = try loadResourcePalette(named: "Default.gpl")

		let coder = PAL.Coder.DCP()
		let data = try coder.encode(palette)
		let decoded = try coder.decode(from: data)
		XCTAssertEqual(palette, decoded)
	}

	func testMultipleGroupPaletteRoundTrip() throws {
		let palette = try loadResourcePalette(named: "24 colour palettes.ase")

		let coder = PAL.Coder.DCP()
		let data = try coder.encode(palette)
		let decoded = try coder.decode(from: data)
		XCTAssertEqual(palette, decoded)

		XCTAssertEqual(0, decoded.colors.count)
		XCTAssertEqual(24, decoded.groups.count)
	}

	func testCMYK() throws {
		let palette = try loadResourcePalette(named: "ADG3-CMYK.ase")

		let coder = PAL.Coder.DCP()
		let data = try coder.encode(palette)
		let decoded = try coder.decode(from: data)
		XCTAssertEqual(palette, decoded)

		XCTAssertEqual(0, decoded.colors.count)
		XCTAssertEqual(7, decoded.groups.count)
	}
}
