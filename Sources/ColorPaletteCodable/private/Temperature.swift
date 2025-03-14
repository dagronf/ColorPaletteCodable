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

/// Get a RGB tuple from a kelvin temperature
/// - Parameter kelvinTemperature: The kelvin temperature
/// - Returns: A r255, g255, b255 tuple
///
/// Based on Neil Bartlett's implementation of Mitchell Charity's color temperature work
///
/// Original data and calculations by Mitchell Charity
/// [http://www.vendian.org/mncharity/dir3/blackbody/](http://www.vendian.org/mncharity/dir3/blackbody/)
///
/// References :-
///
/// [https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html](https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html)
///
/// [https://andi-siess.de/rgb-to-color-temperature/](https://andi-siess.de/rgb-to-color-temperature/)
func kelvinToRGB(_ kelvinTemperature: Double) throws -> (r: UInt8, g: UInt8, b: UInt8) {
	let percentK = kelvinTemperature.clamped(to: 1000.0 ... 40000.0) / 100.0

	// R
	let r: Double
	if percentK <= 66 {
		r = 255
	}
	else {
		r = (329.698727446 * pow(percentK - 60, -0.1332047592))
	}

	// G
	let g: Double
	if percentK <= 66 {
		g = (99.4708025861 * log(percentK) - 161.1195681661)
	}
	else {
		g = (288.1221695283 * pow(percentK - 60, -0.0755148492))
	}

	// B
	let b: Double
	if percentK > 66 {
		b = 255
	}
	else if percentK <= 19 {
		b = 0
	}
	else {
		b = 138.5177312231 * log(percentK - 10) - 305.0447927307
	}

	return (
		r: UInt8(r.clamped(to: 0 ... 255)),
		g: UInt8(g.clamped(to: 0 ... 255)),
		b: UInt8(b.clamped(to: 0 ... 255))
	)
}
