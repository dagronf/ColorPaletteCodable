//
//  PAL+HSB.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

public extension PAL.Color {
	/// Create a color using hsb values
	init(name: String = "", h: Float32, s: Float32, b: Float32, a: Float32, colorType: PAL.ColorType = .global) throws {
		let h = CGFloat(h.clamped(to: 0...1))
		let s = CGFloat(s.clamped(to: 0...1))
		let b = CGFloat(b.clamped(to: 0...1))
		let a = CGFloat(a.clamped(to: 0...1))
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
