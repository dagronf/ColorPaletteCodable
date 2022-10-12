@testable import ColorPaletteCodable
import XCTest

final class CodableTests: XCTestCase {
	func testBasicCoding() throws {

		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
		//let origData = try Data(contentsOf: controlASE)

		let palette = try PAL.Palette.Decode(from: controlASE)

		let enc = try JSONEncoder().encode(palette)
		//try enc.write(to: URL(fileURLWithPath: "/tmp/encoded.json"), options: .atomic)

		let reconst = try JSONDecoder().decode(PAL.Palette.self, from: enc)

		XCTAssertEqual(palette, reconst)
	}

	func testLessBasicCoding() throws {

		let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "Material Palette", withExtension: "aco"))
		//let origData = try Data(contentsOf: controlASE)

		let palette = try PAL.Palette.Decode(from: controlASE)

		let enc = try JSONEncoder().encode(palette)
		try enc.write(to: URL(fileURLWithPath: "/tmp/encoded.json"), options: .atomic)

		let reconst = try JSONDecoder().decode(PAL.Palette.self, from: enc)

		XCTAssertEqual(palette, reconst)
	}
}
