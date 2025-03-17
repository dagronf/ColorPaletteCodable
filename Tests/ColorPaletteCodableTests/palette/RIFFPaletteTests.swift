@testable import ColorPaletteCodable
import XCTest

final class RIFFSwatchesTests: XCTestCase {
	func testBasic() throws {
		let palette = try loadResourcePalette(named: "arne-v20-16.pal", using: PAL.Coder.RIFF())
		XCTAssertEqual(16, palette.colors.count)
		XCTAssertEqual(palette.colors[0], PAL.Color(r255: 0, g255: 0, b255: 0))
		XCTAssertEqual(palette.colors[1], PAL.Color(r255: 157, g255: 157, b255: 157))
		XCTAssertEqual(palette.colors[14], PAL.Color(r255: 49, g255: 162, b255: 242))
		XCTAssertEqual(palette.colors[15], PAL.Color(r255: 178, g255: 220, b255: 239))
	}

	func testBasic2() throws {
		let palette = try loadResourcePalette(named: "sample.pal", using: PAL.Coder.RIFF())
		XCTAssertEqual(256, palette.colors.count)
	}
}
