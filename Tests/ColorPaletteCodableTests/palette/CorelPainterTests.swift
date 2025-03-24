@testable import ColorPaletteCodable
import XCTest

final class CorelPainterTests: XCTestCase {

	func testCorelPainterSwatch() throws {

		do {
			let pal = try loadResourcePalette(named: "adobe-swatch-fun.txt", using: PAL.Coder.CorelPainter())
			XCTAssertEqual(pal.format, .corelPainter)
			XCTAssertEqual(408, pal.colors.count)
		}

		do {
			let pal2 = try loadResourcePalette(named: "corel-odd-coding.txt", using: PAL.Coder.CorelPainter())
			XCTAssertEqual(pal2.format, .corelPainter)
			XCTAssertEqual(13, pal2.colors.count)

			XCTAssertEqual("", pal2.colors[0].name)
			XCTAssertEqual("PANTONE Process Magenta C", pal2.colors[1].name)
			XCTAssertEqual("PANTONE Process Yellow C", pal2.colors[2].name)

			let data = try PAL.Coder.CorelPainter().encode(pal2)
			XCTAssertNotEqual(0, data.count)

			try data.write(to: URL(fileURLWithPath: "/tmp/output.txt"))

			let dpal2 = try PAL.Coder.CorelPainter().decode(from: data)
			XCTAssertEqual(13, dpal2.colors.count)

		}
	}
}
