@testable import ColorPaletteCodable
import XCTest

final class CorelSwatchTests: XCTestCase {

	private func loadPalette(_ name: String) throws -> PAL.Palette {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "txt"))
		return try PAL.Coder.CorelPainter().decode(from: paletteURL)
	}

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testCorelPainterSwatch() throws {
		let pal = try loadPalette("adobe-swatch-fun")
		XCTAssertEqual(408, pal.colors.count)

		let pal2 = try loadPalette("corel-odd-coding")
		XCTAssertEqual(13, pal2.colors.count)

		XCTAssertEqual("", pal2.colors[0].name)
		XCTAssertEqual("PANTONE Process Magenta C", pal2.colors[1].name)
		XCTAssertEqual("PANTONE Process Yellow C", pal2.colors[2].name)
	}
}