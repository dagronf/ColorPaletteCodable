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
	/// The components for a color with a CGColorSpace.RGB colorspace
	struct RGB: Equatable {
		public init(r: Float32, g: Float32, b: Float32, a: Float32 = 1.0) {
			self.r = r.clamped(to: 0.0 ... 1.0)
			self.g = g.clamped(to: 0.0 ... 1.0)
			self.b = b.clamped(to: 0.0 ... 1.0)
			self.a = a.clamped(to: 0.0 ... 1.0)
		}

		/// Create using rgba in the 0 ... 255 range
		/// - Parameters:
		///   - r255: Red component
		///   - g255: Green component
		///   - b255: Blue component
		///   - a255: Alpha component
		public init(r255: UInt8, g255: UInt8, b255: UInt8, a255: UInt8 = 255) {
			self.r = (Float32(r255) / 255).clamped(to: 0.0 ... 1.0)
			self.g = (Float32(g255) / 255).clamped(to: 0.0 ... 1.0)
			self.b = (Float32(b255) / 255).clamped(to: 0.0 ... 1.0)
			self.a = (Float32(a255) / 255).clamped(to: 0.0 ... 1.0)
		}

		/// Create from a hex formatted color string
		///  - Parameters:
		///   - hexString: The rgba hex string
		///   - hexRGBFormat: The expected rgba format
		///
		/// Supported hex formats :-
		/// - [#]FFF      : RGB color  (RGB)
		/// - [#]FFFF     : RGBA color (RGBA)
		/// - [#]FFFFFF   : RGB color  (RRGGBB)
		/// - [#]FFFFFFFF : RGBA color (RRGGBBAA)
		///
		/// Returns black color if the hex string is invalid
		public init(hexString: String, hexRGBFormat: PAL.ColorByteFormat) throws {
			guard let c = extractHexRGBA(hexString: hexString, hexRGBFormat: hexRGBFormat) else {
				throw PAL.CommonError.invalidRGBHexString(hexString)
			}
			self.r = Float32(c.r) / 255.0
			self.g = Float32(c.g) / 255.0
			self.b = Float32(c.b) / 255.0
			self.a = Float32(c.a) / 255.0
		}

		/// Create from a hex RGBA formatted color string
		///  - Parameters:
		///   - rgbaHexString: The rgba hex string
		///
		/// Supported hex formats :-
		/// - [#]FFF      : RGB color  (RGB)
		/// - [#]FFFF     : RGBA color (RGBA)
		/// - [#]FFFFFF   : RGB color  (RRGGBB)
		/// - [#]FFFFFFFF : RGBA color (RRGGBBAA)
		///
		/// Returns black color if the hex string is invalid
		public init(rgbaHexString: String) throws {
			try self.init(hexString: rgbaHexString, hexRGBFormat: .rgba)
		}

		public static func == (lhs: PAL.Color.RGB, rhs: PAL.Color.RGB) -> Bool {
			return
				abs(lhs.r - rhs.r) < 0.005 &&
				abs(lhs.g - rhs.g) < 0.005 &&
				abs(lhs.b - rhs.b) < 0.005 &&
				abs(lhs.a - rhs.a) < 0.005
		}

		public let r: Float32
		public let g: Float32
		public let b: Float32
		public let a: Float32
	}
}

// MARK: - Conversions and helpers

public extension PAL.Color {
	/// Create a color object from 0 -> 255 component values
	/// - Parameters:
	///   - name: The color name
	///   - r255: Red component (0 ... 255)
	///   - g255: Green component (0 ... 255)
	///   - b255: Blue component (0 ... 255)
	///   - a255: Alpha component (0 ... 255)
	///   - colorType: The type of color
	init(
		name: String = "",
		r255: UInt8,
		g255: UInt8,
		b255: UInt8,
		a255: UInt8 = 255,
		colorType: PAL.ColorType = .global
	) throws {
		try self.init(
			name: name,
			colorSpace: .RGB,
			colorComponents: [
				Float32(r255.clamped(to: 0 ... 255)) / 255.0,
				Float32(g255.clamped(to: 0 ... 255)) / 255.0,
				Float32(b255.clamped(to: 0 ... 255)) / 255.0
			],
			colorType: colorType,
			alpha: Float32(a255.clamped(to: 0 ... 255)) / 255.0
		)
	}

	/// Create a color object from 0 ... 1 component values
	/// - Parameters:
	///   - name: The color name
	///   - rf: Red component (0 ... 1)
	///   - gf: Green component (0 ... 1)
	///   - bf: Blue component (0 ... 1)
	///   - af: Alpha component (0 ... 1)
	///   - colorType: The type of color
	init(
		name: String = "",
		rf: Float32,
		gf: Float32,
		bf: Float32,
		af: Float32 = 1.0,
		colorType: PAL.ColorType = .global
	) throws {
		try self.init(
			name: name,
			colorSpace: .RGB,
			colorComponents: [
				rf.clamped(to: 0.0 ... 1.0),
				gf.clamped(to: 0.0 ... 1.0),
				bf.clamped(to: 0.0 ... 1.0)
			],
			colorType: colorType,
			alpha: af.clamped(to: 0.0 ... 1.0)
		)
	}

	/// Create a color using an RGB color object
	/// - Parameters:
	///   - name: The color name
	///   - color: The color components
	///   - colorType: The type of color
	init(name: String = "", color: PAL.Color.RGB, colorType: PAL.ColorType = .global) throws {
		try self.init(name: name, rf: color.r, gf: color.g, bf: color.b, af: color.a, colorType: colorType)
	}

	/// Create a color object from a hex string
	/// - Parameters:
	///   - name: The color name
	///   - hexString: The hex color representation
	///   - hexRGBFormat: The expected hex color format
	///   - colorType: The color type
	///
	/// Supported hex formats :-
	/// - [#]FFF      : RGB color
	/// - [#]FFFF     : RGBA color (RRGGBB)
	/// - [#]FFFFFF   : RGB color
	/// - [#]FFFFFFFF : RGBA color (RRGGBBAA)
	init(name: String = "", hexString: String, hexRGBFormat: PAL.ColorByteFormat, colorType: PAL.ColorType = .normal) throws {
		let color = try PAL.Color.RGB(hexString: hexString, hexRGBFormat: hexRGBFormat)
		try self.init(
			name: name,
			colorSpace: .RGB,
			colorComponents: [color.r, color.g, color.b],
			colorType: colorType,
			alpha: color.a
		)
	}

	/// Create a color object from an rgb[a] hex string
	/// - Parameters:
	///   - name: The color name
	///   - rgbaHexString: The rgba hex string
	///   - colorType: The color type
	///
	/// Supported hex formats :-
	/// - [#]FFF      : RGB color  (RGB)
	/// - [#]FFFF     : RGBA color (RGBA)
	/// - [#]FFFFFF   : RGB color  (RRGGBB)
	/// - [#]FFFFFFFF : RGBA color (RRGGBBAA)
	@inlinable init(name: String = "", rgbaHexString: String, colorType: PAL.ColorType = .normal) throws {
		try self.init(name: name, hexString: rgbaHexString, hexRGBFormat: .rgba, colorType: colorType)
	}

	/// Create a color object from an [a]rgb hex string
	/// - Parameters:
	///   - name: The color name
	///   - argbHexString: The argb hex string
	///   - colorType: The color type
	///
	/// Supported hex formats :-
	/// - [#]FFF      : RGB color  (RGB)
	/// - [#]FFFF     : ARGB color (ARGB)
	/// - [#]FFFFFF   : RGB color  (RRGGBB)
	/// - [#]FFFFFFFF : ARGB color (AARRGGBB)
	@inlinable init(name: String = "", argbHexString: String, colorType: PAL.ColorType = .normal) throws {
		try self.init(name: name, hexString: argbHexString, hexRGBFormat: .argb, colorType: colorType)
	}

	/// Converts a raw UInt32 into an RGBA NSColor
	/// - Parameters:
	///   - name: The color name
	///   - uint32ColorValue: a 32-bit (4 byte) color value
	///   - colorByteFormat: The byte ordering when decoding the color value
	init(name: String = "", _ uint32ColorValue: UInt32, colorByteFormat: PAL.ColorByteFormat) throws {
		let c = extractRGBA(uint32ColorValue, colorByteFormat: colorByteFormat)
		try self.init(name: name, r255: c.r, g255: c.g, b255: c.b, a255: c.a, colorType: .global)
	}
}

public extension PAL.Color {
	/// Create a color from RGB components
	/// - Parameters:
	///   - name: The name for the color
	///   - r: The red component (0.0 ... 1.0)
	///   - g: The green component (0.0 ... 1.0)
	///   - b: The blue component (0.0 ... 1.0)
	///   - alpha: The alpha component (0.0 ... 1.0)
	///   - colorType: The type of color
	/// - Returns: A color
	static func rgb(
		name: String = "",
		_ r: Float32,
		_ g: Float32,
		_ b: Float32,
		_ alpha: Float32 = 1,
		colorType: PAL.ColorType = .global
	) -> PAL.Color {
		// We know that the color has the correct components here
		return try! PAL.Color(
			name: name,
			colorSpace: .RGB,
			colorComponents: [r.unitClamped, g.unitClamped, b.unitClamped],
			colorType: colorType,
			alpha: alpha.unitClamped
		)
	}

	/// Create a color from RGB components
	/// - Parameters:
	///   - name: The name for the color
	///   - r: The red component (0 ... 255)
	///   - g: The green component (0 ... 255)
	///   - b: The blue component (0 ... 255)
	///   - alpha: The alpha component (0 ... 255)
	///   - colorType: The type of color
	/// - Returns: A color
	static func rgb255(
		name: String = "",
		_ r: UInt8,
		_ g: UInt8,
		_ b: UInt8,
		_ alpha: UInt8 = 255,
		colorType: PAL.ColorType = .global
	) -> PAL.Color {
		// We know that the color has the correct components here
		return try! PAL.Color(
			name: name,
			colorSpace: .RGB,
			colorComponents: [
				(Float32(r) / 255.0).unitClamped,
				(Float32(g) / 255.0).unitClamped,
				(Float32(b) / 255.0).unitClamped
			],
			colorType: colorType,
			alpha: (Float32(alpha) / 255.0).unitClamped
		)
	}
}

extension PAL.Color {
	/// Return a CSS rgba definition for this color
	/// - Returns: A string containing the CSS representation
	public func css(includeAlpha: Bool = true) throws -> String {
		let rgba = try self.rgba255Components()
		if includeAlpha {
			return "rgba(\(rgba.r), \(rgba.g), \(rgba.b), \(Double(rgba.a) / 255.0))"
		}
		else {
			return "rgb(\(rgba.r), \(rgba.g), \(rgba.b))"
		}
	}
}

// MARK: RGB compoments

// Unsafe RGB retrieval. No checks or validation are performed. Do not use unless you are absolutely sure
// that this color is rgb colorspaced
internal extension PAL.Color {
	@inlinable @inline(__always) var _r: Float32 {
		assert(self.colorSpace == .RGB && self.colorComponents.count == 3)
		return self.colorComponents[0]
	}
	@inlinable @inline(__always) var _g: Float32 {
		assert(self.colorSpace == .RGB && self.colorComponents.count == 3)
		return self.colorComponents[1]
	}
	@inlinable @inline(__always) var _b: Float32 {
		assert(self.colorSpace == .RGB && self.colorComponents.count == 3)
		return self.colorComponents[2]
	}
}

public extension PAL.Color {
	/// Returns the RGB components for this color
	/// - Returns: RGB components
	func rgb() throws -> PAL.Color.RGB {
		let c = try self.converted(to: .RGB)
		return PAL.Color.RGB(r: c._r, g: c._g, b: c._b, a: c.alpha)
	}

	/// Returns the rgb values as a tuple for a color with colorspace RGB.
	///
	/// Throws `CommonError.mismatchedColorspace` if the colorspace is not RGB
	@inlinable func rgbValues() throws -> PAL.Color.RGB {
		if colorSpace == .RGB { return PAL.Color.RGB(r: _r, g: _g, b: _b, a: self.alpha) }
		throw PAL.CommonError.mismatchedColorspace
	}

	/// The color's red component IF the colorspace is `.RGB`
	///
	/// Throws `PAL.CommonError.mismatchedColorspace` if the colorspace isn't `.RGB`
	@inlinable func r() throws -> Float32 {
		if colorSpace == .RGB { return _r }
		throw PAL.CommonError.mismatchedColorspace
	}

	/// The color's green component IF the colorspace is `.RGB`
	///
	/// Throws `PAL.CommonError.mismatchedColorspace` if the colorspace isn't `.RGB`
	@inlinable func g() throws -> Float32 {
		if colorSpace == .RGB { return _g }
		throw PAL.CommonError.mismatchedColorspace
	}

	/// The color's blue component IF the colorspace is `.RGB`
	///
	/// Throws `PAL.CommonError.mismatchedColorspace` if the colorspace isn't `.RGB`
	@inlinable func b() throws -> Float32 {
		if colorSpace == .RGB { return _b }
		throw PAL.CommonError.mismatchedColorspace
	}
}


public extension PAL.Color {
	/// Create a UInt32 representation of this color
	/// - Parameter format: The output format for the color
	/// - Returns: UInt32 representation for this RGB color
	func asUInt32(format: PAL.ColorByteFormat) throws -> UInt32 {
		let rgba = try self.rgba255Components()
		return convertToUInt32(r255: rgba.r, g255: rgba.g, b255: rgba.b, a255: rgba.a, colorByteFormat: format)
	}
}
