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

// Implementations for the OkLab perceptual colorspace

// References:
//   https://bottosson.github.io/posts/oklab/#oklab-implementations
//   https://aras-p.info/blog/2022/03/11/Optimizing-Oklab-gradients/
//   https://raphlinus.github.io/color/2021/01/18/oklab-critique.html

import Foundation

/// OkLab routines
public struct OkLab { }

// MARK: - Color routines

public extension OkLab {
	/// Create a color by mixing two colors in the OkLab colorspace
	/// - Parameters:
	///   - name: The color name
	///   - c1: First color
	///   - c2: Second color
	///   - t: The fractional distance between the two colors
	/// - Returns: Interpolated color
	static func mix(name: String = "", _ c1: PAL.Color, _ c2: PAL.Color, t: Float32) throws -> PAL.Color {
		let cr1 = try c1.converted(to: .RGB).rgbValuesVec3()
		let cr2 = try c2.converted(to: .RGB).rgbValuesVec3()
		return PAL.Color(name: name, sRGB: OkLab.mix(cr1, cr2, t: t.unitClamped))
	}
}

// MARK: - Palette routines

public extension OkLab {
	/// Create a palette by mixing two colors evenly in steps
	/// - Parameters:
	///   - name: The color name
	///   - c1: First color
	///   - c2: Second color
	///   - steps: The number of palette entries to create (including start and end colors)
	/// - Returns: A palette
	static func palette(name: String = "", _ c1: PAL.Color, _ c2: PAL.Color, steps: Int) throws -> PAL.Palette {
		assert(steps > 1)
		let cr1 = try c1.rgb().vec3  // converted(to: .RGB).rgbValues().vec3
		let cr2 = try c2.rgb().vec3  //.converted(to: .RGB).rgbValues().vec3
		return OkLab.palette(name: name, cr1, cr2, steps: steps)
	}
}

// MARK: - Gradient routines

public extension OkLab {
	/// Create a gradient using colors mapped to the OkLab color space
	/// - Parameters:
	///   - name: The gradient name
	///   - startColor: Starting color for the gradient
	///   - endColor: Ending color for the gradient
	///   - stopCount: The number of stops to include in the gradient
	///   - useOkLab: If true, use OkLab colorspace when generating colors
	/// - Returns: A gradient
	static func gradient(
		name: String = "",
		_ startColor: PAL.Color,
		_ endColor: PAL.Color,
		stopCount: Int,
		useOkLab: Bool = false
	) throws -> PAL.Gradient {
		assert(stopCount > 1)
		let pal = try PAL.Palette(startColor: startColor, endColor: endColor, count: stopCount, useOkLab: useOkLab)
		return PAL.Gradient(name: name, palette: pal)
	}
}
