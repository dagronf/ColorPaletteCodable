@testable import ColorPaletteCodable
import XCTest

#if canImport(CoreGraphics)

import CoreGraphics

final class CoreGraphicsTests: XCTestCase {
	func testCGColorThings() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.coder(for: "ase"))

		do {
			let controlASE = try XCTUnwrap(Bundle.module.url(forResource: "control", withExtension: "ase"))
			let palette = try paletteCoder.decode(from: controlASE)

			let c1 = palette.groups[0].colors[0]
			let c2 = palette.groups[0].colors[1]


			let cg1 = try XCTUnwrap(c1.cgColor)
			XCTAssertEqual(CGColorSpace.sRGB, cg1.colorSpace?.name)
			XCTAssertEqual(cg1.components, [1, 1, 1, 1])

			let cg2 = try XCTUnwrap(c2.cgColor)
			XCTAssertEqual(CGColorSpace.sRGB, cg2.colorSpace?.name)
			XCTAssertEqual(cg2.components, [0, 0, 0, 1])
		}

		do {
			let cmyk = CGColor(genericCMYKCyan: 1, magenta: 1, yellow: 0.5, black: 0.2, alpha: 1)
			let cc1 = try PAL.Color(cgColor: cmyk, name: "cmyk", colorType: .global)

			var p = PAL.Palette()
			p.colors.append(cc1)

			let d1 = try paletteCoder.encode(p)
			XCTAssertLessThan(0, d1.count)

			let p1 = try paletteCoder.decode(from: d1)
			XCTAssertEqual(1, p1.colors.count)
			XCTAssertEqual(.CMYK, p1.colors[0].colorSpace)
			XCTAssertEqual(4, p1.colors[0].colorComponents.count)
			XCTAssertEqual(1, p1.colors[0].colorComponents[0])
			XCTAssertEqual(1, p1.colors[0].colorComponents[1])
			XCTAssertEqual(0.5, p1.colors[0].colorComponents[2])
			XCTAssertEqual(0.2, p1.colors[0].colorComponents[3])
		}
	}
}

#endif
