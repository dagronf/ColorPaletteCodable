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

	/// Create a color object from an rgb(a) hex string
	/// - Parameters:
	///   - name: The color name
	///   - rgbaHexString: The argb hex string
	///   - colorType: The color type
	///
	/// Supported hex formats :-
	/// - [#]FFF      : RGB color
	/// - [#]FFFF     : RGBA color (RRGGBB)
	/// - [#]FFFFFF   : RGB color
	/// - [#]FFFFFFFF : RGBA color (RRGGBBAA)
	init(name: String = "", rgbaHexString: String, colorType: PAL.ColorType = .normal) throws {
		let color = try PAL.Color.RGB(rgbaHexString: rgbaHexString)
		try self.init(
			name: name,
			colorSpace: .RGB,
			colorComponents: [color.r, color.g, color.b],
			colorType: colorType,
			alpha: color.a
		)
	}

	/// Create a color object from an [a]rgb hex string
	/// - Parameters:
	///   - name: The color name
	///   - argbHexString: The argb hex string
	///   - colorType: The color type
	///
	/// Supported hex formats :-
	/// - [#]FFF      : RGB color
	/// - [#]FFFF     : ARGB color (ARGB)
	/// - [#]FFFFFF   : RGB color
	/// - [#]FFFFFFFF : ARGB color (AARRGGBB)
	init(name: String = "", argbHexString: String, colorType: PAL.ColorType = .normal) throws {
		let color = try PAL.Color.RGB(argbHexString: argbHexString)
		try self.init(
			name: name,
			colorSpace: .RGB,
			colorComponents: [color.r, color.g, color.b],
			colorType: colorType,
			alpha: color.a
		)
	}

	/// Converts a raw UInt32 into an ARGB NSColor
	/// - Parameters:
	///   - name: The color name
	///   - colorValue: an color value
	init(name: String = "", _ colorValue: UInt32, colorByteFormat: PAL.ColorByteFormat) throws {
		let c0 = UInt8(truncatingIfNeeded: colorValue >> 24)
		let c1 = UInt8(truncatingIfNeeded: colorValue >> 16)
		let c2 = UInt8(truncatingIfNeeded: colorValue >> 8)
		let c3 = UInt8(truncatingIfNeeded: colorValue)
		switch colorByteFormat {
		case .argb:
			try self.init(name: name, r255: c1, g255: c2, b255: c3, a255: c0, colorType: .global)
		case .rgba:
			try self.init(name: name, r255: c0, g255: c1, b255: c2, a255: c3, colorType: .global)
		case .abgr:
			try self.init(name: name, r255: c3, g255: c2, b255: c1, a255: c0, colorType: .global)
		case .bgra:
			try self.init(name: name, r255: c2, g255: c1, b255: c0, a255: c3, colorType: .global)
		}
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
			return "rgba(\(rgba.r), \(rgba.g), \(rgba.b), \(rgba.a))"
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
	/// - Parameter colorByteFormat: The output format for the color
	/// - Returns: UInt32 representation for this RGB color
	func asRGBUInt32(colorByteFormat: PAL.ColorByteFormat) throws -> UInt32 {
		let rgba = try self.rgba255Components()
		let rgba32 = (r: UInt32(rgba.r), g: UInt32(rgba.g), b: UInt32(rgba.b), a: UInt32(rgba.a))
		switch colorByteFormat {
		case .argb:
			return (rgba32.a << 24) + (rgba32.r << 16) + (rgba32.g << 8) + rgba32.b
		case .rgba:
			return (rgba32.r << 24) + (rgba32.g << 16) + (rgba32.b << 8) + rgba32.a
		case .abgr:
			return (rgba32.a << 24) + (rgba32.b << 16) + (rgba32.g << 8) + rgba32.r
		case .bgra:
			return (rgba32.b << 24) + (rgba32.g << 16) + (rgba32.r << 8) + rgba32.a
		}
	}
}
