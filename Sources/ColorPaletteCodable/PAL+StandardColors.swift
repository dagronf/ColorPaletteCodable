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

// A set of standard predefined colors

public extension PAL.Color {
	/// RGB Black color
	static let black = rgbf(0.0, 0.0, 0.0, 1.0)
	/// RGB Clear color
	static let clear = rgbf(0.0, 0.0, 0.0, 0.0)
	/// RGB White color
	static let white = rgbf(1.0, 1.0, 1.0, 1.0)

	/// RGB Red color
	static let red   = rgbf(1.0, 0.0, 0.0, 1.0)
	/// RGB Green color
	static let green = rgbf(0.0, 1.0, 0.0, 1.0)
	/// RGB Blue color
	static let blue  = rgbf(0.0, 0.0, 1.0, 1.0)

	/// CMYK cyan color
	static let cyan    = cmykf(1.0, 0.0, 0.0, 0.0, 1.0)
	/// CMYK magenta color
	static let magenta = cmykf(0.0, 1.0, 0.0, 0.0, 1.0)
	/// CMYK yellow color
	static let yellow  = cmykf(0.0, 0.0, 1.0, 0.0, 1.0)
	/// CMYK [key color](https://www.jukeboxprint.com/blog/understanding-K-in-CMYK)
	static let key     = cmykf(0.0, 0.0, 0.0, 1.0, 1.0)

	/// Basic pink color
	static let pink    = rgbf(1, 0.251, 0.505)
}
