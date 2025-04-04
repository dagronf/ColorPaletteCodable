//
//  Copyright © 2025 Darren Ford. All rights reserved.
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

extension NumberFormatter {
	/// A convenience initializer for creating a NumberFormatter and initializing it using a block
	///
	/// ```swift
	/// let percentFormatter = NumberFormatter {
	///    $0.numberStyle = .percent
	///    $0.maximumFractionDigits = 2
	/// }
	/// ```
	convenience init(_ builder: (NumberFormatter) -> Void) {
		self.init()
		builder(self)
	}
}

extension NumberFormatter {
	/// Returns a string containing the formatted value
	/// - Parameter value: The value to format
	/// - Returns: A string, or nil if the value cannot be represented using this formatter
	@inlinable func string<T: BinaryFloatingPoint>(for value: T) -> String? {
		self.string(from: NSNumber(value: Double(value)))
	}

	/// Returns a string containing the formatted value
	/// - Parameter value: The value to format
	/// - Returns: A string, or nil if the value cannot be represented using this formatter
	@inlinable func string<T: BinaryInteger>(for value: T) -> String? {
		self.string(from: NSNumber(value: Int64(value)))
	}

	/// Returns a string containing the formatted value
	/// - Parameter value: The value to format
	/// - Returns: A string, or nil if the value cannot be represented using this formatter
	@inlinable func string<T: UnsignedInteger>(for value: T) -> String? {
		self.string(from: NSNumber(value: UInt64(value)))
	}
}
