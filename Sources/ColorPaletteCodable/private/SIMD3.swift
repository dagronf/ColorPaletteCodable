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

//  SIMD3 routines for non-SIMD platforms

import Foundation

#if !canImport(Darwin)

struct SIMD3<T: BinaryFloatingPoint> {
	@usableFromInline let v: [T]
	@inlinable init(_ v0: T, _ v1: T, _ v2: T) {
		self.v = [v0, v1, v2]
	}

	@inlinable var x: T { v[0] }
	@inlinable var y: T { v[1] }
	@inlinable var z: T { v[2] }

	@inlinable subscript(_ index: Int) -> T {
		assert(index >= 0 && index < 3)
		return v[index]
	}

	@inlinable func clamped(lowerBound: SIMD3<T>, upperBound: SIMD3<T>) -> SIMD3<T> {
		SIMD3(
			v[0].clamped(to: lowerBound.v[0] ... upperBound.v[0]),
			v[1].clamped(to: lowerBound.v[1] ... upperBound.v[1]),
			v[2].clamped(to: lowerBound.v[2] ... upperBound.v[2])
		)
	}
	
	@inlinable var unitClamped: SIMD3<T> {
		self.clamped(lowerBound: .init(0, 0, 0), upperBound: .init(1, 1, 1))
	}

	/// Linear interpolate between two SIMD3 instances
	/// - Parameters:
	///   - v0: First vector
	///   - v1: Second vector
	///   - t: The fractional distance between the two values
	/// - Returns: Interpolated value
	@inlinable static func lerp(_ v0: SIMD3, _ v1: SIMD3, t: T) -> SIMD3 {
		v0 + (t * (v1 - v0))
	}

	// MARK: -

	@inlinable static func -(left: SIMD3, right: SIMD3) -> SIMD3 {
		SIMD3(left.v[0] - right.v[0], left.v[1] - right.v[1], left.v[2] - right.v[2])
	}
	@inlinable static func -(left: SIMD3, value: T) -> SIMD3 {
		SIMD3(left.v[0] - value, left.v[1] - value, left.v[2] - value)
	}

	// MARK: *

	@inlinable static func *(left: SIMD3, right: SIMD3) -> SIMD3 {
		SIMD3(left.v[0] * right.v[0], left.v[1] * right.v[1], left.v[2] * right.v[2])
	}
	@inlinable static func *(value: T, right: SIMD3) -> SIMD3 {
		SIMD3(right.v[0] * value, right.v[1] * value, right.v[2] * value)
	}
	@inlinable static func *(left: SIMD3, value: T) -> SIMD3 {
		SIMD3(left.v[0] * value, left.v[1] * value, left.v[2] * value)
	}

	// MARK: +

	@inlinable static func +(left: SIMD3, value: T) -> SIMD3 {
		SIMD3(left.v[0] + value, left.v[1] + value, left.v[2] + value)
	}
	@inlinable static func +(left: SIMD3, right: SIMD3) -> SIMD3 {
		SIMD3(left.v[0] + right.v[0], left.v[1] + right.v[1], left.v[2] + right.v[2])
	}

	// MARK: /

	@inlinable static func /(left: SIMD3, value: T) -> SIMD3 {
		SIMD3(left.v[0] / value, left.v[1] / value, left.v[2] / value)
	}
	@inlinable static func /(left: SIMD3, right: SIMD3) -> SIMD3 {
		SIMD3(left.v[0] / right[0], left.v[1] / right[1], left.v[2] / right[2])
	}
}

#endif
