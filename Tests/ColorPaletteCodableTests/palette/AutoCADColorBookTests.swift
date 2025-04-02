@testable import ColorPaletteCodable
import XCTest

// Can generate Autodesk ACB files here - https://download.autodesk.com/global/acb/index.html

final class AutodeskColorBookTests: XCTestCase {
	func testBasic() throws {
		let url = try resourceURL(for: "basic-rgb.acb")
		let coder = PAL.Coder.AutodeskColorBook()

		let palette = try coder.decode(from: url)
		XCTAssertEqual(5, palette.allColors().count)

		XCTAssertEqual(2, palette.groups.count)

		let g1 = palette.groups[0]
		XCTAssertEqual(3, g1.colors.count)
		XCTAssertEqual(rgb255(255, 0, 0, name: "red", colorType: .global), g1.colors[0])
		XCTAssertEqual(rgb255(0, 255, 0, name: "green", colorType: .global), g1.colors[1])
		XCTAssertEqual(rgb255(0, 0, 255, name: "blue", colorType: .global), g1.colors[2])

		let g2 = palette.groups[1]
		XCTAssertEqual(2, g2.colors.count)
		XCTAssertEqual(rgb255(255, 255, 255, name: "white", colorType: .global), g2.colors[0])
		XCTAssertEqual(rgb255(0, 0, 0, name: "black", colorType: .global), g2.colors[1])

		let data = try coder.encode(palette)

		let decoded = try coder.decode(from: data)
		XCTAssertEqual(2, decoded.groups.count)
		XCTAssertEqual(3, decoded.groups[0].colors.count)
		XCTAssertEqual(2, decoded.groups[1].colors.count)
	}

	func testLargerGroup() throws {
		let palette = try loadResourcePalette(named: "Default.gpl")

		XCTAssertEqual(23, palette.colors.count)
		XCTAssertEqual(palette.format, .gimp)

		let coder = PAL.Coder.AutodeskColorBook()
		let data = try coder.encode(palette)

		// try data.write(to: URL(fileURLWithPath: "/tmp/autodesk.acb"))

		let decoded = try coder.decode(from: data)
		XCTAssertEqual(decoded.format, .autodeskColorBook)
		XCTAssertEqual(1, decoded.groups.count)
		XCTAssertEqual(10, decoded.groups[0].colors.count)
	}


	func testLoadEncryptedColors() throws {
		// This file only contains encrypted colors.  Thus we shouldn't be able to load it
		let url = try resourceURL(for: "BM Classic Colors.acb")
		let coder = PAL.Coder.AutodeskColorBook()
		XCTAssertThrowsError(try coder.decode(from: url))
	}
}
