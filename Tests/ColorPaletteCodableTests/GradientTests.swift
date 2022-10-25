@testable import ColorPaletteCodable
import XCTest

import Foundation

class GradientTests: XCTestCase {

	func testBasic() throws {
		let gradient = PAL.Gradient(
			name: "first",
			colors: [
				try PAL.Color(rgbHexString: "#FFFFFFFF"),
				try PAL.Color(rgbHexString: "#444444FF"),
				try PAL.Color(rgbHexString: "#000000FF")
			]
		)

		XCTAssertEqual("first", gradient.name)
		XCTAssertEqual(3, gradient.stops.count)
		XCTAssertEqual(0, gradient.stops[0].position)
		XCTAssertEqual("#ffffffff", gradient.stops[0].color.hexRGBA)
		XCTAssertEqual(0.5, gradient.stops[1].position)
		XCTAssertEqual("#444444ff", gradient.stops[1].color.hexRGBA)
		XCTAssertEqual(1.0, gradient.stops[2].position)
		XCTAssertEqual("#000000ff", gradient.stops[2].color.hexRGBA)

		let coder = PAL.Gradient.Coder.JSON()
		let g1 = try coder.encode(gradient)
		let gradient2 = try PAL.Gradient.Decode(from: g1, fileExtension: coder.fileExtension)

		XCTAssertEqual("first", gradient2.name)
		XCTAssertEqual(3, gradient2.stops.count)
		XCTAssertEqual(0, gradient2.stops[0].position)
		XCTAssertEqual("#ffffffff", gradient2.stops[0].color.hexRGBA)
		XCTAssertEqual(0.5, gradient2.stops[1].position)
		XCTAssertEqual("#444444ff", gradient2.stops[1].color.hexRGBA)
		XCTAssertEqual(1.0, gradient2.stops[2].position)
		XCTAssertEqual("#000000ff", gradient2.stops[2].color.hexRGBA)
	}


	func testBasicWithNoName() throws {
		let gradient = PAL.Gradient(
			colors: [
				try PAL.Color(rgbHexString: "#FFFFFFFF"),
				try PAL.Color(rgbHexString: "#444444FF"),
				try PAL.Color(rgbHexString: "#000000FF")
			]
		)

		XCTAssertEqual(3, gradient.stops.count)
		XCTAssertEqual(0, gradient.stops[0].position)
		XCTAssertEqual("#ffffffff", gradient.stops[0].color.hexRGBA)
		XCTAssertEqual(0.5, gradient.stops[1].position)
		XCTAssertEqual("#444444ff", gradient.stops[1].color.hexRGBA)
		XCTAssertEqual(1.0, gradient.stops[2].position)
		XCTAssertEqual("#000000ff", gradient.stops[2].color.hexRGBA)

		// Encode
		let format = PAL.Gradient.Coder.JSON.fileExtension
		let coder = try XCTUnwrap(PAL.Gradient.coder(for: format))
		let g1 = try coder.encode(gradient)

		// Decode
		let gradient2 = try PAL.Gradient.Decode(from: g1, fileExtension: format)

		XCTAssertNil(gradient2.name)
		XCTAssertEqual(3, gradient2.stops.count)
		XCTAssertEqual(0, gradient2.stops[0].position)
		XCTAssertEqual("#ffffffff", gradient2.stops[0].color.hexRGBA)
		XCTAssertEqual(0.5, gradient2.stops[1].position)
		XCTAssertEqual("#444444ff", gradient2.stops[1].color.hexRGBA)
		XCTAssertEqual(1.0, gradient2.stops[2].position)
		XCTAssertEqual("#000000ff", gradient2.stops[2].color.hexRGBA)
	}

	func testUnordered() throws {
		let gradient = PAL.Gradient(
			colors: [
				try PAL.Color(rgbHexString: "#FFFFFF"),
				try PAL.Color(rgbHexString: "#444444"),
				try PAL.Color(rgbHexString: "#000000")
			],
			positions: [0.2, 1, 0]
		).sorted

		// Positions should be ordered once the gradient is created

		XCTAssertEqual(3, gradient.stops.count)
		XCTAssertEqual(0, gradient.stops[0].position)
		XCTAssertEqual("#000000", gradient.stops[0].color.hexRGB)
		XCTAssertEqual(0.2, gradient.stops[1].position)
		XCTAssertEqual("#ffffff", gradient.stops[1].color.hexRGB)
		XCTAssertEqual(1.0, gradient.stops[2].position)
		XCTAssertEqual("#444444", gradient.stops[2].color.hexRGB)
	}

	func testUnnormalized() throws {
		let gradient = PAL.Gradient(
			colors: [
				try PAL.Color(rgbHexString: "#FFFFFF"),
				try PAL.Color(rgbHexString: "#121212"),
				try PAL.Color(rgbHexString: "#444444"),
				try PAL.Color(rgbHexString: "#000000")
			],
			positions: [100, 0, 5, 85]
		)

		let normalized = try gradient.normalized()

		// Positions should be ordered once the gradient is created, and the
		// positions should be normalized between 0 -> 1

		XCTAssertEqual(4, normalized.stops.count)

		XCTAssertEqual(0, normalized.stops[0].position)
		XCTAssertEqual("#121212", normalized.stops[0].color.hexRGB)
		XCTAssertEqual(0.05, normalized.stops[1].position)
		XCTAssertEqual("#444444", normalized.stops[1].color.hexRGB)
		XCTAssertEqual(0.85, normalized.stops[2].position)
		XCTAssertEqual("#000000", normalized.stops[2].color.hexRGB)
		XCTAssertEqual(1.0, normalized.stops[3].position)
		XCTAssertEqual("#ffffff", normalized.stops[3].color.hexRGB)
	}

	func testUnnormalizedNonZeroed() throws {
		let gradient = PAL.Gradient(
			colors: [
				try PAL.Color(rgbHexString: "#FFFFFF"),
				try PAL.Color(rgbHexString: "#121212"),
				try PAL.Color(rgbHexString: "#444444")
			],
			positions: [60, 45, 30]
		)

		let normalized = try gradient.normalized()

		// Positions should be ordered once the gradient is created, and the
		// positions should be normalized between 0 -> 1

		XCTAssertNil(gradient.name)

		XCTAssertEqual(3, gradient.stops.count)

		XCTAssertEqual(0, normalized.stops[0].position)
		XCTAssertEqual("#444444", normalized.stops[0].color.hexRGB)
		XCTAssertEqual(0.5, normalized.stops[1].position, accuracy: 4)
		XCTAssertEqual("#121212", normalized.stops[1].color.hexRGB)
		XCTAssertEqual(1.0, normalized.stops[2].position)
		XCTAssertEqual("#ffffff", normalized.stops[2].color.hexRGB)
	}

	func testDumbAssertion() throws {
		let gradient = PAL.Gradient(colorPositions: [
			(20, try PAL.Color(rgbHexString: "#FFFFFF")),
			(20, try PAL.Color(rgbHexString: "#000000")),
		])

		XCTAssertThrowsError(try gradient.normalized())
	}

	func testGradientFromPalette() throws {
		let paletteData = """
			GIMP Palette
			Name: mona
			#Description:
			#Colors: 6
			91	64	78	5b404e
			119	90	95	775a5f
			142	116	112	8e7470
			172	155	144	ac9b90
			210	204	184	d2ccb8
			238	238	225	eeeee1
			"""
		let data = paletteData.data(using: .utf8)!
		let palette = try PAL.Coder.GIMP().decode(from: data)

		let gradient = PAL.Gradient(palette: palette)

		XCTAssertEqual("mona", gradient.name)
		XCTAssertEqual(6, gradient.stops.count)

		XCTAssertEqual("#5b404e", gradient.stops[0].color.hexRGB)
		XCTAssertEqual(0, gradient.stops[0].position, accuracy: 0.01)
		XCTAssertEqual("#775a5f", gradient.stops[1].color.hexRGB)
		XCTAssertEqual(0.2, gradient.stops[1].position, accuracy: 0.01)
		XCTAssertEqual("#8e7470", gradient.stops[2].color.hexRGB)
		XCTAssertEqual(0.4, gradient.stops[2].position, accuracy: 0.01)
		XCTAssertEqual("#ac9b90", gradient.stops[3].color.hexRGB)
		XCTAssertEqual(0.6, gradient.stops[3].position, accuracy: 0.01)
		XCTAssertEqual("#d2ccb8", gradient.stops[4].color.hexRGB)
		XCTAssertEqual(0.8, gradient.stops[4].position, accuracy: 0.01)
		XCTAssertEqual("#eeeee1", gradient.stops[5].color.hexRGB)
		XCTAssertEqual(1, gradient.stops[5].position, accuracy: 0.01)
	}
}

class GGRGradientTests: XCTestCase {
	func testBasicLoadUnsupported() throws {
			let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "Pastel_Rainbow", withExtension: "ggr"))
			let content = try Data(contentsOf: fileURL)

			let dec = PAL.Gradient.Coder.GGR()
			_ = try XCTAssertThrowsError(dec.decode(from: content))
	}

	func testBasicLoad() throws {
		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "Skyline", withExtension: "ggr"))
		let content = try Data(contentsOf: fileURL)

		let dec = PAL.Gradient.Coder.GGR()
		let gradient = try dec.decode(from: content)

		XCTAssertEqual("Skyline", gradient.name)
		XCTAssertEqual(7, gradient.stops.count)

		#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
		do {
			let image = gradient.image(size: CGSize(width: 500, height: 25))
			XCTAssertNotNil(image)
		}
		#endif
	}

	func testLoadJSONGradient() throws {
		do {
			let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "skyline", withExtension: "jsoncolorgradient"))
			let content = try Data(contentsOf: fileURL)

			let dec = PAL.Gradient.Coder.JSON()
			let gradient = try dec.decode(from: content)

			XCTAssertEqual("Skyline", gradient.name)
			XCTAssertEqual(7, gradient.stops.count)
		}

		do {
			let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "simple2", withExtension: "jsoncolorgradient"))
			let content = try Data(contentsOf: fileURL)

			let dec = PAL.Gradient.Coder.JSON()
			let gradient = try dec.decode(from: content)

			XCTAssertEqual(nil, gradient.name)
			XCTAssertEqual(2, gradient.stops.count)
		}

		do {
			let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "basic3pos", withExtension: "jsoncolorgradient"))
			let content = try Data(contentsOf: fileURL)

			let dec = PAL.Gradient.Coder.JSON()
			let gradient = try dec.decode(from: content)

			XCTAssertEqual("alphablurry!", gradient.name)
			XCTAssertEqual(3, gradient.stops.count)
		}
	}

	func testBasicLoad2() throws {
		do {
			let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "Tube_Red", withExtension: "ggr"))
			let content = try Data(contentsOf: fileURL)

			let dec = PAL.Gradient.Coder.GGR()
			let gradient = try dec.decode(from: content)

			XCTAssertEqual("Tube Red", gradient.name)
			XCTAssertEqual(10, gradient.stops.count)

			#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
			do {
				let image = gradient.image(size: CGSize(width: 500, height: 25))
				XCTAssertNotNil(image)
			}
			#endif
		}
		do {
			let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "colorcube", withExtension: "ggr"))
			let content = try Data(contentsOf: fileURL)

			let dec = PAL.Gradient.Coder.GGR()
			let gradient = try dec.decode(from: content)

			XCTAssertEqual("colorcube", gradient.name)
			XCTAssertEqual(64, gradient.stops.count)

			#if os(macOS) || os(iOS) || os(tvOS)
			do {
				let image = gradient.image(size: CGSize(width: 500, height: 25))
				XCTAssertNotNil(image)
			}
			#endif
		}
	}


	func testBasicEncode() throws {
		let dec = PAL.Gradient.Coder.GGR()

		do {
			let gradient = PAL.Gradient(colorPositions: [
				(position: 0.0, color: PAL.Color.red),
				(position: 1.0, color: PAL.Color.white),
			])
			let out = try XCTUnwrap(try? dec.encode(gradient))
//			let outStr = String(data: out, encoding: .utf8)
//			Swift.print(outStr)

			let gradient2 = try dec.decode(from: out)
			XCTAssertEqual("", gradient2.name)
			XCTAssertEqual(2, gradient2.stops.count)

		}
		do {
			let gradient = PAL.Gradient(
				name: "alphablurry!",
				colorPositions: [
					(position: 0.0, color: try PAL.Color.blue.withAlpha(0.1)),
					(position: 0.2, color: PAL.Color.white),
					(position: 1.0, color: try PAL.Color.green.withAlpha(0.8)),
				]
			)

			#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
			do {
				let image = gradient.image(size: CGSize(width: 500, height: 25))
				XCTAssertNotNil(image)
			}
			#endif

			let out = try XCTUnwrap(try? dec.encode(gradient))
//			let outStr = String(data: out, encoding: .utf8)
//			Swift.print(outStr)

			let gradient2 = try dec.decode(from: out)
			XCTAssertEqual("alphablurry!", gradient2.name)
			XCTAssertEqual(3, gradient2.stops.count)
		}
	}
}
