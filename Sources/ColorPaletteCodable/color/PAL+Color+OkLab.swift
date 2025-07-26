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
	///   - c1: First color
	///   - c2: Second color
	///   - t: The fractional distance between the two colors
	///   - name: The color name
	/// - Returns: Interpolated color
	static func mix(_ c1: PAL.Color, _ c2: PAL.Color, t: Double, name: String = "") throws -> PAL.Color {
		let cr1 = try c1.converted(to: .RGB).rgbValuesSIMD3()
		let cr2 = try c2.converted(to: .RGB).rgbValuesSIMD3()
		return PAL.Color(sRGB: OkLab.mix(cr1, cr2, t: t.unitClamped), name: name)
	}
}

// MARK: - Palette routines

public extension OkLab {
	/// Create a palette by mixing two colors evenly in steps
	/// - Parameters:
	///   - c1: First color
	///   - c2: Second color
	///   - steps: The number of palette entries to create (including start and end colors)
	///   - name: The color name
	/// - Returns: A palette
	static func palette(_ c1: PAL.Color, _ c2: PAL.Color, steps: Int, name: String = "") throws -> PAL.Palette {
		assert(steps > 1)
		let cr1 = try c1.rgb().simd3
		let cr2 = try c2.rgb().simd3
		return OkLab.palette(cr1, cr2, steps: steps, name: name)
	}
}

// MARK: - Gradient routines

public extension OkLab {
	/// Create a gradient using colors mapped to the OkLab color space
	/// - Parameters:
	///   - startColor: Starting color for the gradient
	///   - endColor: Ending color for the gradient
	///   - stopCount: The number of stops to include in the gradient
	///   - useOkLab: If true, use OkLab colorspace when generating colors
	///   - name: The gradient name
	/// - Returns: A gradient
	static func gradient(
		_ startColor: PAL.Color,
		_ endColor: PAL.Color,
		stopCount: Int,
		useOkLab: Bool = false,
		name: String = ""
	) throws -> PAL.Gradient {
		assert(stopCount > 1)
		let pal = try PAL.Palette(startColor: startColor, endColor: endColor, count: stopCount, useOkLab: useOkLab)
		return PAL.Gradient(palette: pal, name: name)
	}
}
