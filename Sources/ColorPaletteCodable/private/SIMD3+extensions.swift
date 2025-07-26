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

#if canImport(Darwin)

extension SIMD3 where Scalar: BinaryFloatingPoint {
	/// Return a vector whose values are clamped between 0 and 1
	@inlinable var unitClamped: Self {
		self.clamped(lowerBound: SIMD3(0.0, 0.0, 0.0), upperBound: SIMD3(1.0, 1.0, 1.0))
	}
}

#endif

/// Linear interpolate between two SIMD instances
/// - Parameters:
///   - v0: First vector
///   - v1: Second vector
///   - t: The fractional distance between the two values
/// - Returns: Interpolated value
func lerp<T: FloatingPoint>(_ v0: SIMD3<T>, _ v1: SIMD3<T>, t: T) -> SIMD3<T> {
	v0 + (t * (v1 - v0))
}

// MARK: - PAL.Color Conveniences

internal extension PAL.Color {
	/// Create an RGB color from the content of a SIMD3
	/// - Parameters:
	///   - sRGB: The components values
	///   - name: The color name
	init(sRGB: SIMD3<Double>, name: String = "") {
		self.init(rf: sRGB.x, gf: sRGB.y, bf: sRGB.z, name: name)
	}

	/// Return an SIMD3 representation of this color. Throws an error if the color is not RGB colorspace
	/// - Returns: SIMD3 representation
	func rgbValuesSIMD3() throws -> SIMD3<Double> {
		let rgb = try self.rgb()
		return SIMD3(rgb.rf, rgb.gf, rgb.bf)
	}
}

// MARK: - PAL.Color.RGB Conveniences

internal extension PAL.Color.RGB {
	/// Create an RGB color from the content of a SIMD3
	/// - Parameters:
	///   - sRGB: The components values
	init(sRGB: SIMD3<Double>) {
		self.init(rf: sRGB.x, gf: sRGB.y, bf: sRGB.z)
	}

	/// Create an RGB color from a vector of values
	/// - Parameter value: rgb values
	init(_ value: SIMD3<Double>) {
		self.rf = value.x
		self.gf = value.y
		self.bf = value.z
		self.af = 1.0
	}

	/// A simple representation of the RGB values
	var simd3: SIMD3<Double> { SIMD3<Double>(self.rf, self.gf, self.bf) }
}
