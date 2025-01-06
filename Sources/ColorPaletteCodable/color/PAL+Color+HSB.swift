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

#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

public extension PAL.Color {
	/// Create a color using fractional hsb values
	/// - Parameters:
	///   - name: The color name
	///   - h360: The hue (0 ... 360)
	///   - s100: Saturation (0.0 ... 100.0)
	///   - b100: Brightness (0.0 ... 100.0)
	///   - alpha: The alpha component (0.0 ... 1.0)
	///   - colorType: The color type
	init(
		name: String = "",
		h360: Float32,
		s100: Float32,
		b100: Float32,
		alpha: Float32 = 1.0,
		colorType: PAL.ColorType = .global
	) throws {
		try self.init(
			name: name,
			h: h360 / 360.0,
			s: s100 / 100.0,
			b: b100 / 100.0,
			alpha: alpha,
			colorType: colorType
		)
	}

	/// Create a color using fractional hsb values
	/// - Parameters:
	///   - name: The color name
	///   - h: The hue (0.0 ... 1.0)      / 0 ... 360 /
	///   - s: Saturation (0.0 ... 1.0)   / 0 ... 100 /
	///   - b: Brightness (0.0 ... 1.0)   / 0 ... 100 /
	///   - alpha: The alpha component (0.0 ... 1.0)
	///   - colorType: The color type
	init(
		name: String = "",
		h: Float32,
		s: Float32,
		b: Float32,
		alpha: Float32 = 1.0,
		colorType: PAL.ColorType = .global
	) throws {
		let h = CGFloat(h.clamped(to: 0...1))
		let s = CGFloat(s.clamped(to: 0...1))
		let b = CGFloat(b.clamped(to: 0...1))
		let a = CGFloat(alpha.clamped(to: 0...1))
#if os(macOS)
		// Use AppKit
		let c = NSColor(calibratedHue: h, saturation: s, brightness: b, alpha: a).cgColor
		let cc = c.converted(to: PAL.ColorSpace.RGB.cgColorSpace, intent: .defaultIntent, options: nil) ?? c
		try self.init(cgColor: cc, name: name, colorType: colorType)
#elseif os(iOS) || os(tvOS) || os(watchOS)
		// Use UIKit
		let c = UIColor(hue: h, saturation: s, brightness: b, alpha: a).cgColor
		try self.init(cgColor: c, name: name, colorType: colorType)
#else
		// Use routine
		let RGB = HSB_to_RGB((h: h, s: s, b: b))
		try self.init(
			name: name,
			rf: Float32(RGB.r),
			gf: Float32(RGB.g),
			bf: Float32(RGB.b),
			af: Float32(a),
			colorType: colorType
		)
#endif
	}

	/// Create a color from HSB values
	/// - Parameters:
	///   - name: The color name
	///   - h360: The hue (0.0 ... 360.0)   /0 ... 360/
	///   - s100: Saturation (0.0 ... 100.0)
	///   - b100: Brightness (0.0 ... 100.0)
	///   - alpha: The alpha component (0.0 ... 1.0)
	///   - colorType: The type of color
	/// - Returns: A new color
	static func hsb360(
		name: String = "",
		_ h360: Float32,
		_ s100: Float32,
		_ b100: Float32,
		_ alpha: Float32 = 1.0,
		colorType: PAL.ColorType = .global
	) -> PAL.Color {
		// We know that the color has the correct components here
		PAL.Color.hsb(name: name, h360 / 360.0, s100 / 100.0, b100 / 100.0, alpha, colorType: colorType)
	}

	/// Create a color from fractional HSB values
	/// - Parameters:
	///   - name: The color name
	///   - h: The hue (0.0 ... 1.0)      / 0 ... 360 /
	///   - s: Saturation (0.0 ... 1.0)   / 0 ... 100 /
	///   - b: Brightness (0.0 ... 1.0)   / 0 ... 100 /
	///   - alpha: The alpha component (0.0 ... 1.0)
	///   - colorType: The type of color
	/// - Returns: A new color
	static func hsb(
		name: String = "",
		_ h: Float32,
		_ s: Float32,
		_ b: Float32,
		_ alpha: Float32 = 1.0,
		colorType: PAL.ColorType = .global
	) -> PAL.Color {
		// We know that the color has the correct components here
		try! PAL.Color(h: h, s: s, b: b, alpha: alpha)
	}
}

extension PAL.Color {
	/// Get the hsb values for the color
	public func hsb() throws -> PAL.Color.HSB {
		var c = self
		if c.colorSpace != .RGB {
			// Convert to RGB
			c = try self.converted(to: .RGB)
		}

		var h: CGFloat = 0
		var s: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0

#if os(macOS)
		guard
			let cgColor = self.cgColor,
			let nsc = NSColor(cgColor: cgColor) else {
			throw PAL.CommonError.unsupportedPaletteType
		}
		nsc.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
#elseif os(iOS) || os(tvOS) || os(watchOS)
		guard let cgColor = self.cgColor else {
			throw PAL.CommonError.unsupportedPaletteType
		}
		let usc = UIColor(cgColor: cgColor)
		usc.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
#else
		let hsb = RGB_to_HSB(RGB: (
			r: CGFloat(try c.r()),
			g: CGFloat(try c.g()),
			b: CGFloat(try c.b())
		))
		h = CGFloat(hsb.h)
		s = CGFloat(hsb.s)
		b = CGFloat(hsb.b)
		a = CGFloat(self.alpha)
#endif
		return PAL.Color.HSB(
			h: Float32(h),
			s: Float32(s),
			b: Float32(b),
			a: Float32(a)
		)
	}
}
