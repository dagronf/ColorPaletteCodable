//
//  PAL+Gradients.swift
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

public extension PAL {
	/// Errors that can be throws for gradients
	enum GradientError: Error {
		/// Attempted to normalize a gradient where the minimum position value and the maximum position value were equal
		case cannotNormalize
		/// Attempted to map a palette onto a gradient with a different number of colors
		case mismatchColorCount
		/// The gradient colorspace is not supported
		case unsupportedColorFormat
	}
}

// MARK: Single gradient definition

public extension PAL {
	/// A gradient
	struct Gradient: Equatable, Codable, Identifiable {
		/// A color stop within the gradient
		public struct Stop: Equatable, Codable, Identifiable {
			public let id: UUID
			/// The position of the color within the gradient.
			public var position: Double
			/// The color at the stop
			public var color: PAL.Color
			/// Create a color stop
			@inlinable public init(position: Double, color: PAL.Color) {
				self.position = position
				self.color = color
				self.id = UUID()
			}

			public init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: Self.CodingKeys.self)
				self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
				self.position = try container.decode(Double.self, forKey: .position)
				self.color = try container.decode(PAL.Color.self, forKey: .color)
			}

			/// Compare two stops ignoring their ids
			public func matchesColorAndPosition(of s2: Stop?) -> Bool {
				guard let s2 = s2 else { return false }
				return self.position == s2.position
				&& self.color == s2.color
			}
		}

		/// A transparency stop
		public struct TransparencyStop: Equatable, Codable, Identifiable {
			public let id: UUID
			/// The opacity value at the stop (0 ... 1)
			public var value: Double
			/// The position of the stop (0 ... 1)
			public var position: Double
			/// The midpoint for the stop (0 ... 1)
			public var midpoint: Double

			public init(position: Double, value: Double, midpoint: Double = 0.5) {
				self.id = UUID()
				self.value = max(0, min(1, value))
				self.position = max(0, min(1, position))
				self.midpoint = max(0, min(1, midpoint))
			}

			public init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: Self.CodingKeys.self)
				self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
				self.value = try container.decode(Double.self, forKey: .value)
				self.position = try container.decode(Double.self, forKey: .position)
				self.midpoint = try container.decode(Double.self, forKey: .midpoint)
			}

			/// Compare two stops ignoring their ids
			public func matchesOpacityPositionAndMidpoint(of s2: TransparencyStop?) -> Bool {
				guard let s2 = s2 else { return false }
				return self.position == s2.position
					&& self.midpoint == s2.midpoint
					&& self.value == s2.value
			}
		}

		/// The gradient's name (optional).
		public var name: String?

		/// The gradient's unique identifier
		public let id: UUID

		/// The stops within the gradient. Not guaranteed to be ordered by position
		public var stops: [Stop] = []

		/// Transparency stops within the gradient
		public var transparencyStops: [TransparencyStop]?

		/// Return a transparency map for the gradient
		public var mappedTransparency: [TransparencyStop] {
			// If the gradient has transparency stops, use that
			if let t = self.transparencyStops {
				return t
			}

			// Otherwise, map the alpha colors out of the gradient's colors
			return self.stops.map {
				TransparencyStop(position: Double($0.position), value: Double($0.color.alpha), midpoint: 0.5)
			}
		}

		/// Return a gradient representing the transparency map for the gradient
		public func transparencyGradient(_ baseColor: PAL.Color) -> PAL.Gradient {
			let stops: [Stop] = self.mappedTransparency.map {
				let color = try! PAL.Color(rf: baseColor.r(), gf: baseColor.g(), bf: baseColor.b(), af: Float32($0.value))
				return Stop(position: $0.position, color: color)
			}
			return PAL.Gradient(stops: stops)
		}

		/// Returns a copy of this gradient without any transparency information
		public func withoutTransparency() -> PAL.Gradient {
			let flatColors = self.stops.map {
				PAL.Gradient.Stop(position: $0.position, color: $0.color.removeTransparency())
			}
			return PAL.Gradient(stops: flatColors)
		}

		/// Does this gradient have any transparency information?
		public var hasTransparency: Bool {
			self.mappedTransparency.first(where: { $0.value < 0.99 }) != nil
		}

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

		/// Return a palette containing the colors in the order of the color stops
		@inlinable public var palette: PAL.Palette {
			PAL.Palette(name: self.name ?? "", colors: self.sorted.colors)
		}

		// MARK: Creation

		/// Create a gradient from an array of gradient stops
		/// - Parameters:
		///   - name: The name for the gradient (optional)
		///   - stops: The stops for the gradient
		public init(name: String? = nil, stops: [PAL.Gradient.Stop]) {
			self.id = UUID()
			self.name = name
			self.stops = stops
		}

		/// Create a gradient
		/// - Parameters:
		///   - name: The gradient name
		///   - stops: The color stops within the gradient
		///   - transparencyStops: The transparency stops within the gradient
		public init(name: String? = nil, stops: [PAL.Gradient.Stop], transparencyStops: [PAL.Gradient.TransparencyStop]?) {
			self.id = UUID()
			self.name = name
			self.stops = stops
			self.transparencyStops = transparencyStops
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

		/// Decode a gradient
		/// - Parameter decoder: the decoder
		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: Self.CodingKeys.self)
			self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
			self.name = try container.decodeIfPresent(String.self, forKey: .name)
			self.stops = try container.decode([Stop].self, forKey: .stops)
			self.transparencyStops = try container.decodeIfPresent([TransparencyStop].self, forKey: .transparencyStops)
		}
	}
}

// MARK: - Sorting

public extension PAL.Gradient {
	/// Sort the stops within this gradient ascending by position
	mutating func sort() {
		self.stops = self.stops.sorted { a, b in a.position < b.position }
	}

	/// Return a gradient with the stops and transparency sorted ascending by position
	@inlinable var sorted: PAL.Gradient {
		PAL.Gradient(
			name: self.name,
			stops: self.stops.sorted { a, b in a.position < b.position },
			transparencyStops: self.transparencyStops?.sorted(by: { a, b in a.position < b.position })
		)
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

public extension PAL.Gradient {
	/// Map the transparency stops in the gradient to a 0 ... 1 range
	func normalizedTransparencyStops() throws -> [TransparencyStop] {
		guard let tstops = self.transparencyStops, stops.count > 0 else { return [] }

		// Get the min/max and range values
		let minVal = tstops.map { $0.position }.min() ?? 0
		let maxVal = tstops.map { $0.position }.max() ?? 0
		let range = maxVal - minVal
		if range == 0 {
			// This means that the min and max values are the same. We cannot do anything with this.
			throw PAL.GradientError.cannotNormalize
		}

		// Sort the stops
		let sorted = tstops.sorted { a, b in a.position < b.position }

		// Map the stops into a 0 -> 1 range
		let scaled: [TransparencyStop] = sorted.map {
			let position = $0.position
			// Shift value to zero point
			let shifted = position - minVal
			// Scale to fit the range
			let scaled = shifted / range
			return TransparencyStop(position: scaled, value: $0.value, midpoint: $0.midpoint)
		}
		return scaled
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
}

public extension PAL.Palette {
	/// Returns an evenly-spaced gradient from the global colors of this palette
	@inlinable func gradient(named name: String? = nil) -> PAL.Gradient {
		PAL.Gradient(name: name, colors: self.colors)
	}
}

public extension PAL.Gradient {
	/// Return a new gradient by flattening transparency stops into the color stops
	///
	/// Some gradient formats (such as Adobe GRD) maintain the transparencies as a separate
	/// array. This function creates a new gradient with the transparency values baked into the
	/// color stops. Note that the number of color stops may change, as there may be more
	/// transparency stops than there are color stops
	///
	/// If the gradient has no transparency stops, returns the original gradient.
	func mergeTransparencyStops() throws -> PAL.Gradient {
		// If we have no transparency stops, then just return the original gradient
		if self.transparencyStops == nil { return self }

		// Make sure our colors map between 0 ... 1
		let colors = try self.normalized()
		// The 't' values for the color stops within the gradient
		let color_t = colors.stops.map { $0.position }

		struct cpos {
			let color1: PAL.Color
			let t1: Double
			let color2: PAL.Color
			let t2: Double
			var span: Double { t2 - t1 }
			func contains(_ value: Double) -> Bool { value >= t1 && value <= t2 }
		}

		let csegments: [cpos] = try {
			var segments: [cpos] = []
			for index in 0 ..< (colors.stops.count - 1) {
				let c1 = colors.stops[index]
				let cc1 = try c1.color.converted(to: .RGB)
				let c2 = colors.stops[index + 1]
				let cc2 = try c2.color.converted(to: .RGB)
				segments.append(cpos(color1: cc1, t1: c1.position, color2: cc2, t2: c2.position))
			}
			return segments
		}()

		// Map the transparency stops to 0 ... 1
		let trans = try self.normalizedTransparencyStops()
		// The 't' values for the transparency stops within the gradient
		let trans_t = trans.map { $0.position }

		struct tpos {
			let value1: Double
			let t1: Double
			let value2: Double
			let t2: Double
			var span: Double { t2 - t1 }
			func contains(_ value: Double) -> Bool { value >= t1 && value <= t2 }
		}

		let tsegments: [tpos] = {
			var segments: [tpos] = []
			for index in 0 ..< (trans.count - 1) {
				let c1 = trans[index]
				let c2 = trans[index + 1]
				segments.append(tpos(value1: c1.value, t1: c1.position, value2: c2.value, t2: c2.position))
			}
			return segments
		}()

		// All of the stops in the resulting gradient (0 ... 1)
		let g_stops = (color_t + trans_t).sorted(by: <).unique

		var mappedColorStops: [PAL.Color] = []

		for stop in g_stops {
			var r: Float32 = 0.0
			var g: Float32 = 0.0
			var b: Float32 = 0.0
			var a: Float32 = 0.0

			guard
				let cseg = csegments.first(where: { $0.contains(stop) }),
				let tseg = tsegments.first(where: { $0.contains(stop) })
			else {
				assert(false, "color or transparency segment mapping failed?")
				return self
			}

			do {
				// Find the color percentage within this segment using lerp
				let tv = (stop - cseg.t1) / cseg.span
				let rgb1 = try cseg.color1.rgbaComponents()
				let rgb2 = try cseg.color2.rgbaComponents()
				r = Float32(rgb1.0 + ((rgb2.0 - rgb1.0) * tv))
				g = Float32(rgb1.1 + ((rgb2.1 - rgb1.1) * tv))
				b = Float32(rgb1.2 + ((rgb2.2 - rgb1.2) * tv))
			}

			do {
				// Find the transparency percentage within this segment using lerp
				let tv = (stop - tseg.t1) / tseg.span
				let tt1 = tseg.value1
				let tt2 = tseg.value2
				a = Float32(tt1 + ((tt2 - tt1) * tv))
			}

			let cv = try PAL.Color(rf: r, gf: g, bf: b, af: a)
			mappedColorStops.append(cv)
		}

		return PAL.Gradient(colors: mappedColorStops, positions: g_stops)
	}

	/// Expand gradient edges to the full 0.0 -> 1.0 bounds
	///
	/// Example :-
	///
	/// * If the gradient starts at position 0.2, this function inserts a new stop at 0
	///   with the same color as the first position
	/// * If the gradient ends at position 0.95, this function appends a new stop with
	///   the same color as the last position
	///
	/// The same approach occurs for transparency stops if they exist.
	func expandGradientToEdges() -> PAL.Gradient {
		// Make sure our stops are sorted from 0 -> 1
		var gradient = self.sorted

		if let first = gradient.stops.first, first.position > 0.05 {
			let infill = PAL.Gradient.Stop(position: 0, color: first.color)
			gradient.stops.insert(infill, at: 0)
		}

		if let last = gradient.stops.last, last.position < 0.95 {
			let infill = PAL.Gradient.Stop(position: 1, color: last.color)
			gradient.stops.append(infill)
		}

		if let first = gradient.transparencyStops?.first, first.position > 0.05 {
			let infill = PAL.Gradient.TransparencyStop(position: 0, value: first.value)
			gradient.transparencyStops?.insert(infill, at: 0)
		}

		if let last = gradient.transparencyStops?.last, last.position < 0.95 {
			let infill = PAL.Gradient.TransparencyStop(position: 1, value: last.value)
			gradient.transparencyStops?.append(infill)
		}
		return gradient
	}
}
