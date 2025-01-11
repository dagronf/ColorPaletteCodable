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

// MARK: - Luminance and contrast

public extension PAL.Color {
	/// Get the color's luminance value
	///
	/// Formula from WCAG 2.0: https://www.w3.org/TR/WCAG20/#relativeluminancedef
	func luminance() throws -> Float32 {
		// Get RGB components
		let rgba = try self.rgbaComponents()

		// Calculate relative luminance using sRGB coefficients
		// Formula from WCAG 2.0: https://www.w3.org/TR/WCAG20/#relativeluminancedef
		let ar = (rgba.r <= 0.03928) ? (rgba.r / 12.92) : pow((rgba.r + 0.055) / 1.055, 2.4)
		let ag = (rgba.g <= 0.03928) ? (rgba.g / 12.92) : pow((rgba.g + 0.055) / 1.055, 2.4)
		let ab = (rgba.b <= 0.03928) ? (rgba.b / 12.92) : pow((rgba.b + 0.055) / 1.055, 2.4)

		return Float32((0.2126 * ar) + (0.7152 * ag) + (0.0722 * ab))
	}

	/// Calculates the contrast ratio between this color and the given color
	/// - Parameter otherColor: The color to check against
	/// - Returns: A fractional contrast ratio
	func contrastRatio(with otherColor: PAL.Color) throws -> Float32 {
		let l1 = try self.luminance()
		let l2 = try otherColor.luminance()

		// Calculate contrast ratio using WCAG 2.0 formula
		let lighterLuminance = max(l1, l2)
		let darkerLuminance = min(l1, l2)
		return (lighterLuminance + 0.05) / (darkerLuminance + 0.05)
	}

	/// Returns either black or white, whichever provides better contrast with this color
	///
	/// According to the Web Content Accessibility Guidelines (WCAG), which provide recommendations
	/// for text legibility, the luminance threshold that separates light and dark backgrounds is
	/// approximately 0.179.
	///
	/// This is a commonly used value in accessibility testing tools and frameworks.
	@inlinable func contrastingTextColor() throws -> PAL.Color {
		try self.luminance() > 0.179 ? .black : .white
	}
}

// MARK: - Adjust brightness

public extension PAL.Color {
	/// Adjusts the brightness of a color by the given fraction
	/// - Parameters:
	///   - fraction: The amount to modify the color (-1.0 ... 1.0)
	///     - Positive values lighten the color (up to 1.0)
	///     - Negative values darken the color (up to -1.0)
	///   - useSameColorspace: If true, converts the resulting color into the original color space if needed
	/// - Returns: A darker representation of this color
	func adjustBrightness(by fraction: Float32, useSameColorspace: Bool = false) throws -> PAL.Color {
		if fraction.isEqual(to: 0, accuracy: 1e-6) {
			return self
		}
		let rgbColor = try self.converted(to: .RGB)
		let hsb = try rgbColor.hsb()

		let fraction = fraction.clamped(to: -1.0 ... 1.0)
		let newBrightness = hsb.b * (1.0 + fraction)

		let darker = try PAL.Color(h: hsb.h, s: hsb.s, b: newBrightness.unitClamped, alpha: hsb.a)
		if useSameColorspace {
			return try darker.converted(to: self.colorSpace)
		}
		return darker
	}

	/// Darken a color
	/// - Parameters:
	///   - fraction: The fractional amount to darken the color (0.0 ... 1.0)
	///   - useSameColorspace: If true, converts the resulting color into the original color space if needed
	/// - Returns: A color
	@inlinable func darker(by fraction: Float32, useSameColorspace: Bool = false) throws -> PAL.Color {
		try self.adjustBrightness(by: -1.0 * fraction.unitClamped, useSameColorspace: useSameColorspace)
	}

	/// Lighten a color
	/// - Parameters:
	///   - fraction: The fractional amount to lighten the color (0.0 ... 1.0)
	///   - useSameColorspace: If true, converts the resulting color into the original color space if needed
	/// - Returns: A color
	@inlinable func lighter(by fraction: Float32, useSameColorspace: Bool = false) throws -> PAL.Color {
		try self.adjustBrightness(by: fraction.unitClamped, useSameColorspace: useSameColorspace)
	}
}
