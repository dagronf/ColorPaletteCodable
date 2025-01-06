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
	/// Return a hex RGB string (eg. "523b50", "#523b50") without an alpha component
	/// - Parameters:
	///   - hashmark: If true, includes a hash mark '#' at the start of the string
	///   - uppercase: If true, uppercases the string
	/// - Returns: Hex encoded color
	func hexRGB(hashmark: Bool, uppercase: Bool = false) throws -> String {
		try self.hexRGB(includeAlpha: false, hashmark: hashmark, uppercase: uppercase)
	}

	/// Return a hex RGBA string (eg. "523b50") with an alpha component
	/// - Parameters:
	///   - hashmark: If true, includes a hash mark '#' at the start of the string
	///   - uppercase: If true, uppercases the string
	/// - Returns: Hex encoded color
	func hexRGBA(hashmark: Bool, uppercase: Bool = false) throws -> String {
		try self.hexRGB(includeAlpha: true, hashmark: hashmark, uppercase: uppercase)
	}

	/// Return a hex RGB string (eg. "523b50ff", "#523b50")
	/// - Parameters:
	///   - includeAlpha: If true, includes the alpha component
	///   - hashmark: If true, includes a hash mark '#' at the start of the string
	///   - uppercase: If true, uppercases the string
	/// - Returns: Hex encoded color
	///
	/// If the underlying colorspace is not RGB attempts conversion to RGB before failing
	func hexRGB(includeAlpha: Bool, hashmark: Bool, uppercase: Bool) throws -> String {
		let rgb = try self.converted(to: .RGB)
		let r = rgb.colorComponents[0]
		let g = rgb.colorComponents[1]
		let b = rgb.colorComponents[2]
		let a = rgb.alpha

		let cr = UInt8(r * 255).clamped(to: 0 ... 255)
		let cg = UInt8(g * 255).clamped(to: 0 ... 255)
		let cb = UInt8(b * 255).clamped(to: 0 ... 255)
		let ca = UInt8(a * 255).clamped(to: 0 ... 255)

		var result = hashmark ? "#" : ""
		result += String(format: uppercase ? "%02X%02X%02X" : "%02x%02x%02x", cr, cg, cb)
		if includeAlpha {
			result += String(format: uppercase ? "%02X" : "%02x", ca)
		}
		return result
	}

	/// Return a hex ARGB string (eg. "523b50ff", "#523b50")
	/// - Parameters:
	///   - includeAlpha: If true, includes the alpha component
	///   - hashmark: If true, includes a hash mark '#' at the start of the string
	///   - uppercase: If true, uppercases the string
	/// - Returns: Hex encoded color
	///
	/// If the underlying colorspace is not RGB attempts conversion to RGB before failing
	func hexARGB(includeAlpha: Bool, hashmark: Bool, uppercase: Bool) throws -> String {
		let rgb = try self.converted(to: .RGB)
		let r = rgb.colorComponents[0]
		let g = rgb.colorComponents[1]
		let b = rgb.colorComponents[2]
		let a = rgb.alpha

		let cr = UInt8(r * 255).clamped(to: 0 ... 255)
		let cg = UInt8(g * 255).clamped(to: 0 ... 255)
		let cb = UInt8(b * 255).clamped(to: 0 ... 255)
		let ca = UInt8(a * 255).clamped(to: 0 ... 255)

		var result = hashmark ? "#" : ""
		if includeAlpha {
			result += String(format: uppercase ? "%02X" : "%02x", ca)
		}
		result += String(format: uppercase ? "%02X%02X%02X" : "%02x%02x%02x", cr, cg, cb)
		return result
	}
}
