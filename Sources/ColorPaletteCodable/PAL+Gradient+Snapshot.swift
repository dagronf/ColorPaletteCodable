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

// MARK: - Extracting colors

public extension PAL.Gradient {
	/// Create a snapshot of a gradient, with sorted normalized positions and merged transparency
	func snapshot() throws -> Snapshot {
		try Snapshot(gradient: self)
	}

	/// A snapshot of a gradient, with sorted normalized positions and merged transparency
	struct Snapshot {
		/// The gradient
		public let gradient: PAL.Gradient
		/// The gradient stops
		private let stops: [PAL.Gradient.Stop]
		/// Create a snapshot for a gradient
		internal init(gradient: PAL.Gradient) throws {
			// Create a copy with range of 0 ... 1, and merge transparency stops if they exist
			self.gradient = try gradient
				.normalized()
				.sorted
				.mergeTransparencyStops()
			self.stops = self.gradient.stops
		}

		/// Return the color at the given time within the gradient
		/// - Parameter t: The time within the gradient to retrieve the color
		/// - Returns: The color at the specified time value
		public func color(at t: UnitValue<Double>) throws -> PAL.Color {
			// If no stops, then no color!
			if self.stops.count == 0 { throw PAL.GradientError.notEnoughStops }
			// If only a single stop, return that color
			if self.stops.count == 1 { return self.stops[0].color }

			guard
				let first = self.stops.first,
				let last = self.stops.last
			else {
				throw PAL.GradientError.notEnoughStops
			}

			let t = t.value

			if t == 0 { return first.color }
			if t == 1 { return last.color }

			for index in 0 ..< self.stops.count {
				if
					t >= self.stops[index].position,
					t <  self.stops[index + 1].position
				{
					let e1 = self.stops[index]
					let e2 = self.stops[index + 1]
					let mt = (t - e1.position) / (e2.position - e1.position)
					return try e1.color.midpoint(e2.color, t: mt.unitValue)
				}
			}

			throw PAL.GradientError.internalError
		}

		/// Return colors at fractional values across the gradient
		/// - Parameter t: A array of time values to sample
		/// - Returns: colors
		func colors(at t: [UnitValue<Double>]) throws -> [PAL.Color] {
			return try t.map { try self.color(at: $0) }
		}

		/// Return evenly spaced colors across this gradient
		/// - Parameter count: The number of colors to return (including the first and last colors of the gradient)
		/// - Returns: colors
		func colors(count: Int) throws -> [PAL.Color] {
			assert(count > 1)
			let ts = stride(from: 0.0, through: 1.0, by: 1.0 / (Double(count) - 1))
			let tm = ts.map { $0.unitValue }
			return try self.colors(at: tm)
		}
	}
}
