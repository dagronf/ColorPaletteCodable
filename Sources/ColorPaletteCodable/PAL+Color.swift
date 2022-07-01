//
//  PAL+Color.swift
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

import Foundation

public extension PAL {
	/// A color in the palette
	struct Color: Equatable, CustomStringConvertible, Codable {
		/// The color name
		public let name: String
		/// The colorspace model for the color
		public let colorSpace: PAL.ColorSpace
		/// The components of the color
		public let colorComponents: [Float32]
		/// The type of color (global, spot, normal)
		public let colorType: ColorType

		/// The color's alpha component
		public let alpha: Float32

		/// Create a color object
		public init(name: String, colorSpace: PAL.ColorSpace, colorComponents: [Float32], colorType: ColorType = .global, alpha: Float32 = 1) throws {
			self.name = name
			self.colorSpace = colorSpace

			self.colorComponents = colorComponents
			self.colorType = colorType
			self.alpha = alpha

			// Validate that our color object is correctly formatted
			try self.checkValidity()
		}

		/// Return a string description of the color
		public var description: String {
			"Color '\(self.name)' [(\(self.colorSpace):\(self.colorType):\(self.colorComponents):\(self.alpha)]"
		}

		/// Returns true if the underlying color structure is valid for its colorspace and settings
		public var isValid: Bool {
			switch self.colorSpace {
			case .CMYK: if self.colorComponents.count == 4 { return true }
			case .RGB: if self.colorComponents.count == 3 { return true }
			case .LAB: if self.colorComponents.count == 3 { return true }
			case .Gray: if self.colorComponents.count == 1 { return true }
			}
			return false
		}

		/// Throws an error if the color is in an invalid state
		public func checkValidity() throws {
			if self.isValid == false {
				throw CommonError.invalidColorComponentCountForModelType
			}
		}
	}
}

public extension PAL.Color {
	/// Return a copy of this color with the specified alpha value
	func withAlpha(_ alphaValue: Float32) throws -> PAL.Color {
		return try PAL.Color(
			name: self.name,
			colorSpace: self.colorSpace,
			colorComponents: self.colorComponents,
			colorType: self.colorType,
			alpha: alphaValue
		)
	}
}

public extension PAL.Color {
	internal enum CodingKeys: String, CodingKey {
		case name
		case colorSpace
		case colorComponents
		case colorType
		case alpha
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		self.colorSpace = try container.decode(PAL.ColorSpace.self, forKey: .colorSpace)
		self.colorComponents = try container.decode([Float32].self, forKey: .colorComponents)
		self.colorType = try container.decodeIfPresent(PAL.ColorType.self, forKey: .colorType) ?? .global
		self.alpha = try container.decodeIfPresent(Float32.self, forKey: .alpha) ?? 1

		// Make sure our content is valid
		try self.checkValidity()
	}

	func encode(to encoder: Encoder) throws {
		// Make sure our content is valid
		try self.checkValidity()

		var container = encoder.container(keyedBy: CodingKeys.self)
		if !name.isEmpty { try container.encode(name, forKey: .name) }
		try container.encode(colorSpace, forKey: .colorSpace)
		try container.encode(colorComponents, forKey: .colorComponents)
		if colorType != .global { try container.encode(colorType, forKey: .colorType) }
		if alpha != 1 { try container.encode(alpha, forKey: .alpha) }
	}
}

// MARK: Colorspace converter

public extension PAL.Color {
	/// Convert the color object to a new color object with the specified colorspace
	/// - Parameter colorspace: The colorspace to convert to
	/// - Returns: A new color with the specified namespace
	func converted(to colorspace: PAL.ColorSpace) throws -> PAL.Color {
		return try PAL_ColorSpaceConverter.convert(color: self, to: colorspace)
	}
}

// MARK: Hex color initializers

public extension PAL.Color {
	/// Create a color object from a rgb hex string (eg. "12E5B4" or "#12E5B4")
	///
	/// Supported hex formats :-
	/// - [#]FFF      : RGB color
	/// - [#]FFFF     : RGBA color
	/// - [#]FFFFFF   : RGB color
	/// - [#]FFFFFFFF : RGBA color
	init(name: String = "", rgbHexString: String, colorType: PAL.ColorType = .normal) throws {
		guard let color = Self.fromHexString(rgbHexString) else {
			throw PAL.CommonError.invalidRGBHexString(rgbHexString)
		}
		try self.init(
			name: name,
			colorSpace: .RGB,
			colorComponents: [color.r, color.g, color.b],
			colorType: colorType,
			alpha: color.a)
	}
}

// MARK: Convert to hex

public extension PAL.Color {
	/// Return a hex RGB string (eg. "#523b50") for an RGB color
	///
	/// If the underlying colorspace is not RGB attempts conversion to RGB before failing
	var hexRGB: String? {
		guard let rgb = try? self.converted(to: .RGB) else {
			return nil
		}

		let r = rgb.colorComponents[0]
		let g = rgb.colorComponents[1]
		let b = rgb.colorComponents[2]

		let cr = UInt8(r * 255).clamped(to: 0 ... 255)
		let cg = UInt8(g * 255).clamped(to: 0 ... 255)
		let cb = UInt8(b * 255).clamped(to: 0 ... 255)

		return String(format: "#%02x%02x%02x", cr, cg, cb)
	}

	/// Return a hex RGBA string (eg. "#523b50FF")
	var hexRGBA: String? {
		guard let rgb = hexRGB else { return nil }
		return rgb + String(format: "%02x", Int(self.alpha * 255.0))
	}
}

// MARK: Hex color converters

private extension PAL.Color {
	static func fromHexString(_ hexString: String) -> (r: Float32, g: Float32, b: Float32, a: Float32)? {
		var string = hexString.lowercased()
		if hexString.hasPrefix("#") {
			string = String(string.dropFirst())
		}
		switch string.count {
		case 3:
			string += "f"
			fallthrough
		case 4:
			let chars = Array(string)
			let red = chars[0]
			let green = chars[1]
			let blue = chars[2]
			let alpha = chars[3]
			string = "\(red)\(red)\(green)\(green)\(blue)\(blue)\(alpha)\(alpha)"
		case 6:
			string += "ff"
		case 8:
			break
		default:
			return nil
		}

		guard let rgba = Double("0x" + string)
			.flatMap( {UInt32(exactly: $0) } )
		else {
			return nil
		}
		let red = Float32((rgba & 0xFF00_0000) >> 24) / 255
		let green = Float32((rgba & 0x00FF_0000) >> 16) / 255
		let blue = Float32((rgba & 0x0000_FF00) >> 8) / 255
		let alpha = Float32((rgba & 0x0000_00FF) >> 0) / 255

		return (red, green, blue, alpha)
	}
}

public extension PAL.Color {
	/// Create a color from RGB components
	/// - Parameters:
	///   - name: The name for the color
	///   - r: The red component (0.0 ... 1.0)
	///   - g: The green component (0.0 ... 1.0)
	///   - b: The blue component (0.0 ... 1.0)
	///   - a: The alpha component (0.0 ... 1.0)
	/// - Returns: A color
	static func rgb(name: String = "", _ r: Float32, _ g: Float32, _ b: Float32, _ a: Float32 = 1, colorType: PAL.ColorType = .global) -> PAL.Color {
		// We know that the color has the correct components here
		try! PAL.Color(name: name, colorSpace: .RGB, colorComponents: [r, g, b], colorType: colorType, alpha: a)
	}

	/// Create a color from CMYK components
	/// - Parameters:
	///   - name: The name for the color
	///   - c: The cyan component (0.0 ... 1.0)
	///   - m: The magenta component (0.0 ... 1.0)
	///   - y: The yellow component (0.0 ... 1.0)
	///   - k: The black component (0.0 ... 1.0)
	///   - a: The alpha component (0.0 ... 1.0)
	/// - Returns: A color
	static func cmyk(name: String = "", _ c: Float32, _ m: Float32, _ y: Float32, _ k: Float32, _ a: Float32 = 1, colorType: PAL.ColorType = .global) -> PAL.Color {
		// We know that the color has the correct components here
		try! PAL.Color(name: name, colorSpace: .CMYK, colorComponents: [c, m, y, k], colorType: colorType, alpha: a)
	}

	/// Create a color from a gray component
	/// - Parameters:
	///   - name: The name for the color
	///   - white: The blackness component (0.0 ... 1.0)
	///   - alpha: The alpha component (0.0 ... 1.0)
	/// - Returns: A color
	static func gray(name: String = "", white: Float32, alpha: Float32 = 1, colorType: PAL.ColorType = .global) -> PAL.Color {
		// We know that the color has the correct components here
		try! PAL.Color(name: name, colorSpace: .Gray, colorComponents: [white], colorType: colorType, alpha: alpha)
	}
}

// MARK: RGB compoments

// Unsafe RGB retrieval. No checks or validation are performed. Do not use unless you are absolutely sure.
internal extension PAL.Color {
	@inlinable var _r: Float32 { colorComponents[0] }
	@inlinable var _g: Float32 { colorComponents[1] }
	@inlinable var _b: Float32 { colorComponents[2] }
}

public extension PAL.Color {
	/// Returns the rgb values as a tuple for a color with colorspace RGB.
	///
	/// Throws `CommonError.mismatchedColorspace` if the colorspace is not RGB
	@inlinable func rgbValues() throws -> (r: Float32, g: Float32, b: Float32) {
		if colorSpace == .RGB { return (r: _r, g: _g, b: _b) }
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

// MARK: CMYK compoments

// Unsafe CMYK retrieval. No checks or validation are performed. Do not use unless you are absolutely sure.
internal extension PAL.Color {
	@inlinable var _c: Float32 { colorComponents[0] }
	@inlinable var _m: Float32 { colorComponents[1] }
	@inlinable var _y: Float32 { colorComponents[2] }
	@inlinable var _k: Float32 { colorComponents[3] }
}

public extension PAL.Color {
	/// Returns the cmyk values as a tuple for a color with colorspace CMYK
	///
	/// Throws `CommonError.mismatchedColorspace` if the colorspace is not CMYK
	@inlinable func cmykValues() throws -> (c: Float32, m: Float32, y: Float32, k: Float32) {
		if colorSpace != .CMYK { throw PAL.CommonError.mismatchedColorspace }
		return (c: _c, m: _m, y: _y, k: _k)
	}

	/// The color's cyan component IF the colorspace is `.CMYK`
	///
	/// Throws `PAL.CommonError.mismatchedColorspace` if the colorspace isn't `.CMYK`
	@inlinable func c() throws -> Float32 {
		if colorSpace == .CMYK { return _c }
		throw PAL.CommonError.mismatchedColorspace
	}

	/// The color's magenta component IF the colorspace is `.CMYK`
	///
	/// Throws `PAL.CommonError.mismatchedColorspace` if the colorspace isn't `.CMYK`
	@inlinable func m() throws -> Float32 {
		if colorSpace == .CMYK { return _m }
		throw PAL.CommonError.mismatchedColorspace
	}

	/// The color's yellow component IF the colorspace is `.CMYK`
	///
	/// Throws `PAL.CommonError.mismatchedColorspace` if the colorspace isn't `.CMYK`
	@inlinable func y() throws -> Float32 {
		if colorSpace == .CMYK { return _y }
		throw PAL.CommonError.mismatchedColorspace
	}

	/// The color's black component IF the colorspace is `.CMYK`
	///
	/// Throws `PAL.CommonError.mismatchedColorspace` if the colorspace isn't `.CMYK`
	@inlinable func k() throws -> Float32 {
		if colorSpace == .CMYK { return _k }
		throw PAL.CommonError.mismatchedColorspace
	}
}

// MARK: Gray compoments

// Unsafe Gray retrieval. No checks or validation are performed
internal extension PAL.Color {
	@inlinable var _l: Float32 { colorComponents[0] }
}

public extension PAL.Color {
	/// The color's luminance component IF the colorspace is .Gray
	///
	/// Throws `PAL.CommonError.mismatchedColorspace` if the colorspace isn't `.Gray`
	@inlinable func luminance() throws -> Float32 {
		if colorSpace == .Gray { return _l }
		throw PAL.CommonError.mismatchedColorspace
	}
}
