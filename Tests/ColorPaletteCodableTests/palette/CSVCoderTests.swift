@testable import ColorPaletteCodable
import XCTest
import TinyCSV

final class CSVCoderTests: XCTestCase {

	private func loadPalette(_ name: String) throws -> PAL.Palette {
		let paletteURL = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "csv"))
		return try PAL.Coder.CSV().decode(from: paletteURL)
	}

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testCSVCoder() throws {

		do {
			let pal = try loadPalette("pastel")
			XCTAssertEqual(5, pal.colors.count)
		}

		do {
			let pal2 = try loadPalette("pastel-extended")
			XCTAssertEqual(5, pal2.colors.count)

			XCTAssertEqual("Black olive", pal2.colors[0].name)
			XCTAssertEqual("Vivid sky blue", pal2.colors[1].name)
			XCTAssertEqual("Maya blue", pal2.colors[2].name)
			XCTAssertEqual("Alice Blue", pal2.colors[3].name)
			XCTAssertEqual("Orchid pink", pal2.colors[4].name)

			let data = try PAL.Coder.CSV().encode(pal2)
			XCTAssertGreaterThan(data.count, 0)

			let rawCSV = try XCTUnwrap(String(data: data, encoding: .utf8))
			let records = TinyCSV.Coder().decode(text: rawCSV)
			XCTAssertEqual(records.records.count, 5)
		}
	}
}
