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
	/// The components for a color with the CGColorSpace.XYZ colorspace
	struct XYZ {
		public init(xf: Double, yf: Double, zf: Double, af: Double = 1.0) {
			self.xf = xf
			self.yf = yf
			self.zf = zf
			self.af = af
		}

		public let xf: Double
		public let yf: Double
		public let zf: Double
		public let af: Double
	}
}

extension PAL.Color.XYZ: Equatable {
	public static func == (lhs: PAL.Color.XYZ, rhs: PAL.Color.XYZ) -> Bool {
		return
			abs(lhs.xf - rhs.xf) < 0.005 &&
			abs(lhs.yf - rhs.yf) < 0.005 &&
			abs(lhs.zf - rhs.zf) < 0.005 &&
			abs(lhs.af - rhs.af) < 0.005
	}
}
