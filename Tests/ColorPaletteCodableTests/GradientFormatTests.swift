//
//  GGRGradientTests.swift
//  
//
//  Created by Darren Ford on 31/7/2023.
//

import XCTest
import ColorPaletteCodable

class GradientFormatTests: XCTestCase {
	func testBasicLoadUnsupported() throws {
		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "Pastel_Rainbow", withExtension: "ggr"))
		let content = try Data(contentsOf: fileURL)

		let dec = PAL.Gradients.Coder.GGR()
		_ = try XCTAssertThrowsError(dec.decode(from: content))
	}

	func testBasicLoad() throws {
		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "Skyline", withExtension: "ggr"))
		let content = try Data(contentsOf: fileURL)

		let dec = PAL.Gradients.Coder.GGR()
		let gradients = try dec.decode(from: content)

		XCTAssertEqual(1, gradients.count)
		let gradient = gradients.gradients[0]

		XCTAssertEqual("Skyline", gradient.name)
		XCTAssertEqual(7, gradient.stops.count)

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
		do {
			let image = gradient.image(size: CGSize(width: 500, height: 25))
			XCTAssertNotNil(image)
		}
#endif
	}

	func testLoadJSONGradient1() throws {
		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "skyline", withExtension: "jsoncolorgradient"))
		let content = try Data(contentsOf: fileURL)

		let dec = PAL.Gradients.Coder.JSON()
		let gradients = try dec.decode(from: content)

		XCTAssertEqual(1, gradients.count)
		let gradient = gradients.gradients[0]

		XCTAssertEqual("Skyline", gradient.name)
		XCTAssertEqual(7, gradient.stops.count)
	}

	func testLoadJSONGradient2() throws {
		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "simple2", withExtension: "jsoncolorgradient"))
		let content = try Data(contentsOf: fileURL)

		let dec = PAL.Gradients.Coder.JSON()
		let gradients = try dec.decode(from: content)

		XCTAssertEqual(1, gradients.count)
		let gradient = gradients.gradients[0]

		XCTAssertEqual(nil, gradient.name)
		XCTAssertEqual(2, gradient.stops.count)
	}

	func testLoadJSONGradient3() throws {
		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "basic3pos", withExtension: "jsoncolorgradient"))
		let content = try Data(contentsOf: fileURL)

		let dec = PAL.Gradients.Coder.JSON()
		let gradients = try dec.decode(from: content)

		XCTAssertEqual(1, gradients.count)
		let gradient = gradients.gradients[0]

		XCTAssertEqual("alphablurry!", gradient.name)
		XCTAssertEqual(3, gradient.stops.count)
	}

	func testBasicLoad2() throws {
		do {
			let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "Tube_Red", withExtension: "ggr"))
			let content = try Data(contentsOf: fileURL)

			let dec = PAL.Gradients.Coder.GGR()
			let gradients = try dec.decode(from: content)

			XCTAssertEqual(1, gradients.count)
			let gradient = gradients.gradients[0]

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

			let dec = PAL.Gradients.Coder.GGR()
			let gradients = try dec.decode(from: content)

			XCTAssertEqual(1, gradients.count)
			let gradient = gradients.gradients[0]

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

	func testLargeGGRgradient() throws {
		let gradient = try loadResourceGradient(named: "39_rainbow_white.ggr")
		XCTAssertEqual(gradient.count, 1)
		let g1 = gradient.gradients[0]

		// Because each line in the file generates two color stops
		XCTAssertEqual(g1.colors.count, 237 * 2)
	}

	func testBasicEncode() throws {
		let dec = PAL.Gradients.Coder.GGR()

		do {
			let gradient = PAL.Gradient(colorPositions: [
				(position: 0.0, color: PAL.Color.red),
				(position: 1.0, color: PAL.Color.white),
			])
			let gradients = PAL.Gradients(gradients: [gradient])
			let out = try XCTUnwrap(try? dec.encode(gradients))
			//			let outStr = String(data: out, encoding: .utf8)
			//			Swift.print(outStr)

			let gradients2 = try dec.decode(from: out)
			XCTAssertEqual(1, gradients2.count)
			let gradient2 = gradients2.gradients[0]

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

			let gradients = PAL.Gradients(gradients: [gradient])
			let out = try XCTUnwrap(try? dec.encode(gradients))
			//			let outStr = String(data: out, encoding: .utf8)
			//			Swift.print(outStr)

			let gradients2 = try dec.decode(from: out)
			XCTAssertEqual(1, gradients2.count)
			let gradient2 = gradients2.gradients[0]
			XCTAssertEqual("alphablurry!", gradient2.name)
			XCTAssertEqual(3, gradient2.stops.count)
		}
	}

	func testGRD1() throws {
		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "my-custom-gradient-3-rgb", withExtension: "grd"))
		let i = InputStream(url: fileURL)!
		i.open()
		let grad1 = try PAL.Gradients.Coder.GRD().decode(from: i)
		XCTAssertEqual(1, grad1.count)
		let gradient = grad1.gradients[0]
		let palette = gradient.palette
		XCTAssertEqual(4, palette.colors.count)
	}

	func testGRD2() throws {
		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "35", withExtension: "grd"))
		let i = InputStream(url: fileURL)!
		i.open()
		let grad1 = try PAL.Gradients.Coder.GRD().decode(from: i)

		// There are 10 gradients in this file
		XCTAssertEqual(10, grad1.count)

		let palette = grad1.palette
		XCTAssertEqual(0, palette.colors.count)
		XCTAssertEqual(10, palette.groups.count)
	}

	func testpspgradient() throws {
		let gradients = try loadResourceGradient(named: "temperature.pspgradient")
		XCTAssertEqual(1, gradients.count)
		let g1 = gradients.gradients[0]
		XCTAssertEqual(36, g1.colors.count)
	}

	func testsvggradientexport() throws {
		do {
			// Make sure we don't attempt to load an SVG. (we can't read them yet)
			let dummy = InputStream(data: Data())
			let _ = XCTAssertThrowsError(try PAL.Gradients.Coder.SVG().decode(from: dummy))
		}

		do {
			let gradients = try loadResourceGradient(named: "temperature.pspgradient")
			XCTAssertEqual(1, gradients.count)
			let g1 = gradients.gradients[0]
			XCTAssertEqual(36, g1.colors.count)

			let grad1 = try PAL.Gradients.Coder.SVG().encode(gradients)
			XCTAssertGreaterThan(grad1.count, 0)

			// Generate test compare data
			//try grad1.write(to: URL(fileURLWithPath: "/tmp/temperature.pspgradient.svg"))

			let compareData = try loadResourceData(named: "temperature.pspgradient.svg")
			XCTAssertEqual(compareData, grad1)
		}

		do {
			let gradients = try loadResourceGradient(named: "35.grd")
			XCTAssertEqual(10, gradients.count)
			let g1 = gradients.gradients[0]
			XCTAssertEqual(4, g1.colors.count)

			let grad1 = try PAL.Gradients.Coder.SVG().encode(gradients)
			XCTAssertGreaterThan(grad1.count, 0)

			// Generate test compare data
			try grad1.write(to: URL(fileURLWithPath: "/tmp/35.grd.svg"))

			#if os(macOS)
			let compareData = try loadResourceData(named: "35.grd.svg")
			XCTAssertEqual(compareData, grad1)
			#endif
		}

		do {
			let gradients = try loadResourceGradient(named: "skyline.jsoncolorgradient")
			XCTAssertEqual(1, gradients.count)
			let g1 = gradients.gradients[0]
			XCTAssertEqual(7, g1.colors.count)

			let grad1 = try PAL.Gradients.Coder.SVG().encode(gradients)
			XCTAssertGreaterThan(grad1.count, 0)

			// Generate test compare data
			//try grad1.write(to: URL(fileURLWithPath: "/tmp/skyline.jsoncolorgradient.svg"))

			#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
			let compareData = try loadResourceData(named: "skyline.jsoncolorgradient.svg")
			XCTAssertEqual(compareData, grad1)
			#endif
		}
	}
}
