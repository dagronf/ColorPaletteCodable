@testable import ColorPaletteCodable
import XCTest

final class InterpolationTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testMidpoint() throws {
		let c1 = PAL.Color.rgb(1, 0, 0, 0.2)
		let c2 = PAL.Color.rgb(0, 0, 1, 0.8)
		let c3 = try c1.midpoint(c2, t: 0.5.unitValue)
		XCTAssertEqual([0.5, 0, 0.5], c3.colorComponents)
		XCTAssertEqual(0.5, c3.alpha)
		#if canImport(CoreGraphics)
		let rx = c3.cgColor
		XCTAssertNotNil(rx)
		#endif
	}

	func testBucketColor() throws {
		// No colors, this should throw an error
		XCTAssertThrowsError(try [PAL.Color]().bucketedColor(at: 0.unitValue))
		// Single color will always return the single color
		XCTAssertEqual(PAL.Color.red, try [PAL.Color.red].bucketedColor(at: 0.unitValue))

		let colors: [PAL.Color] = [
			try PAL.Color(name: "r", r255: 255, g255: 0, b255: 0),
			try PAL.Color(name: "g", r255: 0, g255: 255, b255: 0),
			try PAL.Color(name: "b", r255: 0, g255: 0, b255: 255),
		]
		let p1 = PAL.Palette(colors: colors)

		XCTAssertEqual("r", try p1.colors.bucketedColor(at: 0.unitValue).name)
		XCTAssertEqual("r", try p1.colors.bucketedColor(at: 0.32.unitValue).name)

		XCTAssertEqual("g", try p1.colors.bucketedColor(at: 0.34.unitValue).name)
		XCTAssertEqual("g", try p1.colors.bucketedColor(at: 0.5.unitValue).name)
		XCTAssertEqual("g", try p1.colors.bucketedColor(at: 0.65.unitValue).name)

		XCTAssertEqual("b", try p1.colors.bucketedColor(at: 0.67.unitValue).name)
		XCTAssertEqual("b", try p1.colors.bucketedColor(at: 1.unitValue).name)
	}

	func testLinearColor2() throws {
		// No colors, this should throw an error
		XCTAssertThrowsError(try [PAL.Color]().interpolatedColor(at: 0.unitValue))
		// Single color will always return the single color
		XCTAssertEqual(PAL.Color.red, try [PAL.Color.red].interpolatedColor(at: 0.unitValue))

		let colors: [PAL.Color] = [
			try PAL.Color(name: "r", r255: 255, g255: 0, b255: 0),
			try PAL.Color(name: "b", r255: 0, g255: 0, b255: 255),
		]

		XCTAssertEqual(colors[0], try colors.interpolatedColor(at: 0.unitValue))
		XCTAssertEqual(colors[1], try colors.interpolatedColor(at: 1.unitValue))

		XCTAssertEqual(
			try PAL.Color(rf: 0.75, gf: 0, bf: 0.25),
			try colors.interpolatedColor(at: 0.25.unitValue)
		)

		XCTAssertEqual(
			try PAL.Color(rf: 0.5, gf: 0, bf: 0.5),
			try colors.interpolatedColor(at: 0.5.unitValue)
		)

		XCTAssertEqual(
			try PAL.Color(rf: 0.25, gf: 0, bf: 0.75),
			try colors.interpolatedColor(at: 0.75.unitValue)
		)
	}

	func testLinearColor3() throws {
		// No colors, this should throw an error
		XCTAssertThrowsError(try [PAL.Color]().bucketedColor(at: 0.unitValue))
		// Single color will always return the single color
		let t1 = try PAL.Color.green.withAlpha(0.1)
		XCTAssertEqual(t1, try [t1].interpolatedColor(at: 1.unitValue))

		// Single color, should just return the color
		let color = try PAL.Color(r255: 255, g255: 255, b255: 0)
		XCTAssertEqual(color, try [color].bucketedColor(at: 0.unitValue))
		XCTAssertEqual(color, try [color].bucketedColor(at: 1.unitValue))

		// Color array
		let colors: [PAL.Color] = [
			try PAL.Color(r255: 255, g255: 0, b255: 0),
			try PAL.Color(r255: 0, g255: 255, b255: 0),
			try PAL.Color(r255: 0, g255: 0, b255: 255),
		]

		XCTAssertEqual(colors[0], try colors.interpolatedColor(at: 0.unitValue))
		XCTAssertEqual(colors[1], try colors.interpolatedColor(at: 0.5.unitValue))
		XCTAssertEqual(colors[2], try colors.interpolatedColor(at: 1.unitValue))

		XCTAssertEqual(
			try PAL.Color(rf: 0.75, gf: 0.25, bf: 0.0),
			try colors.bucketedColor(at: 0.125.unitValue, interpolate: true)
		)

		XCTAssertEqual(
			try PAL.Color(rf: 0.5, gf: 0.5, bf: 0.0),
			try colors.bucketedColor(at: 0.25.unitValue, interpolate: true)
		)

		XCTAssertEqual(
			try PAL.Color(rf: 0.0, gf: 0.5, bf: 0.5),
			try colors.bucketedColor(at: 0.75.unitValue, interpolate: true)
		)
	}

	func testInterpolateBetweenTwoColors() throws {

		do {
			let priceColors = try PAL.Color.interpolate(
				firstColor: .red,
				lastColor: .green,
				count: 3
			)

			XCTAssertEqual(PAL.Color.red, priceColors[0])
			XCTAssertEqual(try PAL.Color(rf: 0.5, gf: 0.5, bf: 0), priceColors[1])
			XCTAssertEqual(PAL.Color.green, priceColors[2])
			XCTAssertEqual(3, priceColors.count)
		}

		do {
			let priceColors = try PAL.Color.interpolate(
				firstColor: PAL.Color(rf: 1, gf: 0.5, bf: 1),
				lastColor: PAL.Color(rf: 0, gf: 0.5, bf: 0.5),
				count: 3
			)

			XCTAssertEqual(try PAL.Color(rf: 1, gf: 0.5, bf: 1), priceColors[0])
			XCTAssertEqual(try PAL.Color(rf: 0.5, gf: 0.5, bf: 0.75), priceColors[1])
			XCTAssertEqual(try PAL.Color(rf: 0, gf: 0.5, bf: 0.5), priceColors[2])
			XCTAssertEqual(3, priceColors.count)
		}

		do {
			XCTAssertThrowsError(try PAL.Colors.blackToWhite(count: 0))
			let g = try PAL.Colors.blackToWhite(count: 1)
			// Single count means only white
			XCTAssertEqual([.white], g)
		}

		do {
			let grays = try PAL.Colors.blackToWhite(count: 3)
			XCTAssertEqual(3, grays.count)
			XCTAssertEqual(try PAL.Color(rf: 0, gf: 0, bf: 0), grays[0])
			XCTAssertEqual(try PAL.Color(rf: 0.5, gf: 0.5, bf: 0.5), grays[1])
			XCTAssertEqual(try PAL.Color(rf: 1, gf: 1, bf: 1), grays[2])
		}

		do {
			let c = try PAL.Colors.colorToClear(.green, count: 4)
			XCTAssertEqual(4, c.count)
			XCTAssertTrue(try PAL.Color(rf: 0, gf: 1, bf: 0, af: 1).isEqual(to: c[0], precision: 8))
			XCTAssertTrue(try PAL.Color(rf: 0, gf: 1, bf: 0, af: 0.666666666).isEqual(to: c[1], precision: 8))
			XCTAssertTrue(try PAL.Color(rf: 0, gf: 1, bf: 0, af: 0.333333333).isEqual(to: c[2], precision: 8))
			XCTAssertTrue(try PAL.Color(rf: 0, gf: 1, bf: 0, af: 0.0).isEqual(to: c[3], precision: 8))
		}
	}

	func testInterpolateColors() throws {
		// Color array
		let colors: [PAL.Color] = [
			try PAL.Color(rf: 1, gf: 0, bf: 0),
			try PAL.Color(rf: 1, gf: 1, bf: 0),
			try PAL.Color(rf: 0, gf: 1, bf: 0, af: 0.5),
		]

		let cs1 = try colors.interpolatedColors(count: 3)
		XCTAssertEqual(try PAL.Color(rf: 1, gf: 0, bf: 0), cs1[0])
		XCTAssertEqual(try PAL.Color(rf: 1, gf: 1, bf: 0), cs1[1])
		XCTAssertEqual(try PAL.Color(rf: 0, gf: 1, bf: 0, af: 0.5), cs1[2])

		let cs2 = try colors.interpolatedColors(count: 5)
		XCTAssertEqual(try PAL.Color(rf: 1, gf: 0, bf: 0), cs2[0])
		XCTAssertEqual(try PAL.Color(rf: 1, gf: 0.5, bf: 0), cs2[1])
		XCTAssertEqual(try PAL.Color(rf: 1, gf: 1, bf: 0), cs2[2])
		XCTAssertEqual(try PAL.Color(rf: 0.5, gf: 1, bf: 0, af: 0.75), cs2[3])
		XCTAssertEqual(try PAL.Color(rf: 0, gf: 1, bf: 0, af: 0.5), cs2[4])
	}
}
