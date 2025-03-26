import XCTest
@testable import ColorPaletteCodable

final class DCGGradientTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testBreaks() throws {
		let coder = PAL.Gradients.Coder.DCG()
		let gradientURL = try resourceURL(for: "control.ase")  // This is not a gradient file
		XCTAssertThrowsError(try coder.decode(from: gradientURL))
	}

	func testTransparencyStopsBasicallyWork() throws {
		let gradient = PAL.Gradient(
			stops: [
				PAL.Gradient.Stop(position: 0, color: PAL.Color.blue),
				PAL.Gradient.Stop(position: 1, color: PAL.Color.yellow),
			],
			transparencyStops: [
				PAL.Gradient.TransparencyStop(position: 0, value: 1, midpoint: 0.5),
				PAL.Gradient.TransparencyStop(position: 0.2, value: 0.25, midpoint: 0.9),
				PAL.Gradient.TransparencyStop(position: 1.0, value: 1, midpoint: 0.25),
			]
		)

		let coder = PAL.Gradients.Coder.DCG()
		let enc = try coder.encode(PAL.Gradients(gradients: [gradient]))
	//	try enc.write(to: URL(fileURLWithPath: "/tmp/tstops.dcg"))

		let decoded = try coder.decode(from: enc)
		XCTAssertEqual(1, decoded.gradients.count)

		let g1 = decoded.gradients[0]
		do {
			XCTAssertEqual(2, g1.stops.count)
			XCTAssertEqual(0, g1.stops[0].position, accuracy: 0.0001)
			XCTAssertEqual(PAL.Color.blue, g1.stops[0].color)
			XCTAssertEqual(1, g1.stops[1].position, accuracy: 0.0001)
			XCTAssertEqual(PAL.Color.yellow, g1.stops[1].color)
		}

		do {
			let tstops = try XCTUnwrap(g1.transparencyStops)
			XCTAssertEqual(3, tstops.count)

			XCTAssertEqual(0,   tstops[0].position, accuracy: 0.0001)
			XCTAssertEqual(1,   tstops[0].value, accuracy: 0.0001)
			XCTAssertEqual(0.5, tstops[0].midpoint, accuracy: 0.0001)

			XCTAssertEqual(0.2,  tstops[1].position, accuracy: 0.0001)
			XCTAssertEqual(0.25, tstops[1].value, accuracy: 0.0001)
			XCTAssertEqual(0.9,  tstops[1].midpoint, accuracy: 0.0001)

			XCTAssertEqual(1.0, tstops[2].position, accuracy: 0.0001)
			XCTAssertEqual(1.0, tstops[2].value, accuracy: 0.0001)
			XCTAssertEqual(0.25, tstops[2].midpoint, accuracy: 0.0001)
		}
	}

	func testBasicLoad() throws {
		// TSMP is 30.grd
		let gradients = try loadResourceGradient(named: "tsmp.dcg")
		XCTAssertEqual(10, gradients.count)
		XCTAssertEqual(.dcg, gradients.format)

		let g1 = gradients.gradients[0]
		XCTAssertEqual("Custom", g1.name)
		XCTAssertEqual(3, g1.stops.count)
		XCTAssertEqual(9, g1.transparencyStops?.count)
	}

	func testVeryBasic() throws {
		let gradients = try loadResourceGradient(named: "wysiwyg.cpt")
		XCTAssertEqual(1, gradients.count)
		let g1 = gradients.gradients[0]

		let coder = PAL.Gradients.Coder.DCG()

		let enc = try coder.encode(gradients)
		let dec = try coder.decode(from: enc)
		XCTAssertEqual(1, dec.count)

		let g2 = gradients.gradients[0]

		let map = zip(g1.stops, g2.stops)
		map.forEach { a, b in
			XCTAssertEqual(a.position, b.position, accuracy: 0.00001)
			XCTAssertTrue(a.color.isEqual(to: b.color, precision: 5))
		}

		let tmap = zip(g1.transparencyStops ?? [], g2.transparencyStops ?? [])
		tmap.forEach { a, b in
			XCTAssertEqual(a.position, b.position, accuracy: 0.00001)
			XCTAssertEqual(a.value, b.value, accuracy: 0.00001)
			XCTAssertEqual(a.midpoint, b.midpoint, accuracy: 0.00001)
		}
	}

	func testVeryBasicTransparencyMap() throws {
		// This gradient has a transparency map
		let gradients = try loadResourceGradient(named: "30.grd")
		XCTAssertEqual(.adobeGRD, gradients.format)
		XCTAssertEqual(10, gradients.count)
		let g1 = gradients.gradients[0]

		XCTAssertEqual(3, g1.colors.count)
		XCTAssertEqual(9, g1.transparencyMap.count)

		let coder = PAL.Gradients.Coder.DCG()

		// Encode to our internal format

		let enc = try coder.encode(gradients)
		//try enc.write(to: URL(fileURLWithPath: "/tmp/tsmp.dcg"))

		// Try decoding
		let dec = try coder.decode(from: enc)
		XCTAssertEqual(10, dec.count)
	}
}
