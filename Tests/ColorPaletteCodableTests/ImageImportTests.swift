@testable import ColorPaletteCodable
import XCTest
import SwiftImageReadWrite

#if swift(>=5.5)

#if !os(Linux) && !os(Windows)

final class ImageImportTests: XCTestCase {
	func testImage1ToPalette() throws {
		let imageURL = try XCTUnwrap(Bundle.module.url(forResource: "pastel", withExtension: "png"))
		let coder = PAL.Coder.Image(accuracy: 0.1)
		let p1 = try coder.decode(from: imageURL)
		XCTAssertEqual(p1.colors.count, 5)

		let hex = try p1.colors.map { try $0.hexRGBA(hashmark: true, uppercase: false) }
		let expected = ["#bcbef1ff", "#c8f8b6ff", "#fac8e2ff", "#c1e8e1ff", "#e5eadaff"]
		XCTAssertEqual(hex, expected)

		let image = try PAL.Image.Image(colors: p1.colors, size: CGSize(width: 100, height: 25))
		XCTAssertEqual(image.size, CGSize(width: 100, height: 25))
	}

	func testImage2ToPalette() throws {
		let imageURL = try XCTUnwrap(Bundle.module.url(forResource: "pastel", withExtension: "jpg"))
		let coder = PAL.Coder.Image(accuracy: 0.1)
		let p1 = try coder.decode(from: imageURL)
		XCTAssertEqual(p1.colors.count, 5)

		let hex = try p1.colors.map { try $0.hexRGBA(hashmark: true, uppercase: false) }
		// These are slightly different to the png results, as JPEG encoding slightly tweaks the colors
		let expected = ["#bcbef1ff", "#ccf2c9ff", "#eed1d6ff", "#bfeae1ff", "#dfeddeff"]
		XCTAssertEqual(hex, expected)

		let image = try PAL.Image.Image(colors: p1.colors, size: CGSize(width: 100, height: 25))
		XCTAssertEqual(image.size, CGSize(width: 100, height: 25))
	}

	func testImage3ToPalette() throws {
		let imageURL = try XCTUnwrap(Bundle.module.url(forResource: "midnight-ablaze-1x", withExtension: "png"))
		let coder = PAL.Coder.Image(accuracy: 0.01)
		let p1 = try coder.decode(from: imageURL)
		XCTAssertEqual(p1.colors.count, 7)
		let image = try PAL.Image.Image(colors: p1.colors, size: CGSize(width: 100, height: 25))
		XCTAssertEqual(image.size, CGSize(width: 100, height: 25))

		do {
			let imageData = try PAL.Coder.Image(exportType: .swatch(.init(width: 32, height: 16))).encode(p1)
			let image = try XCTUnwrap(PlatformImage(data: imageData))
			XCTAssertEqual(image.size, CGSize(width: 224, height: 16))
		}

		do {
			let imageData = try PAL.Coder.Image(exportType: .image(.init(width: 196, height: 35))).encode(p1)
			let image = try XCTUnwrap(PlatformImage(data: imageData))
			XCTAssertEqual(image.size, CGSize(width: 196, height: 35))
		}

		do {
			let imageData = try PAL.Coder.Image(exportType: .swatch(.init(width: 1, height: 1))).encode(p1)
			let image = try XCTUnwrap(PlatformImage(data: imageData))
			XCTAssertEqual(image.size, CGSize(width: 7, height: 1))
		}
	}

	func testImage4() throws {
		let p = try loadResourcePalette(named: "sunnyswamp-1x.png")
		XCTAssertEqual(5, p.colors.count)
		let cc = try p.colors.map { try $0.hexRGB(hashmark: true, uppercase: true) }
		XCTAssertEqual(["#DBD1B4", "#D1AD82", "#98A681", "#6A9490", "#667580"], cc)

		let imageData = try PAL.Coder.Image(exportType: .swatch(.init(width: 1, height: 1))).encode(p)
		let image = try XCTUnwrap(PlatformImage(data: imageData))
		XCTAssertEqual(image.size, CGSize(width: 5, height: 1))
	}

	func testImage5() throws {
		let p = try loadResourcePalette(named: "sweetie-16-32x.png")
		XCTAssertEqual(16, p.colors.count)
		let cc = try p.colors.map { try $0.hexRGB(hashmark: true, uppercase: true) }

		let expected = [
			"#1A1C2C", "#5D275D", "#B13E53", "#EF7D57", "#FFCD75", "#A7F070", "#38B764", "#257179",
			"#29366F", "#3B5DC9", "#41A6F6", "#73EFF7", "#F4F4F4", "#94B0C2", "#566C86", "#333C57"
		]

		XCTAssertEqual(expected, cc)

		let imageData = try PAL.Coder.Image(exportType: .swatch(.init(width: 1, height: 1))).encode(p)
		let image = try XCTUnwrap(PlatformImage(data: imageData))
		XCTAssertEqual(image.size, CGSize(width: 16, height: 1))
	}
}

#endif

#endif
