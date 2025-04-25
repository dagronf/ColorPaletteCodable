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
	/// The components for a color with the CGColorSpace.LAB colorspace
	struct LAB {
		/// Create an L*a*b* color
		/// - Parameters:
		///   - l100: Lightness (0 ... 100)
		///   - a128: Red/Green Value (-128 ... 128)
		///   - b128: Blue/Yellow Value (-128 ... 128)
		///   - af: Alpha value (0.0 ... 1.0)
		public init(l100: Double, a128: Double, b128: Double, af: Double = 1.0) {
			self.lf = l100.clamped(to: 0 ... 100)
			self.af = a128.clamped(to: -128.0 ... 128.0)
			self.bf = b128.clamped(to: -128.0 ... 128.0)
			self.alphaf = af.clamped(to: 0.0 ... 1.0)
		}

		/// L\* - Lightness (0 ... 100)
		public let lf: Double
		/// a\* - Red/Green Value (-128 ... 128)
		public let af: Double
		/// b\* - Blue/Yellow Value  (-128 ... 128)
		public let bf: Double
		/// Alpha component (0.0 ... 1.0)
		public let alphaf: Double
	}
}

extension PAL.Color.LAB: Equatable {
	public static func == (lhs: PAL.Color.LAB, rhs: PAL.Color.LAB) -> Bool {
		return
			abs(lhs.lf - rhs.lf) < 0.005 &&
			abs(lhs.af - rhs.af) < 0.005 &&
			abs(lhs.bf - rhs.bf) < 0.005 &&
			abs(lhs.alphaf - rhs.alphaf) < 0.005
	}
}

public extension PAL.Color.LAB {
	/// Convert LAB color to RGB
	func rgb() -> PAL.Color.RGB {
		NaiveConversions.LAB2RGB(self)
	}
}

public extension PAL.Color {
	/// Get the Lab values for this color
	/// - Returns: A Lab representation
	func lab() throws -> PAL.Color.LAB {
		if self.colorSpace == .LAB {
			return PAL.Color.LAB(
				l100: self.colorComponents[0],
				a128: self.colorComponents[1],
				b128: self.colorComponents[2],
				af: self.alpha
			)
		}

		// Convert the color to RGB first, then through to Lab
		return NaiveConversions.RGB2LAB(try self.rgb())
	}

	/// Create a color from a PAL.Color.LAB color value
	/// - Parameters:
	///   - color: The LAB represention of the color
	///   - name: The color name
	init(color: PAL.Color.LAB, name: String = "", colorType: PAL.ColorType = .global) throws {
		self.colorSpace = .LAB
		self.colorComponents = [color.lf, color.af, color.bf]
		self.name = name
		self.alpha = 1.0
		self.colorType = colorType
	}
}
