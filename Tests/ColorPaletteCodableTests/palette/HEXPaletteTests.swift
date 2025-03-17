@testable import ColorPaletteCodable
import XCTest

final class HEXPaletteTests: XCTestCase {
	let hexResources: [(name: String, count: Int)] = [
		("pear36.hex", 36),
		("pear36-transparency.hex", 36),
		("behr.hex", 4696),
	]

	func testLoading() throws {
		for item in hexResources {
			let swatches = try loadResourcePalette(named: item.name, using: PAL.Coder.HEX())
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
		let palette = try loadResourcePalette(named: "pear36-transparency.hex", using: PAL.Coder.HEX())
		XCTAssertEqual(palette.format, .hexRGBA)
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
			XCTAssertEqual(try v1p.colors[0].hexRGBA(hashmark: false), "aabbccdd")
			XCTAssertEqual(try v1p.colors[1].hexRGBA(hashmark: false), "11223344")

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
			XCTAssertEqual(try v1p.colors[0].hexRGB(hashmark: false), "aabbcc")
			XCTAssertEqual(try v1p.colors[1].hexRGB(hashmark: false), "445566")

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
			XCTAssertEqual(try v1p.colors[0].hexRGBA(hashmark: false), "aabbccdd")
			XCTAssertEqual(try v1p.colors[1].hexRGBA(hashmark: false), "11223344")
			XCTAssertEqual(try v1p.colors[2].hexRGBA(hashmark: false), "ff2389ff")

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
			XCTAssertEqual(try v1p.colors[0].hexRGBA(hashmark: false), "aabbccdd")
			XCTAssertEqual(try v1p.colors[1].hexRGBA(hashmark: false), "11223344")
			XCTAssertEqual(try v1p.colors[2].hexRGBA(hashmark: false), "ff2389ff")

			let content = String(data: try PAL.Coder.HEX().encode(v1p), encoding: .utf8)
			XCTAssertEqual(content, "#aabbccdd\n#11223344\n#ff2389\n")
		}
	}
}
