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
	/// Create a color from a UInt32 value
	/// - Parameters:
	///   - hexValue: The color value
	///   - format: The expected color byte ordering for the value
	///   - name: The color's name
	init(name: String = "", _ hexValue: UInt32, format: PAL.ColorByteFormat) {
		let c = extractRGBA(hexValue, format: format)
		self.name = name
		self.colorSpace = .RGB
		self.colorComponents = [Float32(c.r) / 255.0, Float32(c.g) / 255.0, Float32(c.b) / 255.0]
		self.colorType = .global
		self.alpha = Float32(c.a) / 255.0
	}

	/// Return a hex RGB string (eg. "523b50ff", "#523b50")
	/// - Parameters:
	///   - format: The format for the hex string
	///   - hashmark: If true, includes a hash mark '#' at the start of the string
	///   - uppercase: If true, uppercases the string
	/// - Returns: Hex encoded color
	///
	/// If the underlying colorspace is not RGB attempts conversion to RGB before failing
	func hexString(_ format: PAL.ColorByteFormat, hashmark: Bool, uppercase: Bool) throws -> String {
		let rgb = try self.rgb()
		return ColorPaletteCodable.hexRGBString(
			r255: rgb.r255,
			g255: rgb.g255,
			b255: rgb.b255,
			a255: rgb.a255,
			format: format,
			hashmark: hashmark,
			uppercase: uppercase
		)
	}

	/// Return a hex RGB string (eg. "523b50", "#523B50")
	/// - Parameters:
	///   - hashmark: If true, includes a hashmark at the beginning
	///   - uppercase: If true, uses uppercase characters
	/// - Returns: hex string
	@inlinable func hexRGB(hashmark: Bool, uppercase: Bool = false) throws -> String {
		try self.hexString(.rgb, hashmark: hashmark, uppercase: uppercase)
	}

	/// Return a hex RGBA string (eg. "523b50ff", "#523B50FF")
	/// - Parameters:
	///   - hashmark: If true, includes a hashmark at the beginning
	///   - uppercase: If true, uses uppercase characters
	/// - Returns: hex string
	@inlinable func hexRGBA(hashmark: Bool, uppercase: Bool = false) throws -> String {
		try self.hexString(.rgba, hashmark: hashmark, uppercase: uppercase)
	}
}
