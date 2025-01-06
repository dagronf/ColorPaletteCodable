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

// Array extension for PAL.Color

import Foundation

public extension Array where Element == PAL.Color {
	/// Returns a color for a time value mapped within an evenly spaced array of colors
	/// - Parameters:
	///   - t: The time value, 0.0 ... 1.0
	///   - interpolate: If true, returns the interpolated color. if false, returns the bucketed color.
	/// - Returns: The color that falls within the time bucket
	func bucketedColor(at t: UnitValue<Double>, interpolate: Bool) throws -> PAL.Color {
		interpolate ? try self.interpolatedColor(at: t) : try self.bucketedColor(at: t)
	}

	/// Returns a bucketed color for a time value mapped within an evenly spaced array of colors
	/// - Parameter t: The time value, 0.0 ... 1.0
	/// - Returns: The color that falls within the time bucket
	func bucketedColor(at t: UnitValue<Double>) throws -> PAL.Color {
		guard self.count > 0 else {
			throw PAL.CommonError.tooFewColors
		}

		if self.count == 1 {
			// If there's only a single color, this is the result
			return self.first!
		}

		let tValue = t.value

		if tValue.isEqual(to: 0.0, precision: 8) {
			// Just return the first value (which will exist because we've checked earlier, hence the force unwrap)
			return self.first!
		}
		else if tValue.isEqual(to: 1.0, precision: 8) {
			// Just return the last value (which will exist because we've checked earlier, hence the force unwrap)
			return self.last!
		}

		// Which chunk does the value fall in?
		let chunkSize = 1.0 / Double(self.count)
		let which = Int((tValue / chunkSize).rounded(.towardZero))
		assert(which >= 0 && which < self.count)

		return self[which]
	}

	/// Returns an interpolated color for a time value mapped within an evenly spaced array of colors
	/// - Parameter t: The time value, 0.0 ... 1.0
	/// - Returns: The color that falls within the time bucket
	func interpolatedColor(at t: UnitValue<Double>) throws -> PAL.Color {
		guard self.count > 0 else {
			throw PAL.CommonError.tooFewColors
		}

		if self.count == 1 {
			// If there's only a single color, this is the result
			return self.first!
		}

		let tValue = t.value

		// If t == 0, return the first value
		if tValue.isEqual(to: 0.0, precision: 8) {
			return self.first!
		}

		// If t == 1, return the last value
		if tValue.isEqual(to: 1.0, precision: 8) {
			return self.last!
		}

		let divisor = 1.0 / Double(self.count - 1)

		let which = Int(tValue / divisor)
		if which == self.count - 1 {
			return self.last!
		}

		let x1 = Double(which) * divisor
		let x2 = Double(which + 1) * divisor
		let y1 = self[which]
		let y2 = self[which + 1]

		// The new t value is the current t value fractionally between x1 and x2
		let newT = (tValue - x1) / (x2 - x1)

		// Linearly interpolate between the two colors at the new time value
		return try y1.midpoint(y2, t: UnitValue(newT))
	}
}
