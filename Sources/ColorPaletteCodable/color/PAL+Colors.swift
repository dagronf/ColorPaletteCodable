//
//  Copyright © 2024 Darren Ford. All rights reserved.
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

// Functions relating to colors

public extension PAL {
	/// An array of colors
	typealias Colors = [PAL.Color]
}

public extension PAL.Colors {
	/// Create a color array by interpolating between two colors
	///   - firstColor: The first (starting) color for the palette
	///   - lastColor: The second (ending) color for the palette
	///   - count: Number of colors to generate
	static func interpolate(_ firstColor: PAL.Color, _ lastColor: PAL.Color, count: Int) throws -> PAL.Colors {
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

	/// Create a color array by interpolating between two colors
	///   - firstColor: The first (starting) color for the palette
	///   - lastColor: The second (ending) color for the palette
	///   - count: Number of colors to generate
	static func interpolateToClear(_ c0: PAL.Color, count: Int) throws -> PAL.Colors {
		let a1: Double = Double(c0.alpha)
		let a2: Double = 0.0
		let step = (a2 - a1) / Double(count - 1)
		let comps = try c0.rgbaComponents()
		return try stride(from: a1, through: a2, by: step).map { value in
			try PAL.Color(
				rf: Float32(comps.r),
				gf: Float32(comps.g),
				bf: Float32(comps.b),
				af: Float32(value)
			)
		}
	}

	/// Return evenly spaced grayscale colors between black and white
	/// - Parameter count: The number of colors to return
	@inlinable
	static func blackToWhite(count: Int) throws -> PAL.Colors {
		try Self.interpolate(.black, .white, count: count)
	}

	@inlinable
	static func colorToClear(_ color: PAL.Color, count: Int) throws -> PAL.Colors {
		try Self.interpolateToClear(color, count: count)
	}
}

// MARK: - Gradient

public extension PAL.Colors {
	/// Return a gradient containing these colors evenly spaced
	/// - Parameters:
	///   - name: The name for the gradient (optional)
	/// - Returns: A new gradient
	@inlinable
	func gradient(named name: String? = nil) -> PAL.Gradient {
		PAL.Gradient(name: name, colors: self)
	}
}
