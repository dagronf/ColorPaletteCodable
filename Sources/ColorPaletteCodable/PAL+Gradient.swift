//
//  PAL+Gradient.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
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

public extension PAL {
	/// Errors that can be throws for gradients
	enum GradientError: Error {
		/// Attempted to normalize a gradient where the minimum position value and the maximum position value were equal
		case cannotNormalize
		/// Attempted to map a palette onto a gradient with a different number of colors
		case mismatchColorCount
	}

	/// A simple gradient object
	struct Gradient: Equatable, Codable {
		/// A color stop within the gradient
		public struct Stop: Equatable, Codable {
			/// The position of the color within the gradient.
			public var position: Double
			/// The color at the stop
			public var color: PAL.Color
			/// Create a color stop
			@inlinable public init(position: Double, color: PAL.Color) {
				self.position = position
				self.color = color
			}
		}

		/// The gradient's name (optional).
		public var name: String?

		/// The stops within the gradient. Not guaranteed to be ordered by position
		public var stops: [Stop] = []

		/// The minimum position value for a stop within the gradient
		@inlinable public var minValue: Double {
			if self.stops.isEmpty { return 0 }
			return self.stops.min { a, b in a.position < b.position }!.position
		}

		/// The maximum position value for a stop within the gradient
		@inlinable public var maxValue: Double {
			if self.stops.isEmpty { return 0 }
			return self.stops.max { a, b in a.position < b.position }!.position
		}

		/// The colors defined in the gradient.
		@inlinable public var colors: [PAL.Color] {
			self.stops.map { $0.color }
		}

		// MARK: Creation

		/// Create a gradient from an array of gradient stops
		/// - Parameters:
		///   - name: The name for the gradient (optional)
		///   - stops: The stops for the gradient
		public init(name: String? = nil, stops: [PAL.Gradient.Stop]) {
			self.name = name
			self.stops = stops
		}

		/// Create an evenly spaced gradient from an array of colors with spacing between 0 -> 1
		/// - Parameters:
		///   - name: The name for the gradient (optional)
		///   - stops: The colors to evenly space within the gradient
		@inlinable public init(name: String? = nil, colors: [PAL.Color]) {
			let div = 1.0 / Double(colors.count - 1)
			let stops = (0 ..< colors.count).map { Stop(position: Double($0) * div, color: colors[$0]) }
			self.init(name: name, stops: stops)
		}

		/// Create a gradient from colors and positions
		/// - Parameters:
		///   - name: The name for the gradient (optional)
		///   - colors: An array of colors to add to the gradient
		///   - positions: The corresponding array of positions for the colors
		@inlinable public init(name: String? = nil, colors: [PAL.Color], positions: [Double]) {
			assert(colors.count == positions.count)
			let stops = zip(positions, colors).map { Stop(position: $0.0, color: $0.1) }
			self.init(name: name, stops: stops)
		}

		/// Create a gradient from an array of position:color tuples
		/// - Parameters:
		///   - name: The name for the gradient (optional)
		///   - colorPositions: An array of position:color tuples
		@inlinable public init(name: String? = nil, colorPositions: [(position: Double, color: PAL.Color)]) {
			self.init(name: name, stops: colorPositions.map { Stop(position: $0.position, color: $0.color) })
		}
	}
}

// MARK: - Sorting

public extension PAL.Gradient {
	/// Sort the stops within this gradient ascending by position
	mutating func sort() {
		self.stops = self.stops.sorted { a, b in a.position < b.position }
	}

	/// Return a gradient with the stops sorted ascending by position
	@inlinable var sorted: PAL.Gradient {
		PAL.Gradient(name: self.name, stops: self.stops.sorted { a, b in a.position < b.position })
	}
}

// MARK: - Normalization

public extension PAL.Gradient {
	/// Normalize the stops within the gradient
	///
	/// Maps the stops by scaling the stop positions to 0 -> 1 and sorting the result
	@inlinable mutating func normalize() throws {
		let gr = try self.normalized()
		self.stops = gr.stops
	}

	/// Returns a new gradient by scaling the stop positions to 0 -> 1 and sorting the resulting gradient
	///
	/// * If the min position and max position are the same (ie. no normalization can be performed), throws `PAL.GradientError.minMaxValuesEqual`
	func normalized() throws -> PAL.Gradient {
		if self.stops.count == 0 {
			return PAL.Gradient(name: self.name, colors: [])
		}

		// Get the min/max and range values
		let minVal = self.minValue
		let maxVal = self.maxValue
		let range = maxVal - minVal
		if range == 0 {
			// This means that the min and max values are the same. We cannot do anything with this.
			throw PAL.GradientError.cannotNormalize
		}

		// Sort the stops
		let sorted = stops.sorted { a, b in a.position < b.position }

		// Map the stops into a 0 -> 1 range
		let scaled: [Stop] = sorted.map {
			let position = $0.position
			// Shift value to zero point
			let shifted = position - minVal
			// Scale to fit the range
			let scaled = shifted / range
			return Stop(position: scaled, color: $0.color)
		}
		return PAL.Gradient(name: self.name, stops: scaled)
	}
}

// MARK: - Integration

public extension PAL.Gradient {
	/// Create an evenly-spaced gradient from the global colors of a palette
	@inlinable init(name: String? = nil, palette: PAL.Palette) {
		self.init(name: name ?? palette.name, colors: palette.colors)
	}

	/// Create an evenly-spaced gradient from a color group
	@inlinable init(name: String? = nil, group: PAL.Group) {
		self.init(name: name, colors: group.colors)
	}

	/// Replace the colors in a gradient with the colors defined in the palette without modifying the positions
	///
	/// Throws `PAL.GradientError.mismatchColorCount` if the current stop count differs from the palette color count
	func mapPalette(_ palette: PAL.Palette) throws -> PAL.Gradient {
		let colors = palette.allColors()
		guard colors.count == self.stops.count else {
			throw PAL.GradientError.mismatchColorCount
		}

		return PAL.Gradient(
			name: self.name,
			stops:
				zip(self.stops, colors)
					.map { Stop(position: $0.0.position, color: $0.1) }
		)
	}

	/// Creates a palette from the colors in the gradient
	@inlinable func palette() -> PAL.Palette {
		PAL.Palette(name: self.name ?? "", colors: self.colors)
	}
}

public extension PAL.Palette {
	/// Returns an evenly-spaced gradient from the global colors of this palette
	@inlinable func gradient(named name: String? = nil) -> PAL.Gradient {
		PAL.Gradient(name: name, colors: self.colors)
	}
}
