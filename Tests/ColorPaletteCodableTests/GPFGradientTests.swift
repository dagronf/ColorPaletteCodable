@testable import ColorPaletteCodable
import XCTest

final class GPFGradientTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	let roundTrip: [(filename: String, expectedCount: Int)] = [
		("argentina.gpf", 127),   // http://seaviewsensing.com/pub/cpt-city/esri/hypsometry/sa/tn/argentina.png.index.html
		("b-255-166.gpf", 4),     // http://seaviewsensing.com/pub/cpt-city/go2/button/tn/b-255-166.png.index.html
		("ipod-pink.gpf", 12),    // http://seaviewsensing.com/pub/cpt-city/go2/ipod/tn/ipod-pink.png.index.html
		("arctic.gpf", 113),
		("geo-smooth.gpf", 29),
	]

	func testRoundTripLoad() throws {
		for item in roundTrip {
			let gradients = try loadResourceGradient(named: item.filename)
			XCTAssertEqual(1, gradients.gradients.count)
			let g = gradients.gradients[0]
			XCTAssertEqual(item.expectedCount, g.colors.count)

			let enc = try PAL.Gradients.Coder.GPF().encode(gradients)

			let decoded = try PAL.Gradients.Coder.GPF().decode(from: enc)
			let decodedGradient = try XCTUnwrap(decoded.gradients.first)
			XCTAssertEqual(item.expectedCount, decodedGradient.colors.count)

			let map = zip(g.stops, decodedGradient.stops)
			map.forEach { (a, b) in
				XCTAssertEqual(a.position, b.position, accuracy: 0.0001)
				XCTAssertTrue(a.color.isEqual(to: b.color, precision: 4))
			}
		}
	}
}
