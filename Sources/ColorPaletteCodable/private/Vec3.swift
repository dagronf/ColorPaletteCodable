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

/// A simple vector containing 3 elements
struct Vec3<T: BinaryFloatingPoint> {
	let x: T
	let y: T
	let z: T

	/// Create a vector object
	init(_ x: T, _ y: T, _ z: T) {
		self.x = x
		self.y = y
		self.z = z
	}

	/// Return a vector whose values are clamped between 0 and 1
	@inlinable var unitClamped: Self {
		Vec3(x.unitClamped, y.unitClamped, z.unitClamped)
	}
}

/// Linear interpolate between two vec3 instances
/// - Parameters:
///   - v0: First vector
///   - v1: Second vector
///   - t: The fractional distance between the two values
/// - Returns: Interpolated value
func lerp<T: FloatingPoint>(_ v0: Vec3<T>, _ v1: Vec3<T>, t: T) -> Vec3<T> {
	Vec3<T>(
		v0.x + (t * (v1.x - v0.x)),
		v0.y + (t * (v1.y - v0.y)),
		v0.z + (t * (v1.z - v0.z))
	)
}

// MARK: - Conveniences

internal extension PAL.Color {
	/// Create an RGB color from the content of a Vec3
	/// - Parameters:
	///   - sRGB: The components values
	///   - name: The color name
	init(sRGB: Vec3<Float32>, name: String = "") {
		self.init(rf: sRGB.x, gf: sRGB.y, bf: sRGB.z, name: name)
	}

	/// Return an Vec3 representation of this color. Throws an error if the color is not RGB colorspace
	/// - Returns: SIMD3 representation
	func rgbValuesVec3() throws -> Vec3<Float32> {
		let rgb = try self.rgb()
		return Vec3<Float32>(rgb.rf, rgb.gf, rgb.bf)
	}
}

internal extension PAL.Color.RGB {
	/// Create an RGB color from a vector of values
	/// - Parameter value: rgb values
	init(_ value: Vec3<Float32>) {
		self.rf = value.x
		self.gf = value.y
		self.bf = value.z
		self.af = 1.0
	}

	/// A simple representation of the RGB values
	var vec3: Vec3<Float32> { Vec3<Float32>(self.rf, self.gf, self.bf) }
}
