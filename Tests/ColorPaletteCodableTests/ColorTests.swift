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
}
