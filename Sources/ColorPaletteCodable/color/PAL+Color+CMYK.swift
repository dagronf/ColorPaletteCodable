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
	/// The components for a color with the CGColorSpace.CMYK colorspace
	struct CMYK: Equatable {
		public init(c: Float32, m: Float32, y: Float32, k: Float32, a: Float32 = 1.0) {
			self.c = c.clamped(to: 0.0 ... 1.0)
			self.m = m.clamped(to: 0.0 ... 1.0)
			self.y = y.clamped(to: 0.0 ... 1.0)
			self.k = k.clamped(to: 0.0 ... 1.0)
			self.a = a.clamped(to: 0.0 ... 1.0)
		}

		public static func == (lhs: PAL.Color.CMYK, rhs: PAL.Color.CMYK) -> Bool {
			return
				abs(lhs.c - rhs.c) < 0.005 &&
				abs(lhs.m - rhs.m) < 0.005 &&
				abs(lhs.y - rhs.y) < 0.005 &&
				abs(lhs.k - rhs.k) < 0.005 &&
				abs(lhs.a - rhs.a) < 0.005
		}

		public let c: Float32
		public let m: Float32
		public let y: Float32
		public let k: Float32
		public let a: Float32
	}
}

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
	) throws {
		try self.init(
			name: name,
			colorSpace: .CMYK,
			colorComponents: [
				cf.unitClamped,
				mf.unitClamped,
				yf.unitClamped,
				kf.unitClamped
			],
			colorType: colorType,
			alpha: af.unitClamped
		)
	}

	/// Create a color from CMYK components
	/// - Parameters:
	///   - name: The name for the color
	///   - c: The cyan component (0.0 ... 1.0)
	///   - m: The magenta component (0.0 ... 1.0)
	///   - y: The yellow component (0.0 ... 1.0)
	///   - k: The black component (0.0 ... 1.0)
	///   - alpha: The alpha component (0.0 ... 1.0)
	///   - colorType: The type of color
	/// - Returns: A color
	static func cmyk(
		name: String = "",
		_ c: Float32,
		_ m: Float32,
		_ y: Float32,
		_ k: Float32,
		_ alpha: Float32 = 1,
		colorType: PAL.ColorType = .global
	) -> PAL.Color {
		// We know that the color has the correct components here
		try! PAL.Color(name: name, cf: c, mf: m, yf: y, kf: k, af: alpha, colorType: colorType)
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
		return PAL.Color.CMYK(c: c._c, m: c._m, y: c._y, k: c._k, a: self.alpha)
	}

	/// Returns the cmyk values as a tuple for a color with colorspace CMYK
	///
	/// Throws `CommonError.mismatchedColorspace` if the colorspace is not CMYK
	@inlinable func cmykValues() throws -> PAL.Color.CMYK {
		if colorSpace != .CMYK { throw PAL.CommonError.mismatchedColorspace }
		return PAL.Color.CMYK(c: _c, m: _m, y: _y, k: _k, a: self.alpha)
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
