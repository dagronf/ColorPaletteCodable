//
//  CGColor+HexExtensions.swift
//
//  Created by Darren Ford on 16/5/2022.
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

#if os(macOS) || os(iOS) || os(tvOS)

import CoreGraphics
import Foundation

extension CGColor {
	/// Returns a lowercased hex RGB (no alpha) string representation of this color (eg "#ff6512")
	///
	/// The color is converted to the `genericRGBLinear` colorspace
	var hexRGB: String? {
		let cs = CGColorSpace(name: CGColorSpace.genericRGBLinear)!
		guard
			let converted = self.converted(to: cs, intent: .defaultIntent, options: nil),
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
		let cs = CGColorSpace(name: CGColorSpace.genericRGBLinear)!
		guard
			let converted = self.converted(to: cs, intent: .defaultIntent, options: nil),
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

extension CGColor {
	/// Create a CGColor from a hex RGB string representation (eg. "#45AA75" or "45aa75")
	///
	/// Note: Does not validate the input string.
	static func fromRGBHexString(_ rgbHexString: String) -> CGColor? {
		// Validate the string length
		guard rgbHexString.count == 6 || rgbHexString.count == 7 else { return nil }
		
		// Create scanner
		let scanner = Scanner(string: rgbHexString)
		scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
		var hexNumber: UInt64 = 0
		if scanner.scanHexInt64(&hexNumber) {
			let cs = CGColorSpace(name: CGColorSpace.genericRGBLinear)!
			let r = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
			let g = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
			let b = CGFloat(hexNumber & 0x0000_00FF) / 255
			return CGColor(colorSpace: cs, components: [r, g, b, 1])
		}
		return nil
	}
	
	/// Create a CGColor from a hex RGBA string representation (eg. "#45AA756C" or "45aa7510")
	///
	/// Note: Does not validate the input string.
	static func fromRGBAHexString(_ rgbaHexString: String) -> CGColor? {
		// Validate the string length
		guard rgbaHexString.count == 8 || rgbaHexString.count == 9 else { return nil }
		
		// Create scanner
		let scanner = Scanner(string: rgbaHexString)
		scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
		var hexNumber: UInt64 = 0
		if scanner.scanHexInt64(&hexNumber) {
			let cs = CGColorSpace(name: CGColorSpace.genericRGBLinear)!
			let r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
			let g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
			let b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
			let a = CGFloat(hexNumber & 0x0000_00FF) / 255
			return CGColor(colorSpace: cs, components: [r, g, b, a])
		}
		return nil
	}
}

#endif
