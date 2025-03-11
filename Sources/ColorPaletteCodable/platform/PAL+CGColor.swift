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
import CoreGraphics

// CGColor conveniences

public extension CGColor {
	/// Create a CGColor from a hex formatted string
	/// - Parameters:
	///   - hexString: The hex string
	///   - format: The expected color ordering
	static func fromHexString(_ hexString: String, format: PAL.ColorByteFormat) throws -> CGColor {
		let rgb = try PAL.Color.RGB(hexString, format: format)
		if #available(macOS 10.15, *) {
			return CGColor(srgbRed: CGFloat(rgb.rf), green: CGFloat(rgb.gf), blue: CGFloat(rgb.bf), alpha: CGFloat(rgb.af))
		} else {
			return CGColor(red: CGFloat(rgb.rf), green: CGFloat(rgb.gf), blue: CGFloat(rgb.bf), alpha: CGFloat(rgb.af))
		}
	}

	/// Create a PAL.Color from a CGColor
	/// - Parameters:
	///   - name: The color's name
	///   - colorType: The color's type
	/// - Returns: A PAL.Color representation of the image
	@inlinable func palColor(name: String = "", colorType: PAL.ColorType = .global) throws -> PAL.Color {
		try PAL.Color(name: name, color: self, colorType: colorType)
	}
}
