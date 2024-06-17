@testable import ColorPaletteCodable
import XCTest

import Foundation

class SVGPaletteTests: XCTestCase {

	let outputFolder = try! testResultsContainer.subfolder(with: "svg")

	func testSVGExportColor() throws {

		let samples = [
			"zenit-241.ase",
			"24 colour palettes.ase",
			"atari-800xl-palette.gpl",
			"pear36-transparency.hex",
		]

		try samples.forEach { name in
			let palette = try loadResourcePalette(named: name)
			let data = try PAL.Coder.SVG().encode(palette)
			try outputFolder.write(data, to: "expected - \(name).svg")

			// Check against our expected SVG output
			let expt = "expected - \(name).svg"
			let edata = try loadResourceData(named: expt)
			XCTAssertEqual(data, edata)
		}
	}
}
