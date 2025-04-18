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

public extension PAL.Color {
	/// Create a color from a kelvin temperature
	/// - Parameters:
	///   - kelvinTemperature: kelvin temperature value (1000.0 ... 40000.0)
	///   - name: The color name
	///   - colorType: The type of color
	init(kelvinTemperature: Double, name: String = "", colorType: PAL.ColorType = .global) throws {
		let k = try kelvinToRGB(kelvinTemperature)
		self.init(r255: k.r, g255: k.g, b255: k.b, name: name)
	}
}

public extension PAL.Palette {
	/// Create a palette containing a range of kelvin colors
	/// - Parameters:
	///   - kelvinRange: The range of kelvin temperatures
	///   - count: The number of colors in the palette
	///   - name: The palette name
	init(kelvinRange: ClosedRange<Double>, count: Int, name: String = "") throws {
		let step = ((kelvinRange.upperBound - kelvinRange.lowerBound) / (Double(count) - 1.0))
		let colors = try stride(from: kelvinRange.lowerBound, through: kelvinRange.upperBound, by: step).map {
			try PAL.Color(kelvinTemperature: $0)
		}
		self.init(colors: colors, name: name)
	}
}

public extension PAL.Gradient {
	/// Create a gradient containing a range of kelvin colors
	/// - Parameters:
	///   - kelvinRange: The range of kelvin temperatures
	///   - count: The number of gradient stops
	///   - name: The gradient name
	init(kelvinRange: ClosedRange<Double>, count: Int, name: String = "") throws {
		let palette = try PAL.Palette(kelvinRange: kelvinRange, count: count, name: name)
		self.init(palette: palette, name: name)
	}
}
