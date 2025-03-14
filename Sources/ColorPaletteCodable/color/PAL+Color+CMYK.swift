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

/// Create a color from CMYK components
/// - Parameters:
///   - cf: The cyan component (0.0 ... 1.0)
///   - mf: The magenta component (0.0 ... 1.0)
///   - yf: The yellow component (0.0 ... 1.0)
///   - kf: The black component (0.0 ... 1.0)
///   - af: The alpha component (0.0 ... 1.0)
///   - name: The name for the color
///   - colorType: The type of color
/// - Returns: A color
public func cmykf(
	_ cf: Float32,
	_ mf: Float32,
	_ yf: Float32,
	_ kf: Float32,
	_ af: Float32 = 1,
	name: String = "",
	colorType: PAL.ColorType = .global
) -> PAL.Color {
	PAL.Color(name: name, cf: cf, mf: mf, yf: yf, kf: kf, af: af, colorType: colorType)
}

// MARK: - Basic CMYK structure

public extension PAL.Color {
	/// CMYK color components
	struct CMYK: Equatable {
		/// Create CMYK color components
		/// - Parameters:
		///   - cf: Cyan component (0.0 ... 1.0)
		///   - mf: Magenta component (0.0 ... 1.0)
		///   - yf: Yellow component (0.0 ... 1.0)
		///   - kf: Key (black) component (0.0 ... 1.0)
		///   - af: Alpha component (0.0 ... 1.0)
		public init(cf: Float32, mf: Float32, yf: Float32, kf: Float32, af: Float32 = 1.0) {
			self.cf = cf.clamped(to: 0.0 ... 1.0)
			self.mf = mf.clamped(to: 0.0 ... 1.0)
			self.yf = yf.clamped(to: 0.0 ... 1.0)
			self.kf = kf.clamped(to: 0.0 ... 1.0)
			self.af = af.clamped(to: 0.0 ... 1.0)
		}

		public static func == (lhs: PAL.Color.CMYK, rhs: PAL.Color.CMYK) -> Bool {
			return
				abs(lhs.cf - rhs.cf) < 0.005 &&
				abs(lhs.mf - rhs.mf) < 0.005 &&
				abs(lhs.yf - rhs.yf) < 0.005 &&
				abs(lhs.kf - rhs.kf) < 0.005 &&
				abs(lhs.af - rhs.af) < 0.005
		}

		/// Cyan component (0.0 ... 1.0)
		public let cf: Float32
		/// Magenta component (0.0 ... 1.0)
		public let mf: Float32
		/// Yellow component (0.0 ... 1.0)
		public let yf: Float32
		/// Key (black) component (0.0 ... 1.0)
		public let kf: Float32
		/// Alpha component (0.0 ... 1.0)
		public let af: Float32
	}
}

// MARK: - Color CMYK support

public extension PAL.Color {
	/// Create a color object from cmyk component values
	/// - Parameters:
	///   - name: The color name
	///   - cf: Cyan component (0.0 ... 1.0)
	///   - mf: Magenta component (0.0 ... 1.0)
	///   - yf: Yellow component (0.0 ... 1.0)
	///   - kf: Black component (0.0 ... 1.0)
	///   - af: Alpha component (0.0 ... 1.0)
	///   - colorType: The type of color
	init(
		name: String = "",
		cf: Float32,
		mf: Float32,
		yf: Float32,
		kf: Float32,
		af: Float32 = 1.0,
		colorType: PAL.ColorType = .global
	) {
		self.name = name
		self.colorSpace = .CMYK
		self.colorComponents = [cf.unitClamped, mf.unitClamped, yf.unitClamped, kf.unitClamped]
		self.alpha = af.unitClamped
		self.colorType = colorType
	}

	/// Create a cmyk color
	/// - Parameters:
	///   - name: The color name
	///   - color: The color components
	///   - colorType: The type of color
	init(name: String = "", color: PAL.Color.CMYK, colorType: PAL.ColorType = .global) {
		self.init(name: name, cf: color.cf, mf: color.mf, yf: color.yf, kf: color.kf, af: color.af, colorType: colorType)
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
	@inlinable func cmyk() throws -> PAL.Color.CMYK {
		let c = try self.converted(to: .CMYK)
		return PAL.Color.CMYK(cf: c._c, mf: c._m, yf: c._y, kf: c._k, af: self.alpha)
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
