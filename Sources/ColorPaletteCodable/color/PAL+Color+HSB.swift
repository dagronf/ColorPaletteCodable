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
	/// The components for an HSB color
	struct HSB: Equatable {
		public init(h: Float32, s: Float32, b: Float32, a: Float32 = 1.0) {
			self.h = h.clamped(to: 0...1)
			self.s = s.clamped(to: 0...1)
			self.b = b.clamped(to: 0...1)
			self.a = a.clamped(to: 0...1)
		}

		public init(h360: Float32, s100: Float32, b100: Float32, a: Float32 = 1.0) {
			self.h = (h360 / 360.0).clamped(to: 0...1)
			self.s = (s100 / 100.0).clamped(to: 0...1)
			self.b = (b100 / 100.0).clamped(to: 0...1)
			self.a = a.clamped(to: 0...1)
		}

		public static func == (lhs: PAL.Color.HSB, rhs: PAL.Color.HSB) -> Bool {
			return
				abs(lhs.h - rhs.h) < 0.005 &&
				abs(lhs.s - rhs.s) < 0.005 &&
				abs(lhs.b - rhs.b) < 0.005 &&
				abs(lhs.a - rhs.a) < 0.005
		}

		/// Hue value as a value in the range 0 ... 1
		public let h: Float32
		/// Hue value as a value in the range 0 ... 360
		public var h360: Float32 { (h * 360.0).clamped(to: 0 ... 360) }
		/// Saturation value as a value in the range 0 ... 1
		public let s: Float32
		/// Saturation value as a value in the range 0 ... 100
		public var s100: Float32 { (s * 100.0).clamped(to: 0 ... 100) }
		/// Brightness value as a value in the range 0 ... 1
		public let b: Float32
		/// Brightness value as a value in the range 0 ... 100
		public var b100: Float32 { (b * 100.0).clamped(to: 0 ... 100) }
		/// Alpha value as a value in the range 0 ... 1
		public let a: Float32
	}
}

// MARK: - Conversions and helpers

public extension PAL.Color {
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
		let h = h.clamped(to: 0...1)
		let s = s.clamped(to: 0...1)
		let b = b.clamped(to: 0...1)
		let a = alpha.clamped(to: 0...1)

		let hsb = hsb2rgb(h: h, s: s, b: b, a: a)
		try self.init(name: name, rf: hsb.r, gf: hsb.g, bf: hsb.b, af: hsb.a, colorType: colorType)
	}

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

	/// Create a color using hsb values
	/// - Parameters:
	///   - name: The color name
	///   - color: The HSB color
	///   - colorType: The color type
	@inlinable init(name: String = "", _ color: PAL.Color.HSB, colorType: PAL.ColorType = .global) throws {
		try self.init(name: name, h: color.h, s: color.s, b: color.b, alpha: color.a, colorType: colorType)
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
		let c = try self.converted(to: .RGB)
		let hsb = rgb2hsb(r: c._r, g: c._g, b: c._b, a: c.alpha)
		return PAL.Color.HSB(h: hsb.h, s: hsb.s, b: hsb.b, a: hsb.a)
	}
}

extension PAL.Color.RGB {
	/// Return this color as a Hue-Saturation-Brightness color
	/// - Returns: HSB color
	public func hsb() -> PAL.Color.HSB {
		let hsb = RGB_to_HSB(r: self.r, g: self.g, b: self.b)
		return PAL.Color.HSB(h: hsb.h, s: hsb.s, b: hsb.b, a: self.a)
	}
}

// MARK: - Private implementations

private func rgb2hsb(r: Float32, g: Float32, b: Float32, a: Float32) -> (h: Float32, s: Float32, b: Float32, a: Float32) {

	var hh: CGFloat = 0
	var hs: CGFloat = 0
	var hb: CGFloat = 0
	var ha: CGFloat = 0

	#if os(macOS)
	let c = NSColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
	c.getHue(&hh, saturation: &hs, brightness: &hb, alpha: &ha)
	#elseif os(iOS) || os(tvOS) || os(watchOS)
	let c = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
	c.getHue(&hh, saturation: &hs, brightness: &hb, alpha: &ha)
	#else
	let hsb = RGB_to_HSB(r: r, g: g, b: b)
	hh = CGFloat(hsb.h)
	hs = CGFloat(hsb.s)
	hb = CGFloat(hsb.b)
	ha = CGFloat(a)
	#endif

	return (Float32(hh), Float32(hs), Float32(hb), Float32(ha))
}

private func hsb2rgb(h: Float32, s: Float32, b: Float32, a: Float32) -> (r: Float32, g: Float32, b: Float32, a: Float32) {
	var rr: CGFloat = 0
	var rg: CGFloat = 0
	var rb: CGFloat = 0
	var ra: CGFloat = 1
#if os(macOS)
	// Use AppKit
	let c = NSColor(calibratedHue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(b), alpha: CGFloat(a))
	c.getRed(&rr, green: &rg, blue: &rb, alpha: &ra)
	return (Float32(rr), Float32(rg), Float32(rb), Float32(ra))
#elseif os(iOS) || os(tvOS) || os(watchOS)
	// Use UIKit
	let c = UIColor(hue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(b), alpha: CGFloat(a))
	c.getRed(&rr, green: &rg, blue: &rb, alpha: &ra)
	return (Float32(rr), Float32(rg), Float32(rb), Float32(ra))
#else
	// Use routine
	let rgb = HSB_to_RGB(h: h, s: s, b: b)
	return (rgb.r, rgb.g, rgb.b, a)
#endif
}
