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
		let g = try XCTUnwrap(gradients.gradients.first)
		XCTAssertEqual(38, g.stops.count)
	}

	func testGradientFormat2() throws {
		let gradients = try loadResourceGradient(named: "magma.cpt")
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
}
