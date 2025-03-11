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

public extension PAL {
	/// Errors that can be throws for gradients
	enum GradientError: Error {
		/// Attempted to normalize a gradient where the minimum position value and the maximum position value were equal
		case cannotNormalize
		/// Attempted to map a palette onto a gradient with a different number of colors
		case mismatchColorCount
		/// The gradient colorspace is not supported
		case unsupportedColorFormat
		/// No gradients
		case noGradients
		/// Unable to convert to utf8 data
		case invalidStringData
		/// The gradient doesn't contain enough stops to create a gradient
		case notEnoughStops
		/// An unexpected error occurred
		case internalError
	}
}

// MARK: - Single gradient

public extension PAL {
	/// A gradient object represents a single gradient within a gradient file
	struct Gradient: Equatable, Codable {
		/// The gradient's unique identifier
		public let id = UUID()

		/// The gradient's name (optional).
		public var name: String?

		/// The stops within the gradient. Not guaranteed to be ordered by position
		public var stops: [Stop] = []

		/// Transparency stops within the gradient
		public var transparencyStops: [TransparencyStop]?

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
			PAL.Palette(colors: self.sorted.colors, name: self.name ?? "")
		}

		// MARK: Creation

		/// Create a gradient from an array of gradient stops
		/// - Parameters:
		///   - stops: The stops for the gradient
		///   - name: The name for the gradient (optional)
		public init(stops: [PAL.Gradient.Stop], name: String? = nil) {
			self.name = name
			self.stops = stops
		}

		/// Create a gradient
		/// - Parameters:
		///   - stops: The color stops within the gradient
		///   - transparencyStops: The transparency stops within the gradient
		///   - name: The gradient name
		public init(stops: [PAL.Gradient.Stop], transparencyStops: [PAL.Gradient.TransparencyStop]?, name: String? = nil) {
			self.name = name
			self.stops = stops
			self.transparencyStops = transparencyStops
		}

		/// Create an evenly spaced gradient from an array of colors with spacing between 0 -> 1
		/// - Parameters:
		///   - colors: The colors to evenly space within the gradient
		///   - name: The name for the gradient (optional)
		@inlinable public init(colors: [PAL.Color], name: String? = nil) {
			let div = 1.0 / Double(colors.count - 1)
			let stops = (0 ..< colors.count).map { Stop(position: Double($0) * div, color: colors[$0]) }
			self.init(stops: stops, name: name)
		}

		/// Create a gradient from colors and positions
		/// - Parameters:
		///   - colors: An array of colors to add to the gradient
		///   - positions: The corresponding array of positions for the colors
		///   - name: The name for the gradient (optional)
		@inlinable public init(colors: [PAL.Color], positions: [Double], name: String? = nil) {
			assert(colors.count == positions.count)
			let stops = zip(positions, colors).map { Stop(position: $0.0, color: $0.1) }
			self.init(stops: stops, name: name)
		}

		/// Create a gradient from an array of position:color tuples
		/// - Parameters:
		///   - colorPositions: An array of position:color tuples
		///   - name: The name for the gradient
		@inlinable public init(colorPositions: [(position: Double, color: PAL.Color)], name: String? = nil) {
			self.init(
				stops: colorPositions.map { Stop(position: $0.position, color: $0.color) },
				name: name
			)
		}

		/// Create a fake hue gradient from a hue range using incremental stops
		/// - Parameters:
		///   - hueRange: The hue range (0.0 ... 1.0)
		///   - stopCount: The number of stops to include in the gradient
		///   - saturation: The saturation
		///   - brightness: The brightness
		///   - name: The name for the gradient
		init(
			hueRange: ClosedRange<Float32>,
			stopCount: Int,
			saturation: Float32 = 1.0,
			brightness: Float32 = 1.0,
			name: String? = nil
		) {
			assert(stopCount > 1)
			let hueStart = hueRange.lowerBound.unitClamped
			let hueEnd = hueRange.upperBound.unitClamped
			let saturation = saturation.unitClamped
			let brightness = brightness.unitClamped
			
			let step = 1.0 / Float32(stopCount - 1)
			
			let colors: [PAL.Color] = stride(from: 0.0, through: 1.0, by: step).map { (s: Float32) in
				let h = lerp(hueStart, hueEnd, t: s)
				return PAL.Color(hf: h, sf: saturation, bf: brightness)
			}
			self.init(colors: colors, name: name)
		}
	}
}

// MARK: Export

public extension PAL.Gradient {
	/// Export this gradient
	/// - Parameter coder: The coder to use when exporting the gradient
	/// - Returns: raw gradient data
	func export(using coder: PAL_GradientsCoder) throws -> Data {
		try PAL.Gradients(gradient: self).export(using: coder)
	}
}

// MARK: Utilities

public extension PAL.Gradient {
	/// Return the color at a given fractional position within the gradient
	/// - Parameter t: The time within the gradient to retrieve the color (0 ... 1)
	/// - Returns: The color at the specified time value
	///
	/// If you're planning to call this function multiple times with the same gradient, it will be much more performant
	/// to create a `Gradient` snapshot and call the `color(at:)` function on the snapshot object.
	///
	/// ```swift
	/// let snapshot = try gradient.snapshot()
	/// let c1 = try snapshot.color(at: t1)
	/// let c2 = try snapshot.color(at: t2)
	/// let c3 = try snapshot.color(at: t3)
	/// ...
	/// ```
	func color(at t: UnitValue<Double>) throws -> PAL.Color {
		try Snapshot(gradient: self).color(at: t)
	}

	/// Return colors at fractional values across the gradient
	/// - Parameter t: A array of time values to sample
	/// - Returns: colors
	func colors(at t: [UnitValue<Double>]) throws -> [PAL.Color] {
		try Snapshot(gradient: self).colors(at: t)
	}

	/// Return evenly spaced colors across this gradient
	/// - Parameter count: The number of colors to return (including the first and last colors of the gradient)
	/// - Returns: colors
	func colors(count: Int) throws -> [PAL.Color] {
		return try Snapshot(gradient: self).colors(count: count)
	}
}

// MARK: Transparency

public extension PAL.Gradient {
	/// Returns an array of transparency stops for this gradient
	var transparencyMap: [TransparencyStop] {
		// If the gradient has transparency stops, use that
		if let t = self.transparencyStops {
			return t
		}

		// Otherwise, map the alpha colors out of the gradient's colors
		return self.stops.map {
			TransparencyStop(position: Double($0.position), value: Double($0.color.alpha), midpoint: 0.5)
		}
	}

	/// Create a gradient representing the transparency map for the gradient
	/// - Parameter baseColor: The base color for the gradient
	/// - Returns: A new gradient
	func createTransparencyGradient(_ baseColor: PAL.Color) throws -> PAL.Gradient {
		let base = try baseColor.rgb()
		let stops: [Stop] = self.transparencyMap.map {
			let color = rgbf(base.rf, base.gf, base.bf, Float32($0.value))
			return Stop(position: $0.position, color: color)
		}
		return PAL.Gradient(stops: stops)
	}

	/// Returns a copy of this gradient without any transparency information
	func removingTransparency() throws -> PAL.Gradient {
		let flatColors = try self.stops.map {
			PAL.Gradient.Stop(position: $0.position, color: try $0.color.removingTransparency())
		}
		return PAL.Gradient(stops: flatColors)
	}

	/// Does this gradient have any transparency information?
	var hasTransparency: Bool {
		self.transparencyMap.first(where: { $0.value < 0.99 }) != nil
	}

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
				let tv = Float32((stop - cseg.t1) / cseg.span)
				let rgb1 = try cseg.color1.rgb()
				let rgb2 = try cseg.color2.rgb()
				r = Float32(rgb1.rf + ((rgb2.rf - rgb1.rf) * tv))
				g = Float32(rgb1.gf + ((rgb2.gf - rgb1.gf) * tv))
				b = Float32(rgb1.bf + ((rgb2.bf - rgb1.bf) * tv))
			}

			do {
				// Find the transparency percentage within this segment using lerp
				let tv = (stop - tseg.t1) / tseg.span
				let tt1 = tseg.value1
				let tt2 = tseg.value2
				a = Float32(tt1 + ((tt2 - tt1) * tv))
			}

			let cv = PAL.Color(rf: r, gf: g, bf: b, af: a)
			mappedColorStops.append(cv)
		}

		return PAL.Gradient(colors: mappedColorStops, positions: g_stops)
	}
}

// MARK: Codable

public extension PAL.Gradient {
	enum CodingKeys: CodingKey {
		case name
		case stops
		case transparencyStops
	}

	/// Decode a gradient
	/// - Parameter decoder: the decoder
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decodeIfPresent(String.self, forKey: .name)
		self.stops = try container.decode([Stop].self, forKey: .stops)
		self.transparencyStops = try container.decodeIfPresent([TransparencyStop].self, forKey: .transparencyStops)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.name, forKey: .name)
		try container.encode(self.stops, forKey: .stops)
		try container.encodeIfPresent(self.transparencyStops, forKey: .transparencyStops)
	}
}

@available(macOS 10.15, *)
extension PAL.Gradient: Identifiable { }

// MARK: Sorting

public extension PAL.Gradient {
	/// Sort the stops within this gradient ascending by position
	mutating func sort() {
		self.stops = self.stops.sorted { a, b in a.position < b.position }
	}

	/// Return a gradient with the stops and transparency sorted ascending by position
	@inlinable var sorted: PAL.Gradient {
		PAL.Gradient(
			stops: self.stops.sorted { a, b in a.position < b.position },
			transparencyStops: self.transparencyStops?.sorted(by: { a, b in a.position < b.position }),
			name: self.name
		)
	}
}

// MARK: Normalization

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
			return PAL.Gradient(colors: [], name: self.name)
		}

		// Get the min/max and range values
		let minVal = self.minValue
		let maxVal = self.maxValue
		let range = maxVal - minVal
		if range == 0 {
			// This means that the min and max values are the same. We cannot do anything with this.
			throw PAL.GradientError.cannotNormalize
		}

		//
		// Sort the stops and normalize to 0 -> 1
		//
		let sorted = self.stops
			.sorted { a, b in a.position < b.position }
			.map {
				let position = $0.position
				// Shift value to zero point
				let shifted = position - minVal
				// Scale to fit the range
				let scaled = shifted / range
				return Stop(position: scaled, color: $0.color)
			}

		//
		// Sort the transparency stops and normalize
		//
		let ts = self.transparencyStops?
			.sorted { a, b in a.position < b.position }
			.map {
				let position = $0.position
				// Shift value to zero point
				let shifted = position - minVal
				// Scale to fit the range
				let scaled = shifted / range
				return TransparencyStop(position: scaled, value: $0.value, midpoint: $0.midpoint)
			}

		return PAL.Gradient(stops: sorted, transparencyStops: ts, name: self.name)
	}

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

	/// Create a new gradient by merging identical neighbouring stops into a single stop
	///
	/// Some gradient format types represent the gradient as an array of 'gradient segments'
	/// So, for example red-blue-green gradient ends up as
	///
	/// ```
	/// 0.0   255 0 0   0.5   0 255 0
	/// 0.5   0 255 0   1.0   0 0 255
	/// ```
	///
	/// As such, during import this is detected as 4 stops, with the middle two stops
	/// being identical. This function removes the duplicated stop(s)
	func mergeIdenticalNeighbouringStops() throws -> PAL.Gradient {
		guard self.stops.count > 1 else {
			// No stops, or only a single stop
			return self
		}

		var prev = self.stops[0]
		var merged: [PAL.Gradient.Stop] = [prev]

		for item in self.stops.dropFirst() {
			if prev.matchesColorAndPosition(of: item) == false {
				prev = item
				merged.append(item)
			}
		}
		return PAL.Gradient(stops: merged)
	}
}


// MARK: - Gradient stop

public extension PAL.Gradient {
	/// A color stop within the gradient
	struct Stop: Equatable, Codable {
		public let id = UUID()
		/// The color at the stop
		public var color: PAL.Color
		/// The position of the stop
		public var position: Double

		/// Create a color stop
		public init(position: Double, color: PAL.Color) {
			self.position = position
			self.color = color
		}

		enum CodingKeys: CodingKey {
			case position
			case color
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: Self.CodingKeys.self)
			self.position = try container.decode(Double.self, forKey: .position)
			self.color = try container.decode(PAL.Color.self, forKey: .color)
		}

		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: Self.CodingKeys.self)
			try container.encode(self.position, forKey: .position)
			try container.encode(self.color, forKey: .color)
		}

		public static func ==(lhs: Stop, rhs: Stop) -> Bool {
			lhs.color == rhs.color &&
			lhs.position == rhs.position
		}

		/// Compare two stops ignoring their ids
		public func matchesColorAndPosition(of s2: Stop?) -> Bool {
			guard let s2 = s2 else { return false }
			return self.position == s2.position
			&& self.color == s2.color
		}
	}
}

@available(macOS 10.15, *)
extension PAL.Gradient.Stop: Identifiable { }

// MARK: - Gradient transparency stop

public extension PAL.Gradient {
	/// A transparency stop
	struct TransparencyStop: Equatable, Codable {
		public let id = UUID()
		/// The opacity value at the stop (0 ... 1)
		public var value: Double
		/// The position of the stop (0 ... 1)
		public var position: Double
		/// The midpoint for the stop (0 ... 1). This represents the t value between this stop and the next one.
		public var midpoint: Double

		public init(position: Double, value: Double, midpoint: Double = 0.5) {
			self.value = value.unitClamped
			self.position = position.unitClamped
			self.midpoint = midpoint.unitClamped
		}

		enum CodingKeys: CodingKey {
			case value
			case position
			case midpoint
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: Self.CodingKeys.self)
			self.value = try container.decode(Double.self, forKey: .value)
			self.position = try container.decode(Double.self, forKey: .position)
			self.midpoint = try container.decode(Double.self, forKey: .midpoint)
		}

		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: Self.CodingKeys.self)
			try container.encode(self.value, forKey: .value)
			try container.encode(self.position, forKey: .position)
			try container.encode(self.midpoint, forKey: .midpoint)
		}

		/// Equality
		public static func ==(lhs: TransparencyStop, rhs: TransparencyStop) -> Bool {
			lhs.value == rhs.value &&
			lhs.position == rhs.position &&
			lhs.midpoint == rhs.midpoint
		}

		/// Compare two stops ignoring their ids
		public func matchesOpacityPositionAndMidpoint(of s2: TransparencyStop?) -> Bool {
			guard let s2 = s2 else { return false }
			return self.position == s2.position
				&& self.midpoint == s2.midpoint
				&& self.value == s2.value
		}
	}
}

@available(macOS 10.15, *)
extension PAL.Gradient.TransparencyStop: Identifiable { }


// MARK: - Integration

public extension PAL.Gradient {
	/// Create an evenly-spaced gradient from the global colors of a palette
	/// - Parameters:
	///   - palette: The palette to convert to a gradient
	///   - name: The gradient name
	@inlinable init(palette: PAL.Palette, name: String? = nil) {
		self.init(colors: palette.colors, name: name ?? palette.name)
	}

	/// Create an evenly-spaced gradient from a color group
	@inlinable init(group: PAL.Group, name: String? = nil) {
		self.init(colors: group.colors, name: name)
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
			stops:
				zip(self.stops, colors)
					.map { Stop(position: $0.0.position, color: $0.1) },
			name: self.name
		)
	}
}

public extension PAL.Palette {
	/// Returns an evenly-spaced gradient from the global colors of this palette
	/// - Parameter name: The gradient name
	/// - Returns: A gradient
	@inlinable func gradient(name: String? = nil) -> PAL.Gradient {
		PAL.Gradient(colors: self.colors, name: name)
	}
}

public extension PAL.Gradient {
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
