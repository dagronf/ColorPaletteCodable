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

// MARK: - Global creators

/// Create a color from RGB components
/// - Parameters:
///   - rf: The red component (0.0 ... 1.0)
///   - gf: The green component (0.0 ... 1.0)
///   - bf: The blue component (0.0 ... 1.0)
///   - af: The alpha component (0.0 ... 1.0)
///   - name: The name for the color
///   - colorType: The type of color
/// - Returns: A color
public func rgbf(
	_ rf: Double,
	_ gf: Double,
	_ bf: Double,
	_ af: Double = 1,
	name: String = "",
	colorType: PAL.ColorType = .global
) -> PAL.Color {
	PAL.Color(rf: rf, gf: gf, bf: bf, af: af, name: name, colorType: colorType)
}

/// Create a color from RGB components
/// - Parameters:
///   - r255: The red component (0 ... 255)
///   - g255: The green component (0 ... 255)
///   - b255: The blue component (0 ... 255)
///   - a255: The alpha component (0 ... 255)
///   - name: The name for the color
///   - colorType: The type of color
/// - Returns: A color
public func rgb255(
	_ r255: UInt8,
	_ g255: UInt8,
	_ b255: UInt8,
	_ a255: UInt8 = 255,
	name: String = "",
	colorType: PAL.ColorType = .normal
) -> PAL.Color {
	PAL.Color(r255: r255, g255: g255, b255: b255, a255: a255, name: name, colorType: colorType)
}

/// Create a color from an RGB[A] hex color format string
/// - Parameters:
///   - rgbHexString: The hex-encoded color string
///   - format: The expected format for the incoming hex string (eg. `.rgb`, `.bgr`)
///   - name: The color name
///   - colorType: The color type
/// - Returns: A color representing the hex string
public func rgb(
	_ rgbHexString: String,
	format: PAL.ColorByteFormat,
	name: String = "",
	colorType: PAL.ColorType = .normal
) throws -> PAL.Color {
	try PAL.Color(rgbHexString: rgbHexString, format: format, name: name, colorType: colorType)
}

// MARK: - Basic RGB structure

public extension PAL.Color {
	/// RGBA color components
	struct RGB {
		/// Create using rgba in the 0.0 ... 1.0 range
		/// - Parameters:
		///   - rf: Red component
		///   - gf: Green component
		///   - bf: Blue component
		///   - af: Alpha component
		public init(rf: Double, gf: Double, bf: Double, af: Double = 1.0) {
			self.rf = rf.unitClamped
			self.gf = gf.unitClamped
			self.bf = bf.unitClamped
			self.af = af.unitClamped
		}

		/// Create using rgba in the 0 ... 255 range
		/// - Parameters:
		///   - r255: Red component
		///   - g255: Green component
		///   - b255: Blue component
		///   - a255: Alpha component
		public init(r255: UInt8, g255: UInt8, b255: UInt8, a255: UInt8 = 255) {
			self.rf = (Double(r255) / 255).unitClamped
			self.gf = (Double(g255) / 255).unitClamped
			self.bf = (Double(b255) / 255).unitClamped
			self.af = (Double(a255) / 255).unitClamped
		}

		/// Create and RGB[A] color from a hex formatted color string
		///  - Parameters:
		///   - hexString: The rgba hex string
		///   - format: The expected rgba format
		///
		/// Supported hex formats :-
		/// - [#]FFF      : RGB color  (RGB)
		/// - [#]FFFF     : RGBA color (RGBA)
		/// - [#]FFFFFF   : RGB color  (RRGGBB)
		/// - [#]FFFFFFFF : RGBA color (RRGGBBAA)
		///
		/// Returns black color if the hex string is invalid
		public init(_ hexString: String, format: PAL.ColorByteFormat) throws {
			guard let c = extractHexRGBA(hexString: hexString, format: format) else {
				throw PAL.CommonError.invalidRGBHexString(hexString)
			}
			self = c
		}

		/// Return a hex string representation of this rgb color
		/// - Parameters:
		///   - format: The output format
		///   - hashmark: If true, includes a hashnark (`#`) at the beginning*
		///   - uppercase: If true, uppercases the output string
		/// - Returns: A string
		public func hexString(format: PAL.ColorByteFormat, hashmark: Bool, uppercase: Bool) -> String {
			hexRGBString(
				rf: self.rf,
				gf: self.gf,
				bf: self.bf,
				af: self.af,
				format: format,
				hashmark: hashmark,
				uppercase: uppercase
			)
		}

		/// Red component (0.0 ... 1.0)
		public let rf: Double
		/// Red component (0 ... 255)
		@inlinable public var r255: UInt8 { UInt8((self.rf * 255.0).rounded(.toNearestOrAwayFromZero)) }
		/// Green component (0.0 ... 1.0)
		public let gf: Double
		/// Green component (0 ... 255)
		@inlinable public var g255: UInt8 { UInt8((self.gf * 255.0).rounded(.toNearestOrAwayFromZero)) }
		/// Blue component (0.0 ... 1.0)
		public let bf: Double
		/// Blue component (0 ... 255)
		@inlinable public var b255: UInt8 { UInt8((self.bf * 255.0).rounded(.toNearestOrAwayFromZero)) }
		/// Alpha component (0.0 ... 1.0)
		public let af: Double
		/// Alpha component (0 ... 255)
		@inlinable public var a255: UInt8 { UInt8((self.af * 255.0).rounded(.toNearestOrAwayFromZero)) }
		
		/// RGB color components
		@inlinable public var components: [Double] { [self.rf, self.gf, self.bf] }
		/// RGB color components
		@inlinable public var components255: [UInt8] { [self.r255, self.g255, self.b255] }
	}
}

extension PAL.Color.RGB: Equatable {
	public static func == (lhs: PAL.Color.RGB, rhs: PAL.Color.RGB) -> Bool {
		return
			abs(lhs.rf - rhs.rf) < 0.005 &&
			abs(lhs.gf - rhs.gf) < 0.005 &&
			abs(lhs.bf - rhs.bf) < 0.005 &&
			abs(lhs.af - rhs.af) < 0.005
	}
}

public extension PAL.Color.RGB {
	/// Convert LAB color to RGB
	func lab() -> PAL.Color.LAB {
		NaiveConversions.RGB2LAB(self)
	}
}

// MARK: - Color RGB support

public extension PAL.Color {
	/// Create a color object from 0 ... 1 component values
	/// - Parameters:
	///   - rf: Red component (clamped to 0 ... 1)
	///   - gf: Green component (clamped to 0 ... 1)
	///   - bf: Blue component (clamped to 0 ... 1)
	///   - af: Alpha component (clamped to 0 ... 1)
	///   - name: The color name
	///   - colorType: The type of color
	init(
		rf: Double,
		gf: Double,
		bf: Double,
		af: Double = 1.0,
		name: String = "",
		colorType: PAL.ColorType = .global
	) {
		self.name = name
		self.colorSpace = .RGB
		self.colorComponents = [rf.unitClamped, gf.unitClamped, bf.unitClamped]
		self.alpha = af.unitClamped
		self.colorType = colorType
	}

	/// Create a color object from 0 -> 255 component values
	/// - Parameters:
	///   - r255: Red component (0 ... 255)
	///   - g255: Green component (0 ... 255)
	///   - b255: Blue component (0 ... 255)
	///   - a255: Alpha component (0 ... 255)
	///   - name: The color name
	///   - colorType: The type of color
	init(
		r255: UInt8,
		g255: UInt8,
		b255: UInt8,
		a255: UInt8 = 255,
		name: String = "",
		colorType: PAL.ColorType = .global
	) {
		let rf = (Double(r255) / 255.0).unitClamped
		let gf = (Double(g255) / 255.0).unitClamped
		let bf = (Double(b255) / 255.0).unitClamped
		let af = (Double(a255) / 255.0).unitClamped

		self.name = name
		self.colorSpace = .RGB
		self.colorComponents = [rf, gf, bf]
		self.alpha = af
		self.colorType = colorType
	}

	/// Create a color using an RGB color object
	/// - Parameters:
	///   - name: The color name
	///   - color: The color components
	///   - colorType: The type of color
	init(color: PAL.Color.RGB, name: String = "", colorType: PAL.ColorType = .global) {
		self.init(rf: color.rf, gf: color.gf, bf: color.bf, af: color.af, name: name, colorType: colorType)
	}

	/// Create an RGB(A) color object from a hex string
	/// - Parameters:
	///   - name: The color name
	///   - hexString: The hex color representation
	///   - format: The expected hex color format
	///   - colorType: The color type
	///
	/// Supported hex formats :-
	/// - [#]ABC      : RGB color
	/// - [#]ABCD     : RGBA color (RRGGBB)
	/// - [#]AABBCC   : RGB color
	/// - [#]AABBCCDD : RGBA color (RRGGBBAA)
	init(rgbHexString: String, format: PAL.ColorByteFormat, name: String = "", colorType: PAL.ColorType = .normal) throws {
		let color = try PAL.Color.RGB(rgbHexString, format: format)
		try self.init(
			colorSpace: .RGB,
			colorComponents: [color.rf, color.gf, color.bf],
			alpha: color.af,
			name: name,
			colorType: colorType
		)
	}
}

/// A formatter for generating an alpha value for css export
///
/// Note that CSS always expects a '.' as the decimal separator
private let alphaFormatter__ = NumberFormatter {
	$0.minimumFractionDigits = 1
	$0.maximumFractionDigits = 4
	$0.decimalSeparator = "."
}

extension PAL.Color {
	/// Return a CSS rgba definition for this color
	/// - Parameter includeAlpha: If true includes an alpha value
	/// - Returns: A string containing the CSS representation
	public func css(includeAlpha: Bool = true) throws -> String {
		let rgba = try self.rgb()
		if includeAlpha {
			let atext = alphaFormatter__.string(for: rgba.af) ?? "1.0"
			return "rgba(\(rgba.r255), \(rgba.g255), \(rgba.b255), \(atext))"
		}
		else {
			return "rgb(\(rgba.r255), \(rgba.g255), \(rgba.b255))"
		}
	}
}

// MARK: RGB compoments

// Unsafe RGB retrieval. No checks or validation are performed. Do not use unless you are absolutely sure
// that this color is rgb colorspaced
internal extension PAL.Color {
	@inlinable @inline(__always) var _r: Double {
		assert(self.colorSpace == .RGB && self.colorComponents.count == 3)
		return self.colorComponents[0]
	}
	@inlinable @inline(__always) var _g: Double {
		assert(self.colorSpace == .RGB && self.colorComponents.count == 3)
		return self.colorComponents[1]
	}
	@inlinable @inline(__always) var _b: Double {
		assert(self.colorSpace == .RGB && self.colorComponents.count == 3)
		return self.colorComponents[2]
	}
}

public extension PAL.Color {
	/// Returns the RGB components for this color
	/// - Returns: RGB components
	func rgb() throws -> PAL.Color.RGB {
		let c = try self.converted(to: .RGB)
		return PAL.Color.RGB(rf: c._r, gf: c._g, bf: c._b, af: c.alpha)
	}
}

// MARK: - 32-bit Integer Conversion

public extension PAL.Color {
	/// Create a UInt32 representation of this color
	/// - Parameter format: The output format for the color
	/// - Returns: UInt32 representation for this RGB color
	func asUInt32(format: PAL.ColorByteFormat) throws -> UInt32 {
		let rgba = try self.rgb()
		return convertToUInt32(r255: rgba.r255, g255: rgba.g255, b255: rgba.b255, a255: rgba.a255, colorByteFormat: format)
	}
}

public extension PAL.Color.RGB {
	/// Get the 32-bit UInt32 representation of this RGB(A) value
	/// - Parameter format: The rgb format
	/// - Returns: A UInt32 representation of the image
	func uint32Value(_ format: PAL.ColorByteFormat) -> UInt32 {
		switch format {
		case .abgr:
			return .fromBytes(self.a255, self.b255, self.g255, self.r255)
		case .argb:
			return .fromBytes(self.a255, self.r255, self.g255, self.b255)
		case .bgra:
			return .fromBytes(self.b255, self.g255, self.r255, self.a255)
		case .bgr:
			return .fromBytes(0, self.b255, self.g255, self.r255)
		case .rgba:
			return .fromBytes(self.r255, self.g255, self.b255, self.a255)
		case .rgb:
			return .fromBytes(0, self.r255, self.g255, self.b255)
		}
	}

	/// Get the 32-bit Int32 representation of this RGB(A) value
	/// - Parameter format: The rgb format
	/// - Returns: A UInt32 representation of the image
	@inlinable func int32Value(_ format: PAL.ColorByteFormat) -> Int32 {
		Int32(bitPattern: self.uint32Value(format))  // map to int32
	}

	/// Create an RGB value from a raw UInt32 value
	/// - Parameters:
	///   - value: The unsigned integer value
	///   - format: The rgb format
	init(value: UInt32, format: PAL.ColorByteFormat) {

		// value byte components
		let c = value.byteComponents()

		let r: UInt8
		let g: UInt8
		let b: UInt8
		let a: UInt8

		switch format {
		case .rgb:
			r = c.1; g = c.2; b = c.3; a = 255
		case .bgr:
			b = c.1; g = c.2; r = c.3; a = 255
		case .argb:
			a = c.0; r = c.1; g = c.2; b = c.3
		case .rgba:
			r = c.0; g = c.1; b = c.2; a = c.3
		case .abgr:
			a = c.0; b = c.1; g = c.2; r = c.3
		case .bgra:
			b = c.0; g = c.1; r = c.2; a = c.3
		}
		self.init(r255: r, g255: g, b255: b, a255: a)
	}

	/// Create an RGB value from a raw Int32 value
	/// - Parameters:
	///   - value: The integer value
	///   - format: The rgb format
	@inlinable init(value: Int32, format: PAL.ColorByteFormat) {
		self.init(value: UInt32(bitPattern: value), format: format)
	}
}
