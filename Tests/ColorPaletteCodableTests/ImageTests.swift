@testable import ColorPaletteCodable
import XCTest

#if canImport(SwiftUI)
import SwiftUI
#endif

private let __display = PAL.Palette(
	name: "My Colors",
	colors: [
		rgbf(1.0, 0, 0),
		rgbf(0, 1.0, 0),
		rgbf(0, 0, 1.0),
		grayf(0.5),
		cmykf(1, 0, 0, 0),
		cmykf(0, 1, 0, 0),
		cmykf(0, 0, 1, 0),
		cmykf(0, 0, 0, 1),

	],
	groups: [
		PAL.Group(name: "one", colors: [
			rgbf(0, 0, 1.0),
			rgbf(0, 1.0, 0),
			rgbf(1.0, 0, 0),
		]),
		PAL.Group(name: "two is the second one", colors: [
			rgbf(0.5, 0, 1),
			rgbf(0, 0.8, 0.3),
			rgbf(0.1, 0.3, 1.0),
			rgb255(000, 000, 000),
			rgb255(153, 000, 000),
			rgb255(102, 085, 085),
			rgb255(221, 017, 017),
		]),
	]
)

class ImageTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

#if os(macOS)

	func testmacOSImage() throws {
		let image = try PAL.Image.Image(colors: __display.colors, size: CGSize(width: 100, height: 25))
		XCTAssertEqual(image.size, CGSize(width: 100, height: 25))

		let image2 = try PAL.Image.Image(colors: __display.groups[0].colors, size: CGSize(width: 90, height: 30))
		XCTAssertEqual(image2.size, CGSize(width: 90, height: 30))
	}

#elseif os(iOS) || os(watchOS) || os(tvOS)

	func testiOSImage() throws {
		let image = try PAL.Image.Image(colors: __display.colors, size: CGSize(width: 100, height: 25))
		XCTAssertEqual(image.size, CGSize(width: 100, height: 25))

		let image2 = try PAL.Image.Image(colors: __display.groups[0].colors, size: CGSize(width: 90, height: 30))
		XCTAssertEqual(image2.size, CGSize(width: 90, height: 30))
	}

#endif
}

#if canImport(SwiftUI)

class SwiftUITests: XCTestCase {
	@available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	func testSwiftUIImage() throws {
		let _ /*image*/ = try PAL.Image.SwiftUIImage(colors: __display.colors, size: CGSize(width: 100, height: 25))
		//XCTAssertEqual(image.size, CGSize(width: 100, height: 25))

		let _ /*image2*/ = try PAL.Image.SwiftUIImage(colors: __display.groups[0].colors, size: CGSize(width: 90, height: 30))
		//XCTAssertEqual(image2.size, CGSize(width: 90, height: 30))
	}
}

#endif
