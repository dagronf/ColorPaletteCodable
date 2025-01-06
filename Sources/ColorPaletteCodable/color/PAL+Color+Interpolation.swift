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

// Color interpolation and bucketing

import Foundation

public extension PAL.Color {
	/// Returns a midpoint color between this color and another color
	/// - Parameters:
	///   - color2: The color to compare against
	///   - t: The fractional distance between the two colors (0 ... 1)
	///   - name: The name for the generated color, or nil for no name
	/// - Returns: The midpoint color
	func midpoint(_ color2: PAL.Color, t: UnitValue<Double>, named name: String? = nil) throws -> PAL.Color {
		if self.colorSpace == color2.colorSpace {
			assert(self.colorComponents.count == color2.colorComponents.count)
			let cs = zip(self.colorComponents, color2.colorComponents).map { i in
				lerp(i.0, i.1, t: Float32(t.value))
			}
			return try PAL.Color(
				name: name ?? "",
				colorSpace: self.colorSpace,
				colorComponents: cs,
				alpha: lerp(self.alpha, color2.alpha, t: Float32(t.value))
			)
		}

		let c1 = try self.rgbaComponents()
		let c2 = try color2.rgbaComponents()
		let t = t.value
		return try PAL.Color(
			name: name ?? "",
			rf: Float32(lerp(c1.r, c2.r, t: t)),
			gf: Float32(lerp(c1.g, c2.g, t: t)),
			bf: Float32(lerp(c1.b, c2.b, t: t)),
			af: Float32(lerp(c1.a, c2.a, t: t))
		)
	}
}

public extension PAL.Color {
	/// Create a color array by interpolating between two colors
	///   - firstColor: The first (starting) color for the palette
	///   - lastColor: The second (ending) color for the palette
	///   - count: Number of colors to generate
	static func interpolate(firstColor: PAL.Color, lastColor: PAL.Color, count: Int) throws -> [PAL.Color] {
		if count == 0 { throw PAL.CommonError.tooFewColors }
		if count == 1 { return [.white] }

		let c1 = try firstColor.rgbaComponents()
		let c2 = try lastColor.rgbaComponents()
		let step = 1.0 / Double(count - 1)

		let rdiff = (c2.r - c1.r) * step
		let gdiff = (c2.g - c1.g) * step
		let bdiff = (c2.b - c1.b) * step
		let adiff = (c2.a - c1.a) * step

		return try (0 ..< count).map { index in
			let index = Double(index)
			return try PAL.Color(
				rf: Float32(c1.r + (index * rdiff)),
				gf: Float32(c1.g + (index * gdiff)),
				bf: Float32(c1.b + (index * bdiff)),
				af: Float32(c1.a + (index * adiff))
			)
		}
	}
}

public extension PAL.Color {
	/// Returns a color for a time value mapped within an evenly spaced array of colors
	/// - Parameters:
	///   - t: The time value, 0.0 ... 1.0
	///   - colors: The array of colors to interpolate from
	///   - interpolate: If true, returns the interpolated color. if false, returns the bucketed color.
	/// - Returns: The color that falls within the time bucket
	@inlinable
	static func bucketedColor(at t: UnitValue<Double>, in colors: [PAL.Color], interpolate: Bool) throws -> PAL.Color {
		try colors.bucketedColor(at: t, interpolate: interpolate)
	}

	/// Returns a bucketed color for a time value mapped within an evenly spaced array of colors
	/// - Parameters:
	///   - t: The time value, 0.0 ... 1.0
	///   - colors: An array of colors to interpolate
	/// - Returns: The color that falls within the time bucket
	@inlinable
	static func bucketedColor(at t: UnitValue<Double>, in colors: [PAL.Color]) throws -> PAL.Color {
		try colors.bucketedColor(at: t)
	}

	/// Returns an interpolated color for a time value mapped within an evenly spaced array of colors
	/// - Parameters:
	///   - t: The time value, 0.0 ... 1.0
	///   - colors: An array of colors to interpolate
	/// - Returns: The color that falls within the time bucket
	@inlinable
	static func interpolatedColor(at t: UnitValue<Double>, in colors: [PAL.Color]) throws -> PAL.Color {
		try colors.interpolatedColor(at: t)
	}
}
