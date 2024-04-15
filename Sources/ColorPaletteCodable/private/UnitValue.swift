//
//  UnitValue.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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

/// A unit floating point value (clamped to 0 ... 1)
public struct UnitValue<T: BinaryFloatingPoint> {
	public let value: T
	/// Create with a value clamped between 0 ... 1
	@inlinable public init(_ value: T) {
		self.value = max(0, min(1, value))
	}
}

extension UnitValue: Codable {
	public init(from decoder: Decoder) throws {
		let c = try decoder.singleValueContainer()
		let v = try c.decode(Double.self)
		self.init(T(v))
	}

	public func encode(to encoder: Encoder) throws {
		var c = encoder.singleValueContainer()
		try c.encode(Double(self.value))
	}
}

extension BinaryFloatingPoint {
	/// Return a clamped unit value (0 ... 1) for this value
	@inlinable public var unitValue: UnitValue<Self> { UnitValue(self) }
}
