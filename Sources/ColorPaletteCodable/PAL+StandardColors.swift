//
//  PAL+StandardColors.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

// A set of standard predefined colors

public extension PAL.Color {
	/// RGB Black color
	static let black = PAL.Color.rgb(0.0, 0.0, 0.0, 1.0)
	/// RGB Clear color
	static let clear = PAL.Color.rgb(0.0, 0.0, 0.0, 0.0)
	/// RGB White color
	static let white = PAL.Color.rgb(1.0, 1.0, 1.0, 1.0)

	/// RGB Red color
	static let red   = PAL.Color.rgb(1.0, 0.0, 0.0, 1.0)
	/// RGB Green color
	static let green = PAL.Color.rgb(0.0, 1.0, 0.0, 1.0)
	/// RGB Blue color
	static let blue  = PAL.Color.rgb(0.0, 0.0, 1.0, 1.0)

	/// CMYK cyan color
	static let cyan    = PAL.Color.cmyk(1.0, 0.0, 0.0, 0.0, 1.0)
	/// CMYK magenta color
	static let magenta = PAL.Color.cmyk(0.0, 1.0, 0.0, 0.0, 1.0)
	/// CMYK yellow color
	static let yellow  = PAL.Color.cmyk(0.0, 0.0, 1.0, 0.0, 1.0)
}
