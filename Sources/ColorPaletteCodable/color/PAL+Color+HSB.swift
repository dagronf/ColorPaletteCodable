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

// MARK: - Global creators

/// Create a color from fractional HSB values
/// - Parameters:
///   - name: The color name
///   - hf: The hue (0.0 ... 1.0)      / 0 ... 360 /
///   - sf: Saturation (0.0 ... 1.0)   / 0 ... 100 /
///   - bf: Brightness (0.0 ... 1.0)   / 0 ... 100 /
///   - af: The alpha component (0.0 ... 1.0)
///   - colorType: The type of color
/// - Returns: A new color
public func hsbf(
	_ hf: Double,
	_ sf: Double,
	_ bf: Double,
	_ af: Double = 1.0,
	name: String = "",
	colorType: PAL.ColorType = .global
) -> PAL.Color {
	PAL.Color(hf: hf, sf: sf, bf: bf, af: af, name: name, colorType: colorType)
}

/// Create a color from HSB values
/// - Parameters:
///   - h360: The hue (0.0 ... 360.0)   /0 ... 360/
///   - s100: Saturation (0.0 ... 100.0)
///   - b100: Brightness (0.0 ... 100.0)
///   - alpha: The alpha component (0.0 ... 1.0)
///   - name: The color name
///   - colorType: The type of color
/// - Returns: A new color
public func hsb360(
	_ h360: Double,
	_ s100: Double,
	_ b100: Double,
	_ alpha: Double = 1.0,
	name: String = "",
	colorType: PAL.ColorType = .global
) -> PAL.Color {
	PAL.Color(h360: h360, s100: s100, b100: b100, alpha: alpha, name: name, colorType: colorType)
}

// MARK: - Basic HSB structure

public extension PAL.Color {
	/// The components for an HSB color
	struct HSB: Equatable {
		/// Create a color with an HSB value
		/// - Parameters:
		///   - hf: Hue value (clamped to 0 ... 1)
		///   - sf: Saturation value (clamped to 0 ... 1)
		///   - bf: Brightness value (clamped to 0 ... 1)
		///   - af: Alpha value (clamped to 0 ... 1)
		public init(hf: Double, sf: Double, bf: Double, af: Double = 1.0) {
			self.hf = hf.unitClamped
			self.sf = sf.unitClamped
			self.bf = bf.unitClamped
			self.af = af.unitClamped
		}

		/// Create a color with an HSB value
		/// - Parameters:
		///   - h360: Hue value (clamped to 0 ... 360)
		///   - s100: Saturation value (clamped to 0 ... 100)
		///   - b100: Brightness value (clamped to 0 ... 1100)
		///   - af: Alpha value (clamped to 0 ... 1)
		public init(h360: Double, s100: Double, b100: Double, af: Double = 1.0) {
			self.hf = (h360 / 360.0).unitClamped
			self.sf = (s100 / 100.0).unitClamped
			self.bf = (b100 / 100.0).unitClamped
			self.af = af.unitClamped
		}

		public static func == (lhs: PAL.Color.HSB, rhs: PAL.Color.HSB) -> Bool {
			return
				abs(lhs.hf - rhs.hf) < 0.005 &&
				abs(lhs.sf - rhs.sf) < 0.005 &&
				abs(lhs.bf - rhs.bf) < 0.005 &&
				abs(lhs.af - rhs.af) < 0.005
		}

		/// Hue value as a value in the range 0 ... 1
		public let hf: Double
		/// Hue value as a value in the range 0 ... 360
		public var h360: Double { (hf * 360.0).clamped(to: 0 ... 360) }
		/// Saturation value as a value in the range 0 ... 1
		public let sf: Double
		/// Saturation value as a value in the range 0 ... 100
		public var s100: Double { (sf * 100.0).clamped(to: 0 ... 100) }
		/// Brightness value as a value in the range 0 ... 1
		public let bf: Double
		/// Brightness value as a value in the range 0 ... 100
		public var b100: Double { (bf * 100.0).clamped(to: 0 ... 100) }
		/// Alpha value as a value in the range 0 ... 1
		public let af: Double
	}
}

// MARK: - Color HSB support

public extension PAL.Color {
	/// Create a color using fractional hsb values
	/// - Parameters:
	///   - hf: The hue (0.0 ... 1.0)      / 0 ... 360 /
	///   - sf: Saturation (0.0 ... 1.0)   / 0 ... 100 /
	///   - bf: Brightness (0.0 ... 1.0)   / 0 ... 100 /
	///   - af: The alpha component (0.0 ... 1.0)
	///   - name: The color name
	///   - colorType: The color type
	init(
		hf: Double,
		sf: Double,
		bf: Double,
		af: Double = 1.0,
		name: String = "",
		colorType: PAL.ColorType = .global
	) {
		let hsb = hsb2rgb(h: hf.unitClamped, s: sf.unitClamped, b: bf.unitClamped, a: af.unitClamped)
		self.init(rf: hsb.r, gf: hsb.g, bf: hsb.b, af: hsb.a, name: name, colorType: colorType)
	}

	/// Create a color using fractional hsb values
	/// - Parameters:
	///   - h360: The hue (0 ... 360)
	///   - s100: Saturation (0.0 ... 100.0)
	///   - b100: Brightness (0.0 ... 100.0)
	///   - alpha: The alpha component (0.0 ... 1.0)
	///   - name: The color name
	///   - colorType: The color type
	init(
		h360: Double,
		s100: Double,
		b100: Double,
		alpha: Double = 1.0,
		name: String = "",
		colorType: PAL.ColorType = .global
	) {
		self.init(hf: h360 / 360.0, sf: s100 / 100.0, bf: b100 / 100.0, af: alpha, name: name, colorType: colorType)
	}

	/// Create a color using hsb values
	/// - Parameters:
	///   - color: The HSB color
	///   - name: The color name
	///   - colorType: The color type
	@inlinable init(_ color: PAL.Color.HSB, name: String = "", colorType: PAL.ColorType = .global) {
		self.init(hf: color.hf, sf: color.sf, bf: color.bf, af: color.af, name: name, colorType: colorType)
	}
}

extension PAL.Color {
	/// Get the hsb values for the color
	public func hsb() throws -> PAL.Color.HSB {
		let c = try self.converted(to: .RGB)
		let hsb = rgb2hsb(r: c._r, g: c._g, b: c._b, a: c.alpha)
		return PAL.Color.HSB(hf: hsb.h, sf: hsb.s, bf: hsb.b, af: hsb.a)
	}
}

extension PAL.Color.RGB {
	/// Return this color as a Hue-Saturation-Brightness color
	/// - Returns: HSB color
	public func hsb() -> PAL.Color.HSB {
		let hsb = RGB_to_HSB(r: self.rf, g: self.gf, b: self.bf)
		return PAL.Color.HSB(hf: hsb.h, sf: hsb.s, bf: hsb.b, af: self.af)
	}
}

// MARK: - Private implementations

private func rgb2hsb(r: Double, g: Double, b: Double, a: Double) -> (h: Double, s: Double, b: Double, a: Double) {

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

	return (Double(hh), Double(hs), Double(hb), Double(ha))
}

private func hsb2rgb(h: Double, s: Double, b: Double, a: Double) -> (r: Double, g: Double, b: Double, a: Double) {
	var rr: CGFloat = 0
	var rg: CGFloat = 0
	var rb: CGFloat = 0
	var ra: CGFloat = 1
#if os(macOS)
	// Use AppKit
	let c = NSColor(calibratedHue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(b), alpha: CGFloat(a))
	c.getRed(&rr, green: &rg, blue: &rb, alpha: &ra)
	return (Double(rr), Double(rg), Double(rb), Double(ra))
#elseif os(iOS) || os(tvOS) || os(watchOS)
	// Use UIKit
	let c = UIColor(hue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(b), alpha: CGFloat(a))
	c.getRed(&rr, green: &rg, blue: &rb, alpha: &ra)
	return (Double(rr), Double(rg), Double(rb), Double(ra))
#else
	// Use routine
	let rgb = HSB_to_RGB(h: h, s: s, b: b)
	return (rgb.r, rgb.g, rgb.b, a)
#endif
}
