@testable import ColorPaletteCodable
import XCTest

#if canImport(CoreGraphics)

import CoreGraphics
import SwiftUI

final class CoreGraphicsTests: XCTestCase {
	func testCGColorThings() throws {
		let paletteCoder = try XCTUnwrap(PAL.Palette.firstCoder(for: "ase"))

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
			let cc1 = try PAL.Color(name: "cmyk", color: cmyk, colorType: .global)

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

	func testSwiftUIDefinitionGeneration() throws {

		do {
			let gradient = PAL.Gradient(
				colors: [
					try PAL.Color(hexString: "#FFFFFF", format: .rgba),
					try PAL.Color(hexString: "#121212", format: .rgba),
					try PAL.Color(hexString: "#444444", format: .rgba)
				],
				positions: [60, 45, 30]
			)
			let gs = PAL.Gradients(gradients: [gradient])

			let suis = try PAL.Gradients.Coder.SwiftGen().encode(gs)
			try suis.write(to: URL(fileURLWithPath: "/tmp/data.swift"))

			let suis2 = try PAL.Gradients.Coder.SwiftUIGen().encode(gs)
			try suis2.write(to: URL(fileURLWithPath: "/tmp/dataUI.swift"))
		}

		do {
			let content = try loadResourceData(named: "Tube_Red.ggr")
			let dec = PAL.Gradients.Coder.GGR()
			let gradients = try dec.decode(from: content)

			let suis = try PAL.Gradients.Coder.SwiftGen().encode(gradients)
			try suis.write(to: URL(fileURLWithPath: "/tmp/data.swift"))

			let suis2 = try PAL.Gradients.Coder.SwiftUIGen().encode(gradients)
			try suis2.write(to: URL(fileURLWithPath: "/tmp/dataUI.swift"))
		}
	}

	func testGeneratingPaletteImage() throws {
		let palette = try loadResourcePalette(named: "paintnet-palette.pal")
		let image = try XCTUnwrap(palette.thumbnailImage(size: CGSize(width: 80, height: 80)))
		Swift.print(image)
	}

	func testGenerateMixingPalette() throws {
		do {
			let palette = try PAL.Palette(
				startColor: CGColor(red: 1, green: 0, blue: 0, alpha: 1),
				endColor: CGColor(red: 0.5, green: 0, blue: 0.5, alpha: 1),
				count: 8
			)
			let image = try XCTUnwrap(palette.thumbnailImage(size: CGSize(width: 80, height: 80)))
			Swift.print(image)
		}
		do {
			let palette = try PAL.Palette(
				startColor: CGColor(red: 1, green: 0, blue: 0, alpha: 1),
				endColor: CGColor(red: 1, green: 1, blue: 0, alpha: 1),
				count: 32
			)
			let image = try XCTUnwrap(palette.thumbnailImage(size: CGSize(width: 80, height: 80)))
			Swift.print(image)
		}
	}

	func testGeneratingCGGradientFromPalette() throws {
		let palette = try loadResourcePalette(named: "paintnet-palette.pal")

		do {
			// Create a CGGradient from the palette
			let gradient = try XCTUnwrap(palette.cgGradient(style: .smooth))
			Swift.print(gradient)

			let image = try XCTUnwrap(PAL.Image.GenerateGradientImage(
				gradient: gradient,
				size: CGSize(width: 300, height: 36)
			))
			Swift.print(image)
		}

		do {
			// Create a CGGradient from the palette
			let gradient = try XCTUnwrap(palette.cgGradient(style: .stepped))
			Swift.print(gradient)

			let image = try XCTUnwrap(PAL.Image.GenerateGradientImage(
				gradient: gradient,
				size: CGSize(width: 300, height: 36)
			))
			Swift.print(image)
		}
	}

	@available(macOS 11, iOS 14.0, tvOS 14.0, watchOS 8.0, *)
	func testGeneratingSwiftUIGradientFromPalette() throws {
		let palette = try loadResourcePalette(named: "paintnet-palette.pal")
		let gradient1 = try XCTUnwrap(palette.SwiftUIGradient(style: .smooth))
		XCTAssertEqual(24, gradient1.stops.count)

		// The stepped style has twice as many stop points
		let gradient2 = try XCTUnwrap(palette.SwiftUIGradient(style: .stepped))
		XCTAssertEqual(48, gradient2.stops.count)
	}
}

#endif
