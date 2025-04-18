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

// MARK: - Mixing, Blending and color midpoints

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
				lerp(i.0, i.1, t: t.value)
			}
			return try PAL.Color(
				colorSpace: self.colorSpace,
				colorComponents: cs,
				alpha: lerp(self.alpha, color2.alpha, t: t.value),
				name: name ?? ""
			)
		}

		let c1 = try self.rgb()
		let c2 = try color2.rgb()
		let t = t.value
		return PAL.Color(
			rf: lerp(c1.rf, c2.rf, t: t),
			gf: lerp(c1.gf, c2.gf, t: t),
			bf: lerp(c1.bf, c2.bf, t: t),
			af: lerp(c1.af, c2.af, t: t),
			name: name ?? ""
		)
	}

	/// Returns a new color by blending this color with another color in the OkLab colorspace
	/// - Parameters:
	///   - color2: The color to compare against
	///   - t: The fractional distance between the two colors (0 ... 1)
	///   - name: The name for the generated color, or nil for no name
	/// - Returns: The midpoint color
	@inlinable @inline(__always)
	func blending(with color2: PAL.Color, t: UnitValue<Double>, named name: String = "") throws -> PAL.Color {
		try OkLab.mix(self, color2, t: t.value, name: name)
	}
}

// MARK: - Interpolating colors

public extension PAL.Color {
	/// Create a color array by interpolating between two colors
	/// - Parameters:
	///   - startColor: The first (starting) color for the palette
	///   - endColor: The second (ending) color for the palette
	///   - count: Number of colors to generate
	///   - useOkLab: If true, use OkLab colorspace when generating colors
	/// - Returns: An array of interpolated colors
	static func interpolate(
		startColor: PAL.Color,
		endColor: PAL.Color,
		count: Int,
		useOkLab: Bool = false
	) throws -> [PAL.Color] {
		if count == 0 { throw PAL.CommonError.tooFewColors }
		if count == 1 { return [.white] }

		if useOkLab {
			return try OkLab.palette(startColor, endColor, steps: count).colors
		}

		let c1 = try startColor.rgb()
		let c2 = try endColor.rgb()
		let step = 1.0 / Double(count - 1)

		let rdiff = (c2.rf - c1.rf) * step
		let gdiff = (c2.gf - c1.gf) * step
		let bdiff = (c2.bf - c1.bf) * step
		let adiff = (c2.af - c1.af) * step

		return (0 ..< count).map { index in
			let index = Double(index)
			return PAL.Color(
				rf: c1.rf + (index * rdiff),
				gf: c1.gf + (index * gdiff),
				bf: c1.bf + (index * bdiff),
				af: c1.af + (index * adiff)
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

public extension PAL.Color {
	/// Returns a color that is the result of THIS color applied on top of `backgroundColor`
	/// taking into account transparencies
	///
	/// [Wikipedia Entry defining the algorithm](https://en.wikipedia.org/wiki/Alpha_compositing)
	///   (Refer to the section "Analytical derivation of the over operator" for derivation of these formulas)
	///
	/// [Stack Overflow implementation here](https://stackoverflow.com/questions/726549/algorithm-for-additive-color-mixing-for-rgb-values)
	func applyOnTopOf(_ backgroundColor: PAL.Color) throws -> PAL.Color {
		if self.alpha.isEqual(to: 0.0, accuracy: 1e-6) {
			// The foreground color is opaque.
			return self
		}

		if self.alpha.isEqual(to: 1.0, accuracy: 1e-6) {
			// Foreground is completely clear
			return backgroundColor
		}

		let fg = try self.rgb()
		let bg = try backgroundColor.rgb()

		let rA = 1.0 - ((1.0 - fg.af) * (1.0 - bg.af))

		if rA.isEqual(to: 0.0, accuracy: 1e-6) {
			// Result is fully transparent
			return .clear
		}

		let rR = (fg.rf * fg.af / rA) + (bg.rf * bg.af * (1 - fg.af) / rA)
		let rG = (fg.gf * fg.af / rA) + (bg.gf * bg.af * (1 - fg.af) / rA)
		let rB = (fg.bf * fg.af / rA) + (bg.bf * bg.af * (1 - fg.af) / rA)

		return PAL.Color(rf: rR, gf: rG, bf: rB, af: rA)
	}
}
