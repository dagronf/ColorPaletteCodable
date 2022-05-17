// Tests that don't directly validate ASEPalette

@testable import ASEPalette
import XCTest

final class GenericTests: XCTestCase {
	func testCGColorHex() throws {
		do {
			let hc = try XCTUnwrap(CGColor.fromRGBHexString("#FF25EE"))
			let co = try XCTUnwrap(hc.components)
			XCTAssertEqual(CGColorSpace.genericRGBLinear, hc.colorSpace?.name)
			XCTAssertEqual(co[0], 1, accuracy: 0.000001)
			XCTAssertEqual(co[1], 0.145098, accuracy: 0.000001)
			XCTAssertEqual(co[2], 0.933333, accuracy: 0.000001)
			XCTAssertEqual(co[3], 1, accuracy: 0.000001)
		}

		do {
			let hc = try XCTUnwrap(CGColor.fromRGBHexString("FF25ee"))
			let co = try XCTUnwrap(hc.components)
			XCTAssertEqual(CGColorSpace.genericRGBLinear, hc.colorSpace?.name)
			XCTAssertEqual(co[0], 1, accuracy: 0.000001)
			XCTAssertEqual(co[1], 0.145098, accuracy: 0.000001)
			XCTAssertEqual(co[2], 0.933333, accuracy: 0.000001)
			XCTAssertEqual(co[3], 1, accuracy: 0.000001)
		}

		do {
			let hc = try XCTUnwrap(CGColor.fromRGBAHexString("#00112244"))
			let co = try XCTUnwrap(hc.components)
			XCTAssertEqual(CGColorSpace.genericRGBLinear, hc.colorSpace?.name)
			XCTAssertEqual(co[0], 0, accuracy: 0.000001)
			XCTAssertEqual(co[1], 0.066666, accuracy: 0.000001)
			XCTAssertEqual(co[2], 0.133333, accuracy: 0.000001)
			XCTAssertEqual(co[3], 0.266666, accuracy: 0.000001)

			let hcs = try XCTUnwrap(hc.hexRGB)
			XCTAssertEqual("#001122", hcs)

			let hcsa = try XCTUnwrap(hc.hexRGBA)
			XCTAssertEqual("#00112244", hcsa)
		}

		do {
			let hc = try XCTUnwrap(CGColor.fromRGBAHexString("ff25eeAA"))
			let co = try XCTUnwrap(hc.components)
			XCTAssertEqual(CGColorSpace.genericRGBLinear, hc.colorSpace?.name)
			XCTAssertEqual(co[0], 1, accuracy: 0.000001)
			XCTAssertEqual(co[1], 0.145098, accuracy: 0.000001)
			XCTAssertEqual(co[2], 0.933333, accuracy: 0.000001)
			XCTAssertEqual(co[3], 0.666666, accuracy: 0.000001)

			let hcs = try XCTUnwrap(hc.hexRGB)
			XCTAssertEqual("#ff25ee", hcs)
			let hcsa = try XCTUnwrap(hc.hexRGBA)
			XCTAssertEqual("#ff25eeaa", hcsa)
		}
	}
}
