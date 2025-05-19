import XCTest
@testable import ColorPaletteCodable

final class CSSParsingTests: XCTestCase {

	let cssTestsFolder = try! testResultsContainer.subfolder(with: "css-parsing-tests")

	func writeGradient(_ gradient: PAL.Gradient, name: String) throws {
		#if !os(Linux) && !os(Windows)
		let imOrig = try XCTUnwrap(gradient.image(size: CGSize(width: 400, height: 200)))
		let d1 = try imOrig.representation.png()
		try cssTestsFolder.write(d1, to: name)
		#endif
	}

	func testBasic() throws {
		let t1 = #"linear-gradient(to right, rgb(199, 210, 254) 0%, rgba(254, 202, 202, 0.8) 5%, rgb(254, 243, 199) 100%)"#
		let result = PAL.Gradients.Coder.CSSGradientCoder.parse(t1)
		XCTAssertEqual(1, result.count)
		XCTAssertEqual(3, result.gradients[0].stops.count)
		XCTAssertEqual(0, result.gradients[0].stops[0].position, accuracy: 0.0001)
		XCTAssertEqual(0.05, result.gradients[0].stops[1].position, accuracy: 0.0001)
		XCTAssertEqual(1, result.gradients[0].stops[2].position, accuracy: 0.0001)
		try writeGradient(result.gradients[0], name: "rgb-with-positions-and-alpha.png")

	}

	func testBasic2() throws {
		let t1 = """
background-color: #0093E9;
background-image: linear-gradient(160deg, #0093E9 0%, #80D0C7 100%);
background-image: linear-gradient(fish, #0093E9, #80D0C7);
"""
		let result = PAL.Gradients.Coder.CSSGradientCoder.parse(t1)
		XCTAssertEqual(2, result.count)

		XCTAssertEqual(2, result.gradients[0].stops.count)
		XCTAssertEqual(0, result.gradients[0].stops[0].position, accuracy: 0.0001)
		XCTAssertEqual(1, result.gradients[0].stops[1].position, accuracy: 0.0001)

		try writeGradient(result.gradients[0], name: "hex-parsing-1-with-positions.png")

		XCTAssertEqual(2, result.gradients[1].stops.count)
		XCTAssertEqual(0, result.gradients[1].stops[0].position, accuracy: 0.0001)
		XCTAssertEqual(1, result.gradients[1].stops[1].position, accuracy: 0.0001)

		try writeGradient(result.gradients[1], name: "hex-parsing-1-without-positions.png")
	}

	func testBasic3() throws {
		do {
			let t1 = "background-image: linear-gradient(lime 40%, orange 100%)"
			let result = PAL.Gradients.Coder.CSSGradientCoder.parse(t1)
			XCTAssertEqual(1, result.count)

			// Because this gradient _starts_ at 40%, the library will insert a duplicate lime node at 0%
			XCTAssertEqual(3, result.gradients[0].stops.count)
			try writeGradient(result.gradients[0], name: "css-names-with-positions.png")
		}

		do {
			let t1 = """
linear-gradient(red, yellow, blue)
linear-gradient(to right, red,orange,yellow,green,blue,indigo,violet);
"""
			let result = PAL.Gradients.Coder.CSSGradientCoder.parse(t1)
			XCTAssertEqual(2, result.count)
			XCTAssertEqual(3, result.gradients[0].stops.count)
			try writeGradient(result.gradients[0], name: "css-names-1.png")
			XCTAssertEqual(7, result.gradients[1].stops.count)
			try writeGradient(result.gradients[1], name: "css-names-2.png")
		}
	}

	func testBasicHSL1() throws {
		let t1 = "linear-gradient(to bottom, hsl(0, 0%, 100%) 0%, hsla(0, 0%, 100%, 0.5) 50%, hsla(0, 0%, 0%, 0.2) 50%, hsl(0, 0%, 0%) 100%))"
		let result = PAL.Gradients.Coder.CSSGradientCoder.parse(t1)
		XCTAssertEqual(1, result.count)
		XCTAssertEqual(4, result.gradients[0].stops.count)
		try writeGradient(result.gradients[0], name: "hsl-with-positions-and-alpha.png")
	}

	func testBasicRGBExport() throws {

		let g1 = PAL.Gradient(colors: [.red, .green, .blue])
		let g2 = PAL.Gradient(colors: [.yellow, .cyan, .magenta])
		let g3 = PAL.Gradient(colors: [rgb255(199, 210, 254), rgb255(254, 202, 202, 175), rgb255(254, 243, 199)], positions: [0, 0.05, 1])

		let g = PAL.Gradients(gradients: [g1, g2, g3])

		let data = try PAL.Gradients.Coder.CSSGradientCoder().encode(g)
		XCTAssertFalse(data.isEmpty)
	}

}
