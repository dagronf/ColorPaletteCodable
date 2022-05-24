@testable import ColorPaletteCodable
import XCTest

#if os(macOS) || os(iOS)

#if os(macOS)
func CreatePasteboard(named name: String) -> NSPasteboard {
	return NSPasteboard(name: NSPasteboard.Name(name))
}
#elseif os(iOS)
func CreatePasteboard(named name: String) -> UIPasteboard {
	return UIPasteboard(name: UIPasteboard.Name(name), create: true)!
}
#endif

final class PasteboardTests: XCTestCase {
	func testBasic() throws {
		let pasteboard = CreatePasteboard(named: "testing")

		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
		let palette = try PAL.Palette.Decode(from: fileURL)

		// Add the palette to the pasteboard
		try palette.setOnPasteboard(pasteboard)

		// Read back from the pasteboard
		let rep = try XCTUnwrap(PAL.Palette.readFromPasteboard(pasteboard))
		XCTAssertEqual(rep, palette)
	}

	func testMoreComplex() throws {
		let pasteboard = CreatePasteboard(named: "testing")

		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "Material Palette", withExtension: "aco"))
		let palette = try PAL.Palette.Decode(from: fileURL)

		// Add the palette to the pasteboard
		try palette.setOnPasteboard(pasteboard)

		#if os(macOS)
		// Purely for debugging
		// try palette.setOnPasteboard(NSPasteboard.general)
		#endif

		// Read back from the pasteboard
		let rep = try XCTUnwrap(PAL.Palette.readFromPasteboard(pasteboard))
		XCTAssertEqual(rep, palette)
	}
}

#endif
