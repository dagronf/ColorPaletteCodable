//
//  CGColor+HexExtensions.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
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

// CoreGraphics extensions for ASEPalette.Color

#if canImport(CoreGraphics)

import CoreGraphics
import Foundation

extension CGColor {
	/// Returns a lowercased hex RGB (no alpha) string representation of this color (eg "#ff6512")
	///
	/// The color is converted to the `genericRGBLinear` colorspace
	var hexRGB: String? {
		guard
			let converted = self.converted(to: PAL.ColorSpace.RGB.cgColorSpace, intent: .defaultIntent, options: nil),
			let r = converted.components?[0],
			let g = converted.components?[1],
			let b = converted.components?[2]
		else {
			return nil
		}
		
		let cr = UInt8(r * 255).clamped(to: 0 ... 255)
		let cg = UInt8(g * 255).clamped(to: 0 ... 255)
		let cb = UInt8(b * 255).clamped(to: 0 ... 255)
		
		return String(format: "#%02x%02x%02x", cr, cg, cb)
	}
	
	/// Returns a lowercased hex RGBA string representation of this color (eg "#ff6512C5")
	///
	/// The color is converted to the `genericRGBLinear` colorspace
	var hexRGBA: String? {
		guard
			let converted = self.converted(to: PAL.ColorSpace.RGB.cgColorSpace, intent: .defaultIntent, options: nil),
			let r = converted.components?[0],
			let g = converted.components?[1],
			let b = converted.components?[2],
			let a = converted.components?[3]
		else {
			return nil
		}
		
		let cr = UInt8(r * 255).clamped(to: 0 ... 255)
		let cg = UInt8(g * 255).clamped(to: 0 ... 255)
		let cb = UInt8(b * 255).clamped(to: 0 ... 255)
		let ca = UInt8(a * 255).clamped(to: 0 ... 255)
		
		return String(format: "#%02x%02x%02x%02x", cr, cg, cb, ca)
	}
}

#endif
