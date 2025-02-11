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

public extension PAL.Color {
	/// The components for an HSL color
	struct HSL: Equatable {
		public init(h: Float32, s: Float32, l: Float32, a: Float32 = 1.0) {
			self.h = h.clamped(to: 0...1)
			self.s = s.clamped(to: 0...1)
			self.l = l.clamped(to: 0...1)
			self.a = a.clamped(to: 0...1)
		}

		public init(h360: Int, s100: Int, l100: Int, a: Float32 = 1.0) {
			self.h = (Float32(h360) / 360.0).clamped(to: 0...1)
			self.s = (Float32(s100) / 100.0).clamped(to: 0...1)
			self.l = (Float32(l100) / 100.0).clamped(to: 0...1)
			self.a = a.clamped(to: 0...1)
		}

		public static func == (lhs: PAL.Color.HSL, rhs: PAL.Color.HSL) -> Bool {
			return
				abs(lhs.h - rhs.h) < 0.005 &&
				abs(lhs.s - rhs.s) < 0.005 &&
				abs(lhs.l - rhs.l) < 0.005 &&
				abs(lhs.a - rhs.a) < 0.005
		}

		/// Hue value as a value in the range 0 ... 1
		public let h: Float32
		/// Hue value as a value in the range 0 ... 360
		public var h360: Float32 { (self.h * 360.0).clamped(to: 0 ... 360) }
		/// Saturation value as a value in the range 0 ... 1
		public let s: Float32
		/// Saturation value as a value in the range 0 ... 100
		public var s100: Float32 { (self.s * 100.0).clamped(to: 0 ... 100) }
		/// Brightness value as a value in the range 0 ... 1
		public let l: Float32
		/// Brightness value as a value in the range 0 ... 100
		public var l100: Float32 { (self.l * 100.0).clamped(to: 0 ... 100) }
		/// Alpha value as a value in the range 0 ... 1
		public let a: Float32
	}
}

// MARK: - Conversions and helpers

public extension PAL.Color {
	/// Convert this color to HSL
	func hsl() throws -> PAL.Color.HSL {
		let c = try self.converted(to: .RGB)
		let hsl = rgb2hsl(r: c._r, g: c._g, b: c._b, a: c.alpha)
		return PAL.Color.HSL(h: hsl.h, s: hsl.s, l: hsl.l, a: hsl.a)
	}

	init(h: Float32, s: Float32, l: Float32, a: Float32 = 1.0) throws {
		let p = PAL.Color.HSL(h: h, s: s, l: l, a: a)
		let rgb = p.rgb()
		try self.init(rf: rgb.r, gf: rgb.g, bf: rgb.b, af: rgb.a)
	}

	@inlinable init(h360: Float32, s100: Float32, l100: Float32, a: Float32 = 1.0) throws {
		try self.init(h: h360 / 360.0, s: s100 / 100, l: l100 / 100, a: a.clamped(to: 0.0 ... 1.0))
	}

	init(_ color: PAL.Color.HSL) throws {
		try self.init(h: color.h, s: color.s, l: color.l, a: color.a)
	}
}

extension PAL.Color.HSL {
	/// Convert HSL to RGB
	public func rgb() -> PAL.Color.RGB {
		let rgb = hsl2rgb(h: self.h, s: self.s, l: self.l, a: self.a)
		return PAL.Color.RGB(r: rgb.r, g: rgb.g, b: rgb.b, a: rgb.a)
	}
}

extension PAL.Color.RGB {
	/// Convert HSL to RGB
	public func hsl() -> PAL.Color.HSL {
		let hsl = rgb2hsl(r: self.r, g: self.g, b: self.b, a: self.a)
		return PAL.Color.HSL(h: hsl.h, s: hsl.s, l: hsl.l, a: hsl.a)
	}
}

// MARK: - Private implementation

// https://www.easyrgb.com/en/math.php
// https://www.niwa.nu/2013/05/math-behind-colorspace-conversions-rgb-hsl/

private func rgb2hsl(r: Float32, g: Float32, b: Float32, a: Float32) -> (h: Float32, s: Float32, l: Float32, a: Float32) {
	let cmax = max(r, g, b)
	let cmin = min(r, g, b)
	let delta = cmax - cmin

	// Luminance
	let l: Float32 = (cmax + cmin) / 2.0

	var h: Float32 = 0.0
	var s: Float32 = 0.0

	if delta != 0.0 {
		// Has chromatic data...
		if l < 0.5 {
			s = delta / (cmax + cmin)
		}
		else {
			s = delta / (2 - cmax - cmin)
		}

		let del_R = (((cmax - r) / 6) + (delta / 2)) / delta
		let del_G = (((cmax - g) / 6) + (delta / 2)) / delta
		let del_B = (((cmax - b) / 6) + (delta / 2)) / delta

		if r == cmax {
			h = del_B - del_G
		}
		else if g == cmax {
			h = (1 / 3) + del_R - del_B
		}
		else if b == cmax {
			h = (2 / 3) + del_G - del_R
		}

		if h < 0 {
			h += 1
		}
		if h > 1 {
			h -= 1
		}
	}
	return (h: h, s: s, l: l, a: a)
}

private func hsl2rgb(h: Float32, s: Float32, l: Float32, a: Float32) -> (r: Float32, g: Float32, b: Float32, a: Float32) {
	func hue2rgb(_ v1: Float32, _ v2: Float32, _ vH: Float32) -> Float32 {
		var vH = vH
		if vH < 0 { vH += 1 }
		if vH > 1 { vH -= 1 }
		if (6 * vH) < 1 { return v1 + (v2 - v1) * 6 * vH }
		if (2 * vH) < 1 { return v2 }
		if (3 * vH) < 2 { return v1 + (v2 - v1) * ((2 / 3) - vH) * 6 }
		return v1
	}

	if s == 0 {
		return (r: l, g: l, b: l, a: a)
	}

	var var_2: Float32
	if l < 0.5 {
		var_2 = l * (1 + s)
	}
	else {
		var_2 = (l + s) - (s * l)
	}

	let var_1 = 2 * l - var_2

	let r = hue2rgb(var_1, var_2, h + (1 / 3))
	let g = hue2rgb(var_1, var_2, h)
	let b = hue2rgb(var_1, var_2, h - (1 / 3))

	return (r: r, g: g, b: b, a: a)
}
