@testable import ColorPaletteCodable
import XCTest

final class TemperatureTests: XCTestCase {
	let outputFolder = try! testResultsContainer.subfolder(with: "temperature-tests")

	override func setUpWithError() throws {
	}

	override func tearDownWithError() throws {
	}

	func testKelvinColor() throws {
		let c1 = try kelvinToRGB(1000)
		XCTAssertEqual(255, c1.r)
		XCTAssertEqual(67, c1.g)
		XCTAssertEqual(0, c1.b)

		let c2 = try kelvinToRGB(5800)
		XCTAssertEqual(255, c2.r)
		XCTAssertEqual(242, c2.g)
		XCTAssertEqual(231, c2.b)

		let c3 = try kelvinToRGB(2700)
		XCTAssertEqual(255, c3.r)
		XCTAssertEqual(166, c3.g)
		XCTAssertEqual(87, c3.b)

		let c4 = try kelvinToRGB(11200)
		XCTAssertEqual(194, c4.r)
		XCTAssertEqual(213, c4.g)
		XCTAssertEqual(255, c4.b)
	}

	func testKelvinPalette() throws {
		let range = try PAL.Palette(kelvinRange: 30 ... 40000, count: 100)
		XCTAssertEqual(100, range.colors.count)
		try self.outputFolder.write(range, coder: PAL.Coder.GIMP(), filename: "basic100kelvin.gpl")
		try self.outputFolder.write(range.gradient(), coder: PAL.Gradients.Coder.GGR(), filename: "basic100kelvin.ggr")

		#if !os(Linux)
		let cgi = range.thumbnailImage(size: CGSize(width: 300, height: 40))!
		let d1 = try cgi.representation.png()
		try self.outputFolder.write(d1, to: "basic100kelvin.png")
		#endif
	}

	func testKelvinGradient() throws {
		let kg = try PAL.Gradient(kelvinRange: 1500 ... 15000, count: 111)
		XCTAssertEqual(111, kg.stops.count)
		try self.outputFolder.write(kg, coder: PAL.Gradients.Coder.GGR(), filename: "basicKelvinGradient.ggr")

		#if !os(Linux)
		let nsi = try kg.image(size: CGSize(width: 400, height: 50))
		let d1 = try nsi.representation.png()
		try self.outputFolder.write(d1, to: "basicKelvinGradient.png")
		#endif
	}
}
