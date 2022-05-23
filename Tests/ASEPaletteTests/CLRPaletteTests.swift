@testable import ASEPalette
import XCTest

final class CLRPaletteTests: XCTestCase {
	func testRealBasic() throws {

		var palette = ASE.Palette()
		let c1 = try ASE.Color(name: "red", model: ASE.ColorSpace.RGB, colorComponents: [1, 0, 0])
		let c2 = try ASE.Color(name: "green", model: ASE.ColorSpace.RGB, colorComponents: [0, 1, 0])
		let c3 = try ASE.Color(name: "blue", model: ASE.ColorSpace.RGB, colorComponents: [0, 0, 1])
		palette.colors.append(contentsOf: [c1, c2, c3])

		let coder = ASE.Factory.shared.clr

		let rawData = try coder.data(for: palette)

		let reconst = try coder.load(data: rawData)
		XCTAssertEqual(reconst, palette)

	}
}
