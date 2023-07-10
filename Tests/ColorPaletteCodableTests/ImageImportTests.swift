@testable import ColorPaletteCodable
import XCTest

#if swift(>=5.5)

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

final class ImageImportTests: XCTestCase {
	func testImage1ToPalette() throws {
		let image1 = try XCTUnwrap(Bundle.module.url(forResource: "pastel", withExtension: "png"))
		let p1 = try PAL.Palette.importFromImage(image1, accuracy: 0.1)
		XCTAssertEqual(p1.colors.count, 5)
		let image = try PAL.Image.Image(colors: p1.colors, size: CGSize(width: 100, height: 25))
		XCTAssertEqual(image.size, CGSize(width: 100, height: 25))
	}

	func testImage2ToPalette() throws {
		let image1 = try XCTUnwrap(Bundle.module.url(forResource: "pastel2", withExtension: "png"))
		let p1 = try PAL.Palette.importFromImage(image1, accuracy: 0.1)
		XCTAssertEqual(p1.colors.count, 5)
		let image = try PAL.Image.Image(colors: p1.colors, size: CGSize(width: 100, height: 25))
		XCTAssertEqual(image.size, CGSize(width: 100, height: 25))
	}
}

#endif

#endif
