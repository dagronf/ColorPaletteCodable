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

extension Sequence where Element: Equatable {
	/// Return the unique elements in the array using Equatable as the predicate
	///
	/// Guaranteed to return the same ordering as per the original sequence
	@inlinable var unique: [Element] {
		return self.reduce(into: []) { uniqueElements, element in
			if !uniqueElements.contains(element) {
				uniqueElements.append(element)
			}
		}
	}
}

extension ExpressibleByIntegerLiteral where Self: Comparable {
	/// Clamp a value to an arbitrary range
	@inlinable func clamped(to range: ClosedRange<Self>) -> Self {
		min(range.upperBound, max(range.lowerBound, self))
	}

	/// Clamp a value to the range 0 ... 1
	@inlinable func unitClamped() -> Self {
		self.clamped(to: 0 ... 1)
	}
}

extension BinaryFloatingPoint {
	/// An equality check with a precision accuracy
	/// - Parameters:
	///   - value: The value to compare
	///   - precision: The precision (accuracy) in decimal places (eg. 8 == 8 decimal places)
	/// - Returns: True if mostly equal, false otherwise
	@inlinable func isEqual(to value: Self, precision: UInt) -> Bool {
		let p = Self(pow(10, -Double(precision)))
		return self.isEqual(to: value, accuracy: p)
	}

	/// An equality check with an accuracy
	/// - Parameters:
	///   - value: The value to compare
	///   - precision: The accuracy to check
	/// - Returns: True if mostly equal, false otherwise
	@inlinable func isEqual(to value: Self, accuracy: Self) -> Bool {
		abs(self - value) < accuracy
	}
}

extension Double {
	/// Round this value to a specific number of decimal places (eg. 3.149 -> 3.15)
	/// - Parameters:
	///   - precision: The expected number of decimal places
	///   - rule: The rounding rule to use
	/// - Returns: A new value
	func roundToPrecision(_ precision: UInt, rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Double {
		let factor = pow(10.0, Double(precision))
		return (self * factor).rounded(rule) / factor
	}

	/// Truncate this value to a specific precision (eg. 3.149 -> 3.14)
	/// - Parameter precision: The number of decimal places to keep
	/// - Returns: A new truncated double value
	func truncate(_ precision: UInt) -> Double {
		let factor = pow(10.0, Double(precision))
		return Double(Int(self * factor)) / factor
	}
}
