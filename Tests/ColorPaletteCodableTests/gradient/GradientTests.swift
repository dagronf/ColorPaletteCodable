@testable import ColorPaletteCodable
import XCTest

import Foundation

let gradientTestsFolder = try! testResultsContainer.subfolder(with: "gradient-tests")

class GradientTests: XCTestCase {

	func testDoco() throws {
		/// Load gradients from a file, (using the fileURL to determine the gradients type)
		let fileURL = try resourceURL(for: "37_waves.cpt")
		let gradients = try PAL.Gradients(fileURL)
		XCTAssertEqual(1, gradients.count)
		XCTAssertEqual(.colorPaletteTables, gradients.format)
		XCTAssertEqual(1, gradients.gradients.count)
		XCTAssertEqual(508, gradients.gradients[0].stops.count)

		/// Load gradients by specifying the type
		let data = try dataURL(for: "37_waves.cpt")
		let gradients2 = try PAL.Gradients(data, format: .colorPaletteTables)
		XCTAssertEqual(1, gradients2.count)
		XCTAssertEqual(1, gradients2.gradients.count)
		XCTAssertEqual(508, gradients2.gradients[0].stops.count)

		/// Save a gradient file
		let fileData = try gradients.export(format: .dcg)
		let decoded = try PAL.Gradients(fileData, fileExtension: "dcg")
		XCTAssertEqual(1, decoded.count)
		XCTAssertEqual(.dcg, decoded.format)
		XCTAssertEqual(1, decoded.gradients.count)
		XCTAssertEqual(508, decoded.gradients[0].stops.count)

		/// Save a gradient file
		let fileData2 = try gradients.export(format: .dcg)
		let decoded2 = try PAL.Gradients(fileData2, format: .dcg)
		XCTAssertEqual(1, decoded2.count)
		XCTAssertEqual(1, decoded2.gradients.count)
		XCTAssertEqual(508, decoded2.gradients[0].stops.count)

		do {
			let coder = PAL.Gradients.Coder.ColorPaletteTablesCoder()
			let gradients2 = try coder.decode(from: fileURL)
			XCTAssertEqual(1, gradients2.count)
			XCTAssertEqual(1, gradients2.gradients.count)
			XCTAssertEqual(508, gradients2.gradients[0].stops.count)
		}
	}

	func testBasic() throws {
		let gradient = PAL.Gradient(
			colors: [
				try PAL.Color(rgbHexString: "#FFFFFFFF", format: .rgba),
				try PAL.Color(rgbHexString: "#444444FF", format: .rgba),
				try PAL.Color(rgbHexString: "#000000FF", format: .rgba)
			],
			name: "first"
		)

		XCTAssertEqual("first", gradient.name)
		XCTAssertEqual(3, gradient.stops.count)
		XCTAssertEqual(0, gradient.stops[0].position)
		XCTAssertEqual("#ffffffff", try gradient.stops[0].color.hexRGBA(hashmark: true))
		XCTAssertEqual(0.5, gradient.stops[1].position)
		XCTAssertEqual("#444444ff", try gradient.stops[1].color.hexRGBA(hashmark: true))
		XCTAssertEqual(1.0, gradient.stops[2].position)
		XCTAssertEqual("#000000ff", try gradient.stops[2].color.hexRGBA(hashmark: true))

		let gradients = PAL.Gradients(gradients: [gradient])

		let coder = PAL.Gradients.Coder.JSON()
		let g1 = try coder.encode(gradients)
		let gradients2 = try PAL.Gradients.Decode(from: g1, fileExtension: coder.fileExtension)
		XCTAssertEqual(1, gradients2.count)
		let gradient2 = gradients.gradients[0]

		XCTAssertEqual("first", gradient2.name)
		XCTAssertEqual(3, gradient2.stops.count)
		XCTAssertEqual(0, gradient2.stops[0].position)
		XCTAssertEqual("#ffffffff", try gradient2.stops[0].color.hexRGBA(hashmark: true))
		XCTAssertEqual(0.5, gradient2.stops[1].position)
		XCTAssertEqual("#444444ff", try gradient2.stops[1].color.hexRGBA(hashmark: true))
		XCTAssertEqual(1.0, gradient2.stops[2].position)
		XCTAssertEqual("#000000ff", try gradient2.stops[2].color.hexRGBA(hashmark: true))
	}


	func testBasicWithNoName() throws {
		let gradient = PAL.Gradient(
			colors: [
				try PAL.Color(rgbHexString: "#FFFFFFFF", format: .rgba),
				try PAL.Color(rgbHexString: "#444444FF", format: .rgba),
				try PAL.Color(rgbHexString: "#000000FF", format: .rgba)
			]
		)

		XCTAssertEqual(3, gradient.stops.count)
		XCTAssertEqual(0, gradient.stops[0].position)
		XCTAssertEqual("#ffffffff", try gradient.stops[0].color.hexRGBA(hashmark: true))
		XCTAssertEqual(0.5, gradient.stops[1].position)
		XCTAssertEqual("#444444ff", try gradient.stops[1].color.hexRGBA(hashmark: true))
		XCTAssertEqual(1.0, gradient.stops[2].position)
		XCTAssertEqual("#000000ff", try gradient.stops[2].color.hexRGBA(hashmark: true))

		let gradients = PAL.Gradients(gradients: [gradient])

		// Encode
		let format = PAL.Gradients.Coder.JSON.fileExtension
		let coder = try XCTUnwrap(PAL.Gradients.coder(for: format))
		let g1 = try coder.encode(gradients)

		// Decode
		let gradients2 = try PAL.Gradients.Decode(from: g1, fileExtension: format)
		XCTAssertEqual(1, gradients2.count)
		XCTAssertEqual(.json, gradients2.format)
		let gradient2 = gradients.gradients[0]

		XCTAssertNil(gradient2.name)
		XCTAssertEqual(3, gradient2.stops.count)
		XCTAssertEqual(0, gradient2.stops[0].position)
		XCTAssertEqual("#ffffffff", try gradient2.stops[0].color.hexRGBA(hashmark: true))
		XCTAssertEqual(0.5, gradient2.stops[1].position)
		XCTAssertEqual("#444444ff", try gradient2.stops[1].color.hexRGBA(hashmark: true))
		XCTAssertEqual(1.0, gradient2.stops[2].position)
		XCTAssertEqual("#000000ff", try gradient2.stops[2].color.hexRGBA(hashmark: true))
	}

	func testUnordered() throws {
		let gradient = PAL.Gradient(
			colors: [
				try PAL.Color(rgbHexString: "#FFFFFF", format: .rgba),
				try PAL.Color(rgbHexString: "#444444", format: .rgba),
				try PAL.Color(rgbHexString: "#000000", format: .rgba)
			],
			positions: [0.2, 1, 0]
		).sorted

		// Positions should be ordered once the gradient is created

		XCTAssertEqual(3, gradient.stops.count)
		XCTAssertEqual(0, gradient.stops[0].position)
		XCTAssertEqual("#000000", try gradient.stops[0].color.hexRGB(hashmark: true))
		XCTAssertEqual(0.2, gradient.stops[1].position)
		XCTAssertEqual("#ffffff", try gradient.stops[1].color.hexRGB(hashmark: true))
		XCTAssertEqual(1.0, gradient.stops[2].position)
		XCTAssertEqual("#444444", try gradient.stops[2].color.hexRGB(hashmark: true))
	}

	func testUnnormalized() throws {
		let gradient = PAL.Gradient(
			colors: [
				try PAL.Color(rgbHexString: "#FFFFFF", format: .rgba),
				try PAL.Color(rgbHexString: "#121212", format: .rgba),
				try PAL.Color(rgbHexString: "#444444", format: .rgba),
				try PAL.Color(rgbHexString: "#000000", format: .rgba)
			],
			positions: [100, 0, 5, 85]
		)

		let normalized = try gradient.normalized()

		// Positions should be ordered once the gradient is created, and the
		// positions should be normalized between 0 -> 1

		XCTAssertEqual(4, normalized.stops.count)

		XCTAssertEqual(0, normalized.stops[0].position)
		XCTAssertEqual("#121212", try normalized.stops[0].color.hexRGB(hashmark: true))
		XCTAssertEqual(0.05, normalized.stops[1].position)
		XCTAssertEqual("#444444", try normalized.stops[1].color.hexRGB(hashmark: true))
		XCTAssertEqual(0.85, normalized.stops[2].position)
		XCTAssertEqual("#000000", try normalized.stops[2].color.hexRGB(hashmark: true))
		XCTAssertEqual(1.0, normalized.stops[3].position)
		XCTAssertEqual("#ffffff", try normalized.stops[3].color.hexRGB(hashmark: true))
	}

	func testUnnormalizedNonZeroed() throws {
		let gradient = PAL.Gradient(
			colors: [
				try PAL.Color(rgbHexString: "#FFFFFF", format: .rgba),
				try PAL.Color(rgbHexString: "#121212", format: .rgba),
				try PAL.Color(rgbHexString: "#444444", format: .rgba)
			],
			positions: [60, 45, 30]
		)

		let normalized = try gradient.normalized()

		// Positions should be ordered once the gradient is created, and the
		// positions should be normalized between 0 -> 1

		XCTAssertNil(gradient.name)

		XCTAssertEqual(3, gradient.stops.count)

		XCTAssertEqual(0, normalized.stops[0].position)
		XCTAssertEqual("#444444", try normalized.stops[0].color.hexRGB(hashmark: true))
		XCTAssertEqual(0.5, normalized.stops[1].position, accuracy: 4)
		XCTAssertEqual("#121212", try normalized.stops[1].color.hexRGB(hashmark: true))
		XCTAssertEqual(1.0, normalized.stops[2].position)
		XCTAssertEqual("#ffffff", try normalized.stops[2].color.hexRGB(hashmark: true))
	}

	func testDumbAssertion() throws {
		let gradient = PAL.Gradient(colorPositions: [
			(20, try PAL.Color(rgbHexString: "#FFFFFF", format: .rgba)),
			(20, try PAL.Color(rgbHexString: "#000000", format: .rgba)),
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

		XCTAssertEqual("#5b404e", try gradient.stops[0].color.hexRGB(hashmark: true))
		XCTAssertEqual(0, gradient.stops[0].position, accuracy: 0.01)
		XCTAssertEqual("#775a5f", try gradient.stops[1].color.hexRGB(hashmark: true))
		XCTAssertEqual(0.2, gradient.stops[1].position, accuracy: 0.01)
		XCTAssertEqual("#8e7470", try gradient.stops[2].color.hexRGB(hashmark: true))
		XCTAssertEqual(0.4, gradient.stops[2].position, accuracy: 0.01)
		XCTAssertEqual("#ac9b90", try gradient.stops[3].color.hexRGB(hashmark: true))
		XCTAssertEqual(0.6, gradient.stops[3].position, accuracy: 0.01)
		XCTAssertEqual("#d2ccb8", try gradient.stops[4].color.hexRGB(hashmark: true))
		XCTAssertEqual(0.8, gradient.stops[4].position, accuracy: 0.01)
		XCTAssertEqual("#eeeee1", try gradient.stops[5].color.hexRGB(hashmark: true))
		XCTAssertEqual(1, gradient.stops[5].position, accuracy: 0.01)
	}

	func testFlattenTransparencyStops() throws {
		let outputFolder = try! gradientTestsFolder.subfolder(with: "transparency-stop-flattening")
		do {
			let gradient = PAL.Gradient(
				stops: [
					PAL.Gradient.Stop(position: 0, color: PAL.Color.blue),
					PAL.Gradient.Stop(position: 1, color: PAL.Color.yellow),
				],
				transparencyStops: [
					PAL.Gradient.TransparencyStop(position: 0, value: 1),
					PAL.Gradient.TransparencyStop(position: 0.2, value: 0.25),
					PAL.Gradient.TransparencyStop(position: 1.0, value: 1),
				]
			)

			#if !os(Linux) && !os(Windows)
			let imOrig = try XCTUnwrap(gradient.image(size: CGSize(width: 400, height: 200)))
			let d1 = try imOrig.representation.png()
			try outputFolder.write(d1, to: "textGradient1_original.png")
			#endif

			let flattened = try gradient.mergeTransparencyStops()
			XCTAssertNil(flattened.transparencyStops)

			#if !os(Linux) && !os(Windows)
			let imFlattened = try XCTUnwrap(flattened.image(size: CGSize(width: 400, height: 200)))
			let d2 = try imFlattened.representation.png()
			try outputFolder.write(d2, to: "textGradient1_flattened.png")
			#endif
		}

		do {
			let gradients = try loadResourceGradient(named: "35.grd")
			XCTAssertEqual(10, gradients.count)

			let first = gradients.gradients[0]
			XCTAssertNotNil(first.transparencyStops)

			#if !os(Linux) && !os(Windows)
			let imOrig = try XCTUnwrap(first.image(size: CGSize(width: 400, height: 200)))
			let d1 = try imOrig.representation.png()
			try outputFolder.write(d1, to: "35_1_orig.png")
			#endif

			let flattened = try first.mergeTransparencyStops()
			XCTAssertNil(flattened.transparencyStops)
			XCTAssertEqual(8, flattened.stops.count)

			#if !os(Linux) && !os(Windows)
			let imFlattened = try XCTUnwrap(flattened.image(size: CGSize(width: 400, height: 200)))
			let d2 = try imFlattened.representation.png()
			try outputFolder.write(d2, to: "35_1_flattened.png")
			#endif
		}

		do {
			let gradients = try loadResourceGradient(named: "30.grd")
			XCTAssertEqual(10, gradients.count)

			let first = gradients.gradients[1]
			XCTAssertEqual(3, first.stops.count)
			XCTAssertNotNil(first.transparencyStops)
			XCTAssertEqual(9, first.transparencyStops?.count)

			#if !os(Linux) && !os(Windows)
			let imOrig = try XCTUnwrap(first.image(size: CGSize(width: 400, height: 200)))
			let d1 = try imOrig.representation.png()
			try outputFolder.write(d1, to: "30_1_orig.png")
			#endif

			let flattened = try first.mergeTransparencyStops()
			XCTAssertNil(flattened.transparencyStops)
			XCTAssertEqual(10, flattened.stops.count)

			#if !os(Linux) && !os(Windows)
			let imFlattened = try XCTUnwrap(flattened.image(size: CGSize(width: 400, height: 200)))
			let d2 = try imFlattened.representation.png()
			try outputFolder.write(d2, to: "30_1_flattened.png")
			#endif
		}
	}

	func testGradientCreationFromArray() throws {
		let colors: [PAL.Color] = [
			PAL.Color(r255: 255, g255: 0, b255: 0, name: "r"),
			PAL.Color(r255: 0, g255: 255, b255: 0, name: "g"),
			PAL.Color(r255: 0, g255: 0, b255: 255, name: "b"),
		]
		let g = colors.gradient()
		XCTAssertNil(g.name)
		XCTAssertEqual([0, 0.5, 1], g.stops.map { $0.position })
		XCTAssertEqual(colors, g.stops.map { $0.color })

		let g1 = colors.gradient(named: "g")
		XCTAssertEqual("g", g1.name)
	}

	let peekingFolder = try! gradientTestsFolder.subfolder(with: "gradient-color-peeking")

	func testGradientPeekColor() throws {
		let gcolors: [PAL.Color] = [
			PAL.Color(r255: 255, g255: 0, b255: 0, name: "r"),
			PAL.Color(r255: 0, g255: 255, b255: 0, name: "g"),
			PAL.Color(r255: 0, g255: 0, b255: 255, name: "b"),
		]
		let g = gcolors.gradient()

#if !os(Linux)
		let gr = try XCTUnwrap(g.thumbnailImage(size: CGSize(width: 300, height: 300)))
		let d1 = try gr.representation.png()
		try peekingFolder.write(d1, to: "rgb-gradient-image.png")
#endif

		let colors = try g.colors(count: 11)
		XCTAssertEqual(11, colors.count)

#if !os(Linux)
		let pal = PAL.Palette(colors: colors)
		let ima = try XCTUnwrap(pal.thumbnailImage(size: CGSize(width: 300, height: 50), dimension: CGSize(width: 12, height: 12)))
		let d2 = try ima.representation.png()
		try peekingFolder.write(d2, to: "rgb-palette-peeked.png")
#endif

		do {
			let colors = try g.colors(at: [0.unitValue, 0.3.unitValue, 0.9.unitValue, 1.0.unitValue])
			XCTAssertEqual(4, colors.count)
	#if !os(Linux)
			let pal = PAL.Palette(colors: colors)
			let ima = try XCTUnwrap(pal.thumbnailImage(size: CGSize(width: 300, height: 50), dimension: CGSize(width: 12, height: 12)))
			let d2 = try ima.representation.png()
			try peekingFolder.write(d2, to: "rgb-palette-color-ts.png")
	#endif
		}
	}

#if !os(Linux)
	func testGradientPeekColor2() throws {
		let gradients = try loadResourceGradient(named: "dem3.cpt")

		let g = try XCTUnwrap(gradients.gradients.first)
		let gr = try XCTUnwrap(g.thumbnailImage(size: CGSize(width: 300, height: 300)))
		let d1 = try gr.representation.png()
		try peekingFolder.write(d1, to: "dem3.png")

		let colors = try g.colors(count: 11)
		XCTAssertEqual(11, colors.count)

		let pal = PAL.Palette(colors: colors)

		let ima = try XCTUnwrap(pal.thumbnailImage(size: CGSize(width: 300, height: 50), dimension: CGSize(width: 12, height: 12)))
		let d2 = try ima.representation.png()
		try peekingFolder.write(d2, to: "dem3-peeked.png")
	}
#endif

	func testHueGradient() throws {

		let hueGradient = try! gradientTestsFolder.subfolder(with: "hue-gradient-tests")

		do {
			let g1 = PAL.Gradient(hueRange: 0.0 ... 1.0, stopCount: 11)
			let gs1 = PAL.Gradients(gradient: g1)
			let ps1 = try PAL.Gradients.Coder.GIMPGradientCoder().encode(gs1)
			try hueGradient.write(ps1, to: "hue-gradient-0-1-11.ggr")
		}
		do {
			let g1 = PAL.Gradient(hueRange: 0.0 ... 1.0, stopCount: 101)
			let gs1 = PAL.Gradients(gradient: g1)
			let ps1 = try PAL.Gradients.Coder.GIMPGradientCoder().encode(gs1)
			try hueGradient.write(ps1, to: "hue-gradient-0-1-101.ggr")
		}

		do {
			let g1 = PAL.Gradient(hueRange: 0.0 ... 1.0, stopCount: 3)
			let gs1 = PAL.Gradients(gradient: g1)
			let ps1 = try PAL.Gradients.Coder.GIMPGradientCoder().encode(gs1)
			try hueGradient.write(ps1, to: "hue-gradient-0-1-3.ggr")
		}

		do {
			let g1 = PAL.Gradient(hueRange: 0.1 ... 0.47, stopCount: 8)
			let gs1 = PAL.Gradients(gradient: g1)
			let ps1 = try PAL.Gradients.Coder.GIMPGradientCoder().encode(gs1)
			try hueGradient.write(ps1, to: "hue-gradient-orange2green-8.ggr")
		}
	}

	#if canImport(CoreGraphics)
	func testGradientDirections() throws {
		let gradientDirection = try! gradientTestsFolder.subfolder(with: "gradient-direction-tests")

		let g1 = PAL.Gradient(colors: [.red, .white, .blue])

		let i1 = try g1.cgImage(dimension: 60, unitStartPoint: CGPoint(x: 0, y: 0), unitEndPoint: CGPoint(x: 1, y: 0))
		let d1 = try i1.representation.png()
		try gradientDirection.write(d1, to: "leading-trailing.png")

		let i2 = try g1.cgImage(dimension: 60, unitStartPoint: CGPoint(x: 1, y: 0), unitEndPoint: CGPoint(x: 0, y: 0))
		let d2 = try i2.representation.png()
		try gradientDirection.write(d2, to: "trailing-leading.png")

		let i3 = try g1.cgImage(dimension: 60, unitStartPoint: CGPoint(x: 0, y: 1), unitEndPoint: CGPoint(x: 0, y: 0))
		let d3 = try i3.representation.png()
		try gradientDirection.write(d3, to: "top-bottom.png")

		let i4 = try g1.cgImage(dimension: 60, unitStartPoint: CGPoint(x: 0, y: 0), unitEndPoint: CGPoint(x: 0, y: 1))
		let d4 = try i4.representation.png()
		try gradientDirection.write(d4, to: "bottom-top.png")

		let i5 = try g1.cgImage(dimension: 60, unitStartPoint: CGPoint(x: 0, y: 0), unitEndPoint: CGPoint(x: 1, y: 1))
		let d5 = try i5.representation.png()
		try gradientDirection.write(d5, to: "bottom-leading-top-trailing.png")

		let i6 = try g1.cgImage(dimension: 60, unitStartPoint: CGPoint(x: 0, y: 1), unitEndPoint: CGPoint(x: 1, y: 0))
		let d6 = try i6.representation.png()
		try gradientDirection.write(d6, to: "top-leading-bottom-trailing.png")
	}
	#endif
}
