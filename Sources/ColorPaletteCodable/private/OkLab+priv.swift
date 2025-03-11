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

// References:
//   https://bottosson.github.io/posts/oklab/#oklab-implementations
//   https://aras-p.info/blog/2022/03/11/Optimizing-Oklab-gradients/
//   https://raphlinus.github.io/color/2021/01/18/oklab-critique.html

extension OkLab {
	/// Create a color by mixing two colors in the OkLab colorspace
	/// - Parameters:
	///   - c1: First color
	///   - c2: Second color
	///   - t: The fractional distance between the two colors
	/// - Returns: Interpolated color
	static func mix(_ c1: Vec3<Float32>, _ c2: Vec3<Float32>, t: Float32) -> Vec3<Float32> {
		let omix = lerp(sRGB_to_OkLab(c1.unitClamped), sRGB_to_OkLab(c2.unitClamped), t: t.unitClamped)
		return OkLab_to_sRGB(omix).unitClamped
	}

	/// Create a palette by mixing two sRGB colors evenly in steps
	/// - Parameters:
	///   - c1: First color
	///   - c2: Second color
	///   - name: The gradient name
	///   - steps: The number of palette entries to create (including start and end colors)
	/// - Returns: A palette
	internal static func palette(
		_ c1: Vec3<Float32>,
		_ c2: Vec3<Float32>,
		steps: Int,
		name: String = ""
	) -> PAL.Palette {
		assert(steps > 1)
		let colors = stride(from: 0, through: 1, by: 1.0 / (Float32(steps) - 1)).map {
			PAL.Color(sRGB: OkLab.mix(c1, c2, t: $0))
		}
		return PAL.Palette(colors: colors, name: name)
	}
}

// MARK: - Private implementations

private let _cubed = Vec3<Float32>(3, 3, 3)

internal func sRGB_to_OkLab(_ c: Vec3<Float32>) -> Vec3<Float32> {
	Linear_sRGB_to_OkLab_Ref(sRGB_to_Linear(c))
}

internal func OkLab_to_sRGB(_ c: Vec3<Float32>) -> Vec3<Float32> {
	linear_to_sRGB(OkLab_to_Linear_sRGB_Ref(c))
}

private func sRGB_Oklab_mix(_ c1: Vec3<Float32>, _ c2: Vec3<Float32>, t: Float32) -> Vec3<Float32> {
	let o1 = sRGB_to_OkLab(c1)
	let o2 = sRGB_to_OkLab(c2)
	let m = lerp(o1, o2, t: t)
	return OkLab_to_sRGB(m)
}

private func Linear_sRGB_to_OkLab_Ref(_ c: Vec3<Float32>) -> Vec3<Float32> {
	let lms = Vec3<Float32>(
		0.4122214708 * c.x + 0.5363325363 * c.y + 0.0514459929 * c.z,
		0.2119034982 * c.x + 0.6806995451 * c.y + 0.1073969566 * c.z,
		0.0883024619 * c.x + 0.2817188376 * c.y + 0.6299787005 * c.z
	)

	let lms_ = Vec3<Float32>(cbrt(lms.x), cbrt(lms.y), cbrt(lms.z))

	return Vec3<Float32>(
		0.2104542553 * lms_.x + 0.7936177850 * lms_.y - 0.0040720468 * lms_.z,
		1.9779984951 * lms_.x - 2.4285922050 * lms_.y + 0.4505937099 * lms_.z,
		0.0259040371 * lms_.x + 0.7827717662 * lms_.y - 0.8086757660 * lms_.z
	)
}

private func OkLab_to_Linear_sRGB_Ref(_ c: Vec3<Float32>) -> Vec3<Float32> {
	let lms_ = Vec3<Float32>(
		 c.x + 0.3963377774 * c.y + 0.2158037573 * c.z,
		 c.x - 0.1055613458 * c.y - 0.0638541728 * c.z,
		 c.x - 0.0894841775 * c.y - 1.2914855480 * c.z
	 )

	let lms = Vec3<Float32>(pow(lms_.x, 3), pow(lms_.y, 3), pow(lms_.z, 3))

	return Vec3<Float32>(
		+4.0767416621 * lms.x - 3.3077115913 * lms.y + 0.2309699292 * lms.z,
		-1.2684380046 * lms.x + 2.6097574011 * lms.y - 0.3413193965 * lms.z,
		-0.0041960863 * lms.x - 0.7034186147 * lms.y + 1.7076147010 * lms.z
	)
}

private func sRGB_to_Linear(_ value: Float32) -> Float32 {
	if value < 0.04045 {
		return value / 12.92
	}
	else {
		return pow((value + 0.055) / 1.055, 2.4)
	}
}

private func sRGB_to_Linear(_ value: Vec3<Float32>) -> Vec3<Float32> {
	Vec3<Float32>(sRGB_to_Linear(value.x), sRGB_to_Linear(value.y), sRGB_to_Linear(value.z))
}

private func linear_to_sRGB(_ value: Float32) -> Float32 {
	if value < 0.0031308 {
		return 12.92 * value
	}
	else {
		return 1.055 * pow(value, 0.41666) - 0.055
	}
}

private func linear_to_sRGB(_ v: Vec3<Float32>) -> Vec3<Float32> {
	Vec3<Float32>(linear_to_sRGB(v.x), linear_to_sRGB(v.y), linear_to_sRGB(v.z))
}
