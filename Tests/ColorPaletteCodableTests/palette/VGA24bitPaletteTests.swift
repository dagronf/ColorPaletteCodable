@testable import ColorPaletteCodable
import XCTest

import Foundation

class VGA24bitPaletteTests: XCTestCase {

	//let outputFolder = try! testResultsContainer.subfolder(with: "vga24bit")

	func testRoundTrip() throws {

		let samples = [
			("atari-7800-palette.pal", 256),
		]

		try samples.forEach { sample in
			let url = try resourceURL(for: sample.0)

			// Make sure that 'detecting' the coder via the file extension works as expected
			let p1 = try PAL.Palette(url)
			XCTAssertEqual(sample.1, p1.colors.count)

			let p2 = try PAL.Palette(url, format: .vga24bit)
			XCTAssertEqual(sample.1, p1.colors.count)
			XCTAssertEqual(p1, p2)

			// Write back out, then read back in
			let data = try p1.export(format: .vga24bit)
			let p11 = try PAL.Palette(data, format: .vga24bit)
			XCTAssertEqual(p1, p11)
		}
	}

	func test18bitSampleRoundTrip() throws {
		let fileURL = try resourceURL(for: "18-bit sample.pal")
		let p = try PAL.Palette(fileURL, format: .vga18bit)
		XCTAssertEqual(256, p.colors.count)

		let data = try p.export(format: .vga18bit)
//		try data.write(to: URL(fileURLWithPath: "/tmp/18bitconv.gpl"))

		let p2 = try PAL.Palette(data, format: .vga18bit)
		XCTAssertEqual(p, p2)
	}

}
