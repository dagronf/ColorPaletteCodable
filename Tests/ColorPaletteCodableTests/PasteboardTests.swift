@testable import ColorPaletteCodable
import XCTest


#if os(macOS)
func CreatePasteboard(named name: String) -> NSPasteboard {
	return NSPasteboard(name: NSPasteboard.Name(name))
}
#else
func CreatePasteboard(named name: String) -> UIPasteboard {
	return UIPasteboard(name: UIPasteboard.Name(name), create: true)!
}
#endif

final class PasteboardTests: XCTestCase {
	func testBasic() throws {
		let pasteboard = CreatePasteboard(named: "testing")

		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
		let palette = try PAL.Palette.load(fileURL: fileURL)

		// Add the palette to the pasteboard
		try palette.setOnPasteboard(pasteboard)

		// Read back from the pasteboard
		let rep = try XCTUnwrap(PAL.Palette.Create(from: pasteboard))
		XCTAssertEqual(rep, palette)
	}

	func testMoreComplex() throws {
		let pasteboard = CreatePasteboard(named: "testing")

		let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "Material Palette", withExtension: "aco"))
		let palette = try PAL.Palette.load(fileURL: fileURL)

		// Add the palette to the pasteboard
		try palette.setOnPasteboard(pasteboard)

		#if os(macOS)
		try palette.setOnPasteboard(NSPasteboard.general)
		#endif

		// Read back from the pasteboard
		let rep = try XCTUnwrap(PAL.Palette.Create(from: pasteboard))
		XCTAssertEqual(rep, palette)
	}
}
