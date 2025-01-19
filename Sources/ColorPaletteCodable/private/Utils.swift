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

/// Linear interpret between two values
/// - Parameters:
///   - v0: First value
///   - v1: Second value
///   - t: The fractional distance between the two values
/// - Returns: Interpolated value
@inlinable func lerp<T: FloatingPoint>(_ v0: T, _ v1: T, t: T) -> T {
	return v0 + (t * (v1 - v0))
}

/// Convert a palettized 0 ... 255 value to a 0 ... 1 double value
@inlinable func _u2f<T: BinaryFloatingPoint>(_ value: UInt8) -> T {
	return T(value) / 255.0
}

/// Convert a Double unit value to a palettized 0 ... 255 value
@inlinable func _f2u<T: BinaryFloatingPoint>(_ value: T) -> UInt8 {
	return UInt8((value * 255).clamped(to: 0 ... 255))
}
