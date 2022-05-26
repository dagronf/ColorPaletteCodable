@testable import ColorPaletteCodable
import XCTest

#if canImport(SwiftUI)
import SwiftUI
#endif

let display = PAL.Palette(
	name: "My Colors",
	colors: [
		PAL.Color.rgb(1.0, 0, 0),
		PAL.Color.rgb(0, 1.0, 0),
		PAL.Color.rgb(0, 0, 1.0),
		PAL.Color.gray(white: 0.5),
		PAL.Color.cmyk(1, 0, 0, 0),
		PAL.Color.cmyk(0, 1, 0, 0),
		PAL.Color.cmyk(0, 0, 1, 0),
		PAL.Color.cmyk(0, 0, 0, 1),

	],
	groups: [
		PAL.Group(name: "one", colors: [
			PAL.Color.rgb(0, 0, 1.0),
			PAL.Color.rgb(0, 1.0, 0),
			PAL.Color.rgb(1.0, 0, 0),
		]),
		PAL.Group(name: "two is the second one", colors: [
			PAL.Color.rgb(0.5, 0, 1),
			PAL.Color.rgb(0, 0.8, 0.3),
			PAL.Color.rgb(0.1, 0.3, 1.0),
			PAL.Color.rgb(000, 000, 000),
			PAL.Color.rgb(153, 000, 000),
			PAL.Color.rgb(102, 085, 085),
			PAL.Color.rgb(221, 017, 017),
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
		let image = try PAL.Image.Image(colors: display.colors, size: CGSize(width: 100, height: 25))
		XCTAssertEqual(image.size, CGSize(width: 100, height: 25))

		let image2 = try PAL.Image.Image(colors: display.groups[0].colors, size: CGSize(width: 90, height: 30))
		XCTAssertEqual(image2.size, CGSize(width: 90, height: 30))
	}

#elseif os(iOS) || os(watchOS) || os(tvOS)

	func testiOSImage() throws {
		let image = try PAL.Image.Image(colors: display.colors, size: CGSize(width: 100, height: 25))
		XCTAssertEqual(image.size, CGSize(width: 100, height: 25))

		let image2 = try PAL.Image.Image(colors: display.groups[0].colors, size: CGSize(width: 90, height: 30))
		XCTAssertEqual(image2.size, CGSize(width: 90, height: 30))
	}

#endif
}

#if canImport(SwiftUI)

class SwiftUITests: XCTestCase {
	@available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	func testSwiftUIImage() throws {
		let _ /*image*/ = try PAL.Image.SwiftUIImage(colors: display.colors, size: CGSize(width: 100, height: 25))
		//XCTAssertEqual(image.size, CGSize(width: 100, height: 25))

		let _ /*image2*/ = try PAL.Image.SwiftUIImage(colors: display.groups[0].colors, size: CGSize(width: 90, height: 30))
		//XCTAssertEqual(image2.size, CGSize(width: 90, height: 30))
	}
}

#endif
