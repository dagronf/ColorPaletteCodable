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

/// Map the provided value within a 0 ... 360 range, wrapping if needed
@inlinable func h360(_ value: Float32) -> Float32 {
	let e = value.truncatingRemainder(dividingBy: 360)
	return e < 0 ? e + 360 : e
}

extension PAL.Color {
	/// Returns the complementary color for this color
	public func complementary() throws -> PAL.Color {
		// Get the color's hue
		let hsba = try hsb()

		// Rotate the hue to the other side of the color wheel
		let h = (hsba.h - 0.5).wrappingToUnitValue()

		// Create a new color using the new hue
		return PAL.Color(hf: h, sf: hsba.s, bf: hsba.b, af: hsba.a)
	}

	/// The style of monochromacity
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
		stride(from: 0, through: dest, by: step).forEach { offset in
			let color: PAL.Color
			switch style {
			case .saturation:
				color = PAL.Color(hf: hsba.h, sf: hsba.s + offset, bf: hsba.b, af: hsba.a)
			case .brightness:
				color = PAL.Color(hf: hsba.h, sf: hsba.s, bf: hsba.b + offset, af: hsba.a)
			}
			results.append(color)
		}
		return results
	}

	/// Returns variations of the same hue with evenly spaced saturation stepping
	/// - Parameters:
	///   - count: The number of monochromatic colors to return
	/// - Returns: Array of colors
	public func monochromatic(count: UInt = 4) throws -> [PAL.Color] {
		assert(count > 1)
		let count = Float32(count)

		let hsb = try self.hsb()
		let h = hsb.h360
		let s = max(0.005, hsb.s100)
		let b = hsb.b100

		// Calculate 4 monochromatic colors
		return stride(from: s, to: 0, by: -s / count).map {
			PAL.Color(h360: h, s100: $0, b100: b)
		}
	}

	/// Returns an analogous color scheme based on this color
	/// - Parameters:
	///   - count: The number of colors to return
	///   - stepSize: The spacing between the colors on the color wheel
	/// - Returns: An array of analogous colors
	///
	/// https://www.w3schools.com/colors/colors_analogous.asp
	public func analogous(count: Int, stepSize: Double) throws -> [PAL.Color] {
		assert(stepSize > 0)
		assert(stepSize < 1)
		assert(count > 1)
		let hsba = try hsb()
		let totalSweep = Double(count - 1) * stepSize
		let offset = totalSweep / 2.0
		let hStart = (Double(hsba.h) - offset).wrappingToUnitValue()
		var colors = [PAL.Color]()
		(0 ..< count).forEach { index in
			let pos = (hStart + (Double(index) * stepSize)).wrappingToUnitValue()
			let c = PAL.Color(hf: Float32(pos), sf: hsba.s, bf: hsba.b, af: hsba.a)
			colors.append(c)
		}
		return colors
	}

	/// Returns 3 analogous colors based on this color
	/// - Returns: An array of analogous colors
	///
	/// [https://www.w3schools.com/colors/colors_analogous.asp](https://www.w3schools.com/colors/colors_analogous.asp)
	public func analogous() throws -> [PAL.Color] {
		let hsl = try self.hsl()
		let h = hsl.h360
		let s = hsl.s100
		let l = hsl.l100

		// Calculate the 3 triadic colors
		let colors = [
			(h360(h - 30), s, l),
			(h, s, l),
			(h360(h + 30), s, l),
		]

		// Ensure the hue is wrapped correctly (between 0 and 360 degrees)
		return colors.map { (h: Float32, s: Float32, l: Float32) in
			PAL.Color(h360: h360(h), s100: s, l100: l)
		}
	}

	/// Return the three triadic colors based on this color
	/// - Returns: The three triadic colors for this color
	///
	/// Triadic schemes are made up of hues equally spaced around the color wheel.
	///
	/// [https://www.w3schools.com/colors/colors_triadic.asp](https://www.w3schools.com/colors/colors_triadic.asp)
	public func triadic() throws -> [PAL.Color] {
		let hsl = try self.hsl()
		let h = hsl.h360
		let s = hsl.s100
		let l = hsl.l100

		// Calculate the 3 triadic colors
		let colors = [
			(h, s, l),
			(h360(h + 120.0), s, l),
			(h360(h + 240.0), s, l),
		]

		// Ensure the hue is wrapped correctly (between 0 and 360 degrees)
		return colors.map { (h: Float32, s: Float32, l: Float32) in
			PAL.Color(h360: h, s100: s, l100: l)
		}
	}

	/// Calculate the four tetradic (rectangular) colors for this color
	/// - Returns: Four tetradic colors
	///
	/// A tetradic (or double-complementary) scheme involves four colors forming two complementary pairs.
	/// There are a couple of common approaches, but a standard tetradic relationship often starts with one
	/// hue and then includes its complement, plus another pair of complementary hues 90° away from each.
	///
	/// https://customstickers.com/en-ca/community/blog/how-to-calculate-complementary-triadic-and-tetradic-colors-from-a-hex-code
	public func tetradic() throws -> [PAL.Color] {
		let hsl = try self.hsl()
		let h = hsl.h360
		let s = hsl.s100
		let l = hsl.l100

		let offset: Float32 = 30

		// Calculate the 4 tetradic colors
		let colors = [
			(h, s, l),
			(h360(h - offset), s, l),
			(h360(h + 180.0), s, l),
			(h360(h + 180.0 - offset), s, l)
		]

		// Ensure the hue is wrapped correctly (between 0 and 360 degrees)
		return colors.map { (h: Float32, s: Float32, l: Float32) in
			PAL.Color(h360: h, s100: s, l100: l)
		}
	}

	/// Return the split complementary colors for this color
	/// - Returns: plit complementary colors
	///
	/// https://colorkit.co/split-complementary-colors/
	/// https://www.w3schools.com/colors/colors_compound.asp
	/// https://www.color-meanings.com/split-complementary-colors/
	public func splitComplementary() throws -> [PAL.Color] {
		let hsl = try self.hsl()
		let h = hsl.h360
		let s = hsl.s100
		let l = hsl.l100

		let offset: Float32 = 30
		let colors = [
			(h, s, l),
			(h360(h + 180.0 - offset), s, l),
			(h360(h + 180.0 + offset), s, l),
		]

		// Ensure the hue is wrapped correctly (between 0 and 360 degrees)
		return colors.map { (h: Float32, s: Float32, l: Float32) in
			PAL.Color(h360: h, s100: s, l100: l)
		}
	}

	/// Square color schemes consist of four colors spaced evenly around the color wheel
	/// - Returns: Square colors
	///
	/// https://www.colorsexplained.com/square-colors/
	/// https://www.colorsexplained.com/color-harmony/
	public func square() throws -> [PAL.Color] {
		let hsl = try self.hsl()
		let h = hsl.h360
		let s = hsl.s100
		let l = hsl.l100

		// Calculate the 4 'square' colors
		let colors = [
			(h360(h), s, l),
			(h360(h + 90.0), s, l),
			(h360(h + 180.0), s, l),
			(h360(h + 270.0), s, l),
		]

		// Ensure the hue is wrapped correctly (between 0 and 360 degrees)
		return colors.map { (h: Float32, s: Float32, l: Float32) in
			PAL.Color(h360: h, s100: s, l100: l)
		}
	}

	/// Returns harmonious colors for this color
	/// - Parameter count: The number of harmonious colors
	/// - Returns: colors
	///
	/// https://www.colorsexplained.com/color-harmony/
	public func harmonious(count: Int = 12) throws -> [PAL.Color] {
		let hsl = try self.hsl()
		let h = Float32(hsl.h360)
		let s = Float32(hsl.s100)
		let l = Float32(hsl.l100)
		return stride(from: 0, to: 360, by: 360 / Float32(count)).map {
			PAL.Color(h360: h360(h + $0), s100: s, l100: l)
		}
	}
}

// MARK: - Tinting and shading

public extension PAL.Color {
	/// Returns a shaded representation of this color
	/// - Returns: Shaded color
	///
	/// According to color theory, shades are created by adding black pigment to any hue
	func shade(fraction: Float32) throws -> PAL.Color {
		let fraction = fraction.clamped(to: 0.0 ... 1.0)
		let hsl = try self.hsl()
		return PAL.Color(hf: hsl.hf, sf: hsl.sf, lf: hsl.lf * fraction)
	}

	/// Returns shaded versions of this color
	/// - Parameter count: The number of variations
	/// - Returns: Color shades
	///
	/// According to color theory, shades are created by adding black pigment to any hue
	func shade(count: Int) throws -> [PAL.Color] {
		let rgb = try self.rgb()
		let step = 1.0 / Float32(count)
		return stride(from: 1.0, to: 0.0, by: -step).map {
			PAL.Color(rf: rgb.rf * $0, gf: rgb.gf * $0, bf: rgb.bf * $0)
		}
	}

	/// Returns a tinted version of this color
	/// - Parameter fraction: The fractional tint amount
	/// - Returns: Tinted color
	///
	/// Tints are created by adding white to any hue, according to color theory.
	/// This lightens and desaturates the hue, creating a subtler and lighter color than the original hue.
	func tint(fraction: Float32) throws -> PAL.Color {
		let fraction = fraction.clamped(to: 0.0 ... 1.0)
		let hsl = try self.hsl()
		return PAL.Color(hf: hsl.hf, sf: hsl.sf, lf: hsl.lf + ((1.0 - hsl.lf) * fraction))
	}

	/// Returns tinted versions of this color
	/// - Parameter count: The number of evenly spaced tinted color
	/// - Returns: Tinted colors
	///
	/// Tints are created by adding white to any hue, according to color theory.
	/// This lightens and desaturates the hue, creating a subtler and lighter color than the original hue.
	func tint(count: Int) throws -> [PAL.Color] {
		let hsl = try self.hsl()
		let step = (1.0 - min(0.999, hsl.lf)) / Float32(count)
		return stride(from: hsl.lf, to: 0.999, by: step).map {
			PAL.Color(hf: hsl.hf, sf: hsl.sf, lf: $0)
		}
	}
}

// MARK: - Luminance and contrast

public extension PAL.Color {
	/// Get the color's luminance value
	///
	/// Formula from WCAG 2.0: https://www.w3.org/TR/WCAG20/#relativeluminancedef
	func luminance() throws -> Float32 {
		// Get RGB components
		let rgba = try self.rgb()

		// Calculate relative luminance using sRGB coefficients
		// Formula from WCAG 2.0: https://www.w3.org/TR/WCAG20/#relativeluminancedef
		let ar = (rgba.rf <= 0.03928) ? (rgba.rf / 12.92) : pow((rgba.rf + 0.055) / 1.055, 2.4)
		let ag = (rgba.gf <= 0.03928) ? (rgba.gf / 12.92) : pow((rgba.gf + 0.055) / 1.055, 2.4)
		let ab = (rgba.bf <= 0.03928) ? (rgba.bf / 12.92) : pow((rgba.bf + 0.055) / 1.055, 2.4)

		return Float32((0.2126 * ar) + (0.7152 * ag) + (0.0722 * ab))
	}

	/// Calculates the contrast ratio between this color and the given color
	/// - Parameter otherColor: The color to check against
	/// - Returns: A fractional contrast ratio
	///
	/// WCAG Contrast Guidelines
	/// * Normal text: At least 4.5:1 contrast ratio.
	/// * Large text (18pt or larger, or 14pt bold): At least 3:1 contrast ratio.
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

		let darker = PAL.Color(hf: hsb.h, sf: hsb.s, bf: newBrightness.unitClamped, af: hsb.a)
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
