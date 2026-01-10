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

// MARK: - Y'CbCr Components

// https://en.wikipedia.org/wiki/Y'CbCr
// https://colorizer.org

public extension PAL.Color {
	/// Y'CbCr color components
	struct YCbCr: Equatable, Sendable {
		/// The luminance value (0.0 ... 255.0)
		public let y: Double
		/// The blue-difference value (0.0 ... 255.0)
		public let cb: Double
		/// The red-difference value (0.0 ... 255.0)
		public let cr: Double

		/// Create using Y'CbCr components
		/// - Parameters:
		///   - y: A value between 0 ... 255
		///   - cb: A value between 0 ... 255 (usually centered around 128)
		///   - cr: A value between 0 ... 255 (usually centered around 128)
		public init(y: Double, cb: Double, cr: Double) {
			assert(range0255__.contains(y))
			assert(range0255__.contains(cb))
			assert(range0255__.contains(cr))
			self.y = y
			self.cb = cb
			self.cr = cr
		}

		/// Create using RGB components (0.0 ... 1.0)
		/// - Parameters:
		///   - rf: The red component (between 0.0 ... 1.0)
		///   - gf: The green component (between 0.0 ... 1.0)
		///   - bf: The blue component (between 0.0 ... 1.0)
		public init(rf: Double, gf: Double, bf: Double) {
			let ycbcr = rgb2ycbcr(rf: rf, gf: gf, bf: bf)
			self.init(y: ycbcr.y, cb: ycbcr.cb, cr: ycbcr.cr)
		}

		/// Create using RGB components
		/// - Parameters:
		///   - r255: Red component (0 ... 255)
		///   - g255: Green component (0 ... 255)
		///   - b255: Blue component (0 ... 255)
		@inlinable
		public init(r255: UInt8, g255: UInt8, b255: UInt8) {
			self.init(rf: r255.unitValue, gf: g255.unitValue, bf: b255.unitValue)
		}

		public func isEqual(_ right: YCbCr, precision: UInt) -> Bool {
			return
				self.y.isEqual(to: right.y, precision: precision) &&
				self.cb.isEqual(to: right.cb, precision: precision) &&
				self.cr.isEqual(to: right.cr, precision: precision)
		}

		/// Return a Y'CbCr representation with all the values at a specific precision
		/// - Parameter value: The precision
		/// - Returns: A new Y~CbCr value
		public func precision(_ value: UInt) -> YCbCr {
			YCbCr(
				y: self.y.roundToPrecision(value),
				cb: self.cb.roundToPrecision(value),
				cr: self.cr.roundToPrecision(value)
			)
		}

		/// Return components in the range y: (0.0 ... 1.0), cb: (-0.5 ... 0.5), cr: (-0.5 ... 0.5)
		@inlinable
		public var fractional: (y: Double, cb: Double, cr: Double) {
			(self.y / 255.0, (self.cb / 255.0) - 0.5, (self.cr / 255.0) - 0.5)
		}
	}
}

// MARK: - Conversion

public extension PAL.Color.YCbCr {
	/// Return the RGB representation of a YCbCr color
	/// - Returns: An RGB color
	func rgb() -> PAL.Color.RGB {
		let rgb = ycbcr2rgb(y, cb, cr)
		return PAL.Color.RGB(rf: rgb.r, gf: rgb.g, bf: rgb.b)
	}
}

public extension PAL.Color {
	/// Get the Y'CbCr components for this color
	/// - Returns: A Y'CbCR color
	/// - Throws: If this color cannot be converted to RGB
	func YCbCr() throws -> PAL.Color.YCbCr {
		try self.rgb().YCbCr()
	}
}

public extension PAL.Color.RGB {
	/// Convert this RGB value to Y'CbCr value
	/// - Returns: A Y'CbCr value
	@inlinable func YCbCr() -> PAL.Color.YCbCr {
		PAL.Color.YCbCr(rf: self.rf, gf: self.gf, bf: self.bf)
	}
}

// MARK: - Raw conversion

private let range0255__ = 0.0 ... 255.0
private let range01__ = 0.0 ... 1.0

/// Convert an Y'CbCr value to an RGB value
/// - Parameters:
///   - y: The luma component, between 0.0 ... 255.0
///   - cb: Blue-difference component, between 0.0 ... 255.0
///   - cr: Red-difference component, between 0.0 ... 255.0
/// - Returns: An RGB triple, with each component a unit component (0.0 ... 1.0)
///
/// Uses ITU-R BT.601 conversion formula
///
/// Formula from https://www.w3.org/Graphics/JPEG/jfif3.pdf
private func ycbcr2rgb(_ y: Double, _ cb: Double, _ cr: Double) -> (r: Double, g: Double, b: Double) {

	assert(range0255__.contains(y))
	assert(range0255__.contains(cb))
	assert(range0255__.contains(cr))

	let cb = cb - 128.0
	let cr = cr - 128.0

	let r255 = y + (1.402 * cr)
	let g255 = y - (0.34414 * cb) - (0.71414 * cr)
	let b255 = y + (1.772 * cb)

	// Convert range from 0.0 ... 255.0 -> 0.0 ... 1.0
	let rf = r255 / 255.0
	let gf = g255 / 255.0
	let bf = b255 / 255.0
	return (rf.unitClamped, gf.unitClamped, bf.unitClamped)
}

/// Convert an RGB value to a Y'CbCr value
/// - Parameters:
///   - rf: The red component, between 0.0 ... 1.0
///   - gf: The green component, between 0.0 ... 1.0
///   - bf: The blue component, between 0.0 ... 1.0
/// - Returns: An YCbCr triple, with each component in the range (0.0 ... 255.0)
///
/// Uses ITU-R BT.601 conversion formula
///
/// Formula from https://www.w3.org/Graphics/JPEG/jfif3.pdf
private func rgb2ycbcr(rf: Double, gf: Double, bf: Double) -> (y: Double, cb: Double, cr: Double) {

	assert(range01__.contains(rf))
	assert(range01__.contains(gf))
	assert(range01__.contains(bf))

	let rf = rf * 255.0
	let gf = gf * 255.0
	let bf = bf * 255.0

	let y  = (rf *  0.2990) + (gf *  0.5870) + (bf *  0.1140)
	let cb = (rf * -0.1687) + (gf * -0.3313) + (bf *  0.5000) + 128.0
	let cr = (rf *  0.5000) + (gf * -0.4187) + (bf * -0.0813) + 128.0
	return (
		y.clamped(to: 0 ... 255),
		cb.clamped(to: 0 ... 255),
		cr.clamped(to: 0 ... 255),
	)
}
