//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

// Analogous color schemes are created by using colors that are next to each other on the color wheel

#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

extension PAL {
	public enum FunctionError: Error {
		case monochromaticSpanTooLarge
	}
}

extension PAL.Color {

	/// Returns the complementary color
	public func complementary() throws -> PAL.Color {
		// Get the color's hue
		let hsba = try hsb()

		// Rotate the hue to the other side of the color wheel
		let h = (hsba.h - 0.5).wrappingToUnitValue()

		// Create a new color using the new hue
		return try PAL.Color(h: h, s: hsba.s, b: hsba.b, alpha: hsba.a)
	}

	/// The style of
	public enum MonochromeStyle {
		/// Modify the saturation
		case saturation
		/// Modify the brightness
		case brightness
	}

	/// Returns a monochromatic collection of colors
	/// - Parameters:
	///   - style: The monochromatic style
	///   - count: The number of colors to return (including the current color)
	///   - step: The amount to reduce the saturation for each count (-1 ... 1). A positive value means positive saturation
	/// - Returns: An array of monochromatic colors based on this color
	public func monochromatic(style: MonochromeStyle, count: UInt, step: Float32) throws -> [PAL.Color] {
		// Get the color's hue
		let hsba = try hsb()
		let dest = step * Float32(count - 1)
		var results: [PAL.Color] = []
		try stride(from: 0, through: dest, by: step).forEach { offset in
			let color: PAL.Color
			switch style {
			case .saturation:
				color = try PAL.Color(h: hsba.h, s: hsba.s + offset, b: hsba.b, alpha: hsba.a)
			case .brightness:
				color = try PAL.Color(h: hsba.h, s: hsba.s, b: hsba.b + offset, alpha: hsba.a)
			}
			results.append(color)
		}

		return results
	}

	/// Returns an analogous color scheme based on this color
	/// - Parameters:
	///   - count: The number of colors to return
	///   - stepSize: The spacing between the colors on the color wheel
	/// - Returns: An array of analogous colors
	///
	/// https://www.w3schools.com/colors/colors_analogous.asp
	func analogous(count: Int = 6, stepSize: Double = 0.1) throws -> [PAL.Color] {
		assert(stepSize > 0)
		assert(stepSize < 1)
		assert(count > 1)
		let hsba = try hsb()
		let totalSweep = Double(count - 1) * stepSize
		let offset = totalSweep / 2.0
		let hStart = (Double(hsba.h) - offset).wrappingToUnitValue()
		var colors = [PAL.Color]()
		try (0 ..< count).forEach { index in
			let pos = (hStart + (Double(index) * stepSize)).wrappingToUnitValue()
			colors.append(try PAL.Color(
				h: Float32(pos),
				s: hsba.s,
				b: hsba.b,
				alpha: hsba.a
			))
		}
		return colors
	}
}
