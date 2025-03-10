import XCTest
@testable import ColorPaletteCodable

private let grayTestsFolder = try! testResultsContainer.subfolder(with: "gray-tests")


final class GrayTests: XCTestCase {
	func testCheckGraySupport() throws {

		let colors: [PAL.Color] = stride(from: 0, through: 1, by: 0.2).flatMap {
			[
				/*let black =*/ grayf(0.0, $0),
				/*let mid =*/ grayf(0.5, $0),
				/*let white =*/ grayf(1.0, $0)
			]
		}

		let pal = PAL.Palette(colors: colors)

		do {
			let file = try grayTestsFolder.write(pal, coder: PAL.Coder.BasicXML(), filename: "basic-gray-color-generation.xml")
			let p2 = try PAL.Palette.Decode(from: file)
			try grayTestsFolder.write(p2, coder: PAL.Coder.BasicXML(), filename: "basic-gray-color-generation-reloaded.xml")
		}
		do {
			let file = try grayTestsFolder.write(pal, coder: PAL.Coder.DCP(), filename: "basic-gray-color-generation.dcp")
			let p2 = try PAL.Palette.Decode(from: file)
			try grayTestsFolder.write(p2, coder: PAL.Coder.DCP(), filename: "basic-gray-color-generation-reloaded.dcp")
		}
		#if os(macOS)
		do {
			let file = try grayTestsFolder.write(pal, coder: PAL.Coder.CLR(), filename: "basic-gray-color-generation.clr")
			let p2 = try PAL.Palette.Decode(from: file)
			try grayTestsFolder.write(p2, coder: PAL.Coder.CLR(), filename: "basic-gray-color-generation-reloaded.clr")
		}
		#endif
	}
}
