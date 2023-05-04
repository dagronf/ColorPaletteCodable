@testable import ColorPaletteCodable
import XCTest

final class HEXPaletteTests: XCTestCase {
	let hexResources: [(name: String, count: Int)] = [
		("pear36", 36),
		("pear36-transparency", 36),
		("behr", 4696),
	]

	private func loadPalette(_ name: String) throws -> PAL.Palette {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "hex"))
		return try PAL.Coder.HEX().decode(from: paletteURL)
	}

	func testLoading() throws {
		for item in hexResources {
			let swatches = try loadPalette(item.name)
			XCTAssertEqual(item.count, swatches.allColors().count)

			// Encode
			let encoded = try PAL.Coder.HEX().encode(swatches)

			// Decode
			let decoded = try PAL.Coder.HEX().decode(from: encoded)

			// Check that the palettes match
			XCTAssertEqual(decoded, swatches)
		}
	}

	func testLoadingAlpha() throws {
		let palette = try loadPalette("pear36-transparency")

		XCTAssertEqual(36, palette.colors.count)

		let color1 = palette.colors[0]
		let color2 = palette.colors[1]
		XCTAssertEqual(0.7333, color1.alpha, accuracy: 0.001)
		XCTAssertEqual(0.7333, color2.alpha, accuracy: 0.001)
	}

	func testBasicReadFormats() throws {

		do {
			let v1 =
"""
#AABBCCDD, #11223344
"""
			let v1p = try PAL.Coder.HEX().decode(from: v1.data(using: .utf8)!)
			XCTAssertEqual(2, v1p.colors.count)
			XCTAssertEqual(v1p.colors[0].rawHexRGBA, "aabbccdd")
			XCTAssertEqual(v1p.colors[1].rawHexRGBA, "11223344")

			let content = String(data: try PAL.Coder.HEX().encode(v1p), encoding: .utf8)
			XCTAssertEqual(content, "#aabbccdd\n#11223344\n")

		}

		do {
			let v1 =
"""
#abc,#456
"""
			let v1p = try PAL.Coder.HEX().decode(from: v1.data(using: .utf8)!)
			XCTAssertEqual(2, v1p.colors.count)
			XCTAssertEqual(v1p.colors[0].rawHexRGB, "aabbcc")
			XCTAssertEqual(v1p.colors[1].rawHexRGB, "445566")

			let content = String(data: try PAL.Coder.HEX().encode(v1p), encoding: .utf8)
			XCTAssertEqual(content, "#aabbcc\n#445566\n")
		}

		do {
			let v1 =
"""
#AABBCCDD
#11223344
ff2389
"""
			let v1p = try PAL.Coder.HEX().decode(from: v1.data(using: .utf8)!)
			XCTAssertEqual(3, v1p.colors.count)
			XCTAssertEqual(v1p.colors[0].rawHexRGBA, "aabbccdd")
			XCTAssertEqual(v1p.colors[1].rawHexRGBA, "11223344")
			XCTAssertEqual(v1p.colors[2].rawHexRGBA, "ff2389ff")

			let content = String(data: try PAL.Coder.HEX().encode(v1p), encoding: .utf8)
			XCTAssertEqual(content, "#aabbccdd\n#11223344\n#ff2389\n")
		}

		do {
			let v1 =
"""
AABBCCDD;11223344;ff2389
"""
			let v1p = try PAL.Coder.HEX().decode(from: v1.data(using: .utf8)!)
			XCTAssertEqual(3, v1p.colors.count)
			XCTAssertEqual(v1p.colors[0].rawHexRGBA, "aabbccdd")
			XCTAssertEqual(v1p.colors[1].rawHexRGBA, "11223344")
			XCTAssertEqual(v1p.colors[2].rawHexRGBA, "ff2389ff")

			let content = String(data: try PAL.Coder.HEX().encode(v1p), encoding: .utf8)
			XCTAssertEqual(content, "#aabbccdd\n#11223344\n#ff2389\n")
		}
	}
}
