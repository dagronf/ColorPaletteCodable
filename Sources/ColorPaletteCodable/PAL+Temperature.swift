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

import Foundation

public extension PAL.Color {
	/// Create a color from a kelvin temperature
	/// - Parameters:
	///   - name: The color name
	///   - kelvinTemperature: kelvin temperature value (1000.0 ... 40000.0)
	///   - colorType: The type of color
	init(name: String = "", kelvinTemperature: Float32, colorType: PAL.ColorType = .global) throws {
		let k = try kelvinToRGB(kelvinTemperature)
		try self.init(name: name, r255: k.r, g255: k.g, b255: k.b)
	}
}

public extension PAL.Palette {
	/// Create a palette containing a range of kelvin colors
	/// - Parameters:
	///   - name: The palette name
	///   - kelvinRange: The range of kelvin temperatures
	///   - count: The number of colors in the palette
	init(named name: String = "", kelvinRange: ClosedRange<Float32>, count: Int) throws {
		let step = ((kelvinRange.upperBound - kelvinRange.lowerBound) / (Float32(count) - 1.0))
		let colors = try stride(from: kelvinRange.lowerBound, through: kelvinRange.upperBound, by: step).map {
			try PAL.Color(kelvinTemperature: $0)
		}
		self.init(name: name, colors: colors)
	}
}

public extension PAL.Gradient {
	/// Create a gradient containing a range of kelvin colors
	/// - Parameters:
	///   - name: The gradient name
	///   - kelvinRange: The range of kelvin temperatures
	///   - count: The number of gradient stops
	init(named name: String = "", kelvinRange: ClosedRange<Float32>, count: Int) throws {
		let palette = try PAL.Palette(named: name, kelvinRange: kelvinRange, count: count)
		self.init(name: name, palette: palette)
	}
}
