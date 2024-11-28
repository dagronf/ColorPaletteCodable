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
}
