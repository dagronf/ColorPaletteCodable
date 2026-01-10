@testable import ColorPaletteCodable
import XCTest


final class ColorTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testBasicRGB2LABConvert() throws {

		// https://colormine.org/convert/rgb-to-lab
		// https://colorizer.org

		let map = [
			(PAL.Color.RGB(r255: 50, g255: 125, b255: 50), PAL.Color.LAB(l100: 46.4127, a128: -39.2424, b128: 33.5074)),
			(PAL.Color.RGB(r255: 169, g255: 104, b255: 54), PAL.Color.LAB(l100: 50.2183, a128: 21.47, b128: 38.3924)),
			(PAL.Color.RGB(r255: 230, g255: 202, b255: 108), PAL.Color.LAB(l100: 81.9179, a128: -1.7478, b128: 50.0225)),
			(PAL.Color.RGB(r255: 155, g255: 173, b255: 255), PAL.Color.LAB(l100: 72.2791, a128: 13.4988, b128: -42.6301)),
		]

		map.forEach { (rgb, lab) in
			let c_lab = rgb.lab()
			XCTAssertEqual(c_lab.lf, lab.lf, accuracy: 0.001)
			XCTAssertEqual(c_lab.af, lab.af, accuracy: 0.001)
			XCTAssertEqual(c_lab.bf, lab.bf, accuracy: 0.001)

			let c_rgb = lab.rgb()
			XCTAssertEqual(c_rgb.r255, rgb.r255)
			XCTAssertEqual(c_rgb.g255, rgb.g255)
			XCTAssertEqual(c_rgb.b255, rgb.b255)
		}
	}

	func testRGBIntegerConversion() throws {

		func CheckConversion(_ color: PAL.Color.RGB, _ format: PAL.ColorByteFormat, _ expected: UInt32) {
			// Convert color to a uint32 - check against expected
			XCTAssertEqual(color.uint32Value(format), expected)
			// Convert expected value to RGBA
			XCTAssertEqual(color, PAL.Color.RGB(value: expected, format: format))
		}

		func CheckConversion(_ color: PAL.Color.RGB, _ format: PAL.ColorByteFormat, _ expected: Int32) {
			// Convert color to a uint32 - check against expected
			XCTAssertEqual(color.int32Value(format), expected)
			// Convert expected value to RGBA
			XCTAssertEqual(color, PAL.Color.RGB(value: expected, format: format))
		}

		// These hardcoded values come from https://colorizer.org

		CheckConversion(PAL.Color.RGB(r255: 255, g255: 255, b255: 255), .rgba, UInt32(4294967295))
		CheckConversion(PAL.Color.RGB(r255: 255, g255: 255, b255: 255), .rgba, Int32(-1))

		CheckConversion(PAL.Color.RGB(r255: 255, g255: 0, b255: 255), .rgba, UInt32(4278255615))
		CheckConversion(PAL.Color.RGB(r255: 255, g255: 0, b255: 255), .rgba, Int32(-16711681))

		CheckConversion(PAL.Color.RGB(r255: 255, g255: 255, b255: 255), .rgb, UInt32(16777215))
		CheckConversion(PAL.Color.RGB(r255: 255, g255: 255, b255: 255), .rgb, Int32(16777215))

		CheckConversion(PAL.Color.RGB(r255: 255, g255: 0, b255: 255), .bgr, UInt32(16711935))
		CheckConversion(PAL.Color.RGB(r255: 255, g255: 0, b255: 255), .bgr, Int32(16711935))

		CheckConversion(PAL.Color.RGB(r255: 89, g255: 145, b255: 106), .argb, UInt32(4284060010))
		CheckConversion(PAL.Color.RGB(r255: 89, g255: 145, b255: 106), .argb, Int32(-10907286))

		CheckConversion(PAL.Color.RGB(r255: 89, g255: 145, b255: 106), .bgra, UInt32(1787910655))
		CheckConversion(PAL.Color.RGB(r255: 89, g255: 145, b255: 106), .bgra, Int32(1787910655))
	}

	func testBasicRGB_YCbCrConversion() throws {

		// Example: https://colorizer.org

		let mapping: [(PAL.Color.RGB, PAL.Color.YCbCr)] = [
			// pure black
			(PAL.Color.RGB(r255: 0, g255: 0, b255: 0), PAL.Color.YCbCr(y: 0, cb: 128, cr: 128)),
			// pure white
			(PAL.Color.RGB(r255: 255, g255: 255, b255: 255), PAL.Color.YCbCr(y: 255, cb: 128, cr: 128)),
			// pure mid gray
			(PAL.Color.RGB(r255: 128, g255: 128, b255: 128), PAL.Color.YCbCr(y: 128, cb: 128, cr: 128)),
			// pure red
			(PAL.Color.RGB(r255: 255, g255: 0, b255: 0), PAL.Color.YCbCr(y: 76, cb: 85, cr: 255)),
			// orange
			(PAL.Color.RGB(r255: 255, g255: 165, b255: 0), PAL.Color.YCbCr(y: 173, cb: 30, cr: 186)),
			// green
			(PAL.Color.RGB(r255: 0, g255: 255, b255: 0), PAL.Color.YCbCr(y: 150, cb: 44, cr: 21)),
			// blue
			(PAL.Color.RGB(r255: 0, g255: 0, b255: 255), PAL.Color.YCbCr(y: 29, cb: 255, cr: 107)),
		]

		mapping.forEach { rgb, ycbcr in
			// rgb -> Y'CbCr
			XCTAssertEqual(rgb.YCbCr().precision(0), ycbcr)
			// Y'CbCr -> rgb
			XCTAssertEqual(ycbcr.rgb(), rgb)
		}
	}
}
