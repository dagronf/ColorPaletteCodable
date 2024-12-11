@testable import ColorPaletteCodable
import XCTest

final class GPFGradientTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testExample() throws {

		do {
			// http://seaviewsensing.com/pub/cpt-city/esri/hypsometry/sa/tn/argentina.png.index.html
			let gradients = try loadResourceGradient(named: "argentina.gpf")
			XCTAssertEqual(1, gradients.gradients.count)
			let g = gradients.gradients[0]
			XCTAssertEqual(127, g.colors.count)

			let enc = try PAL.Gradients.Coder.GPF().encode(gradients)
			let decoded = try PAL.Gradients.Coder.GPF().decode(from: enc)
			XCTAssertEqual(127, decoded.gradients.first?.colors.count)
		}

		do {
			// http://seaviewsensing.com/pub/cpt-city/go2/button/tn/b-255-166.png.index.html
			let gradients = try loadResourceGradient(named: "b-255-166.gpf")
			XCTAssertEqual(1, gradients.gradients.count)
			let g = gradients.gradients[0]
			XCTAssertEqual(4, g.colors.count)

			let enc = try PAL.Gradients.Coder.GPF().encode(gradients)
			let decoded = try PAL.Gradients.Coder.GPF().decode(from: enc)
			XCTAssertEqual(4, decoded.gradients.first?.colors.count)
		}

		do {
			// http://seaviewsensing.com/pub/cpt-city/go2/ipod/tn/ipod-pink.png.index.html
			let gradients = try loadResourceGradient(named: "ipod-pink.gpf")
			XCTAssertEqual(1, gradients.gradients.count)
			let g = gradients.gradients[0]
			XCTAssertEqual(12, g.colors.count)

			let enc = try PAL.Gradients.Coder.GPF().encode(gradients)
			let decoded = try PAL.Gradients.Coder.GPF().decode(from: enc)
			XCTAssertEqual(12, decoded.gradients.first?.colors.count)
		}
	}
}
