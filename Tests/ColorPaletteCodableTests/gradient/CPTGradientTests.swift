import XCTest
import ColorPaletteCodable

final class CPTGradientTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testGradientFormat1() throws {
		let gradients = try loadResourceGradient(named: "wysiwyg.cpt")
		XCTAssertEqual(1, gradients.count)
		XCTAssertEqual(.colorPaletteTables, gradients.format)
		let g = try XCTUnwrap(gradients.gradients.first)
		XCTAssertEqual(38, g.stops.count)
	}

	func testGradientFormat2() throws {
		let gradients = try loadResourceGradient(named: "magma.cpt")
		XCTAssertEqual(.colorPaletteTables, gradients.format)
		XCTAssertEqual(1, gradients.count)
		let g = try XCTUnwrap(gradients.gradients.first)
		XCTAssertEqual(510, g.stops.count)
	}

	func testGradientFormat3() throws {
		let gradients = try loadResourceGradient(named: "panoply.cpt")
		XCTAssertEqual(1, gradients.count)
		let g = try XCTUnwrap(gradients.gradients.first)
		XCTAssertEqual(32, g.stops.count)

		XCTAssertEqual("red", g.stops[26].color.name)
		XCTAssertEqual("red", g.stops[27].color.name)
	}

	func testGradientFormat4() throws {
		let gradients = try loadResourceGradient(named: "bhw1_02.cpt")
		XCTAssertEqual(1, gradients.count)
		let g = try XCTUnwrap(gradients.gradients.first)
		XCTAssertEqual(6, g.stops.count)
	}

	func testGradientFormat5() throws {
		let gradients = try loadResourceGradient(named: "acton.cpt")
		XCTAssertEqual(1, gradients.count)
		let g = try XCTUnwrap(gradients.gradients.first)
		XCTAssertEqual(510, g.stops.count)
	}

	func testGradientFormat6() throws {
		let gradients = try loadResourceGradient(named: "balance.cpt")
		XCTAssertEqual(1, gradients.count)
		let g = try XCTUnwrap(gradients.gradients.first)
		XCTAssertEqual(512, g.stops.count)
	}

	func testGradientFormat7() throws {
		let gradients = try loadResourceGradient(named: "37_waves.cpt")
		XCTAssertEqual(1, gradients.count)
		let g = try XCTUnwrap(gradients.gradients.first)
		XCTAssertEqual(508, g.stops.count)
	}

	func testGradientFormat8() throws {
		// Format uses x11 color names
		let gradients = try loadResourceGradient(named: "dem3.cpt")
		XCTAssertEqual(1, gradients.count)
		let g = try XCTUnwrap(gradients.gradients.first)
		XCTAssertEqual(12, g.stops.count)
		XCTAssertEqual("MediumSeaGreen", g.stops[0].color.name)
		XCTAssertEqual("ivory2", g.stops[10].color.name)
	}

	func testCheckRemapGradientPositions() throws {
		let gradients = try loadResourceGradient(named: "os250k-metres.cpt")
		XCTAssertEqual(1, gradients.gradients.count)

		let posns = gradients.gradients[0].stops.map { $0.position }
		let xMin = try XCTUnwrap(posns.min())
		let xMax = try XCTUnwrap(posns.max())
		XCTAssertGreaterThanOrEqual(0, xMin)
		XCTAssertLessThanOrEqual(1, xMax)
	}

	func testBasicImportExportAndStopMerging() throws {

		let g1 = PAL.Gradient(
			colors: [
				PAL.Color.red,
				PAL.Color.green,
				PAL.Color.blue
			],
			positions: [-1000, 0, 1000],
			name: "first"
		)

		let c = PAL.Gradients.Coder.ColorPaletteTablesCoder()

		let data = try c.encode(PAL.Gradients(gradient: g1))
		//try data.write(to: URL(fileURLWithPath: "/tmp/output.cpt"))

		let decoded = try c.decode(from: data)
		XCTAssertEqual(1, decoded.gradients.count)
		let dg1 = try XCTUnwrap(decoded.gradients.first)

		// There will be four stops now, from two segments (-1000 -> 0, 0 -> 1000)
		XCTAssertEqual(4, dg1.stops.count)

		XCTAssertEqual(-1000, dg1.stops[0].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color.red.isEqual(to: dg1.stops[0].color, precision: 6))
		XCTAssertEqual(0, dg1.stops[1].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color.green.isEqual(to: dg1.stops[1].color, precision: 6))
		XCTAssertEqual(0, dg1.stops[2].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color.green.isEqual(to: dg1.stops[2].color, precision: 6))
		XCTAssertEqual(1000, dg1.stops[3].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color.blue.isEqual(to: dg1.stops[3].color, precision: 6))

		let merged = try dg1.mergeIdenticalNeighbouringStops()

		XCTAssertEqual(3, merged.stops.count)

		// red p=-1000
		XCTAssertEqual(-1000, merged.stops[0].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color.red.isEqual(to: merged.stops[0].color, precision: 6))

		// green p=0
		XCTAssertEqual(0, merged.stops[1].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color.green.isEqual(to: merged.stops[1].color, precision: 6))

		// blue p=1000
		XCTAssertEqual(1000, merged.stops[2].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color.blue.isEqual(to: merged.stops[2].color, precision: 6))
	}

	func testAttemptGrayscaleLoad() throws {
		let gradients = try loadResourceGradient(named: "gray.cpt")
		XCTAssertEqual(1, gradients.count)
		let g = try XCTUnwrap(gradients.gradients.first)
		XCTAssertEqual(4, g.stops.count)

		XCTAssertEqual(0, g.stops[0].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color(white255: 10).isEqual(to: g.stops[0].color, precision: 6))

		XCTAssertEqual(0.5, g.stops[1].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color(white255: 40).isEqual(to: g.stops[1].color, precision: 6))

		XCTAssertEqual(0.5, g.stops[2].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color(white255: 60).isEqual(to: g.stops[2].color, precision: 6))

		XCTAssertEqual(1, g.stops[3].position, accuracy: 0.000001)
		XCTAssertTrue(PAL.Color(white255: 90).isEqual(to: g.stops[3].color, precision: 6))
	}
}
