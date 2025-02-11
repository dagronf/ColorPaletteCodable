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
	struct LAB: Equatable {
		public init(l: Float32, a: Float32, b: Float32, alpha: Float32 = 1.0) {
			self.l = l.clamped(to: 0 ... 100)
			self.a = a.clamped(to: -128.0 ... 128.0)
			self.b = b.clamped(to: -128.0 ... 128.0)
			self.alpha = a.clamped(to: 0.0 ... 1.0)
		}

		public static func == (lhs: PAL.Color.LAB, rhs: PAL.Color.LAB) -> Bool {
			return
				abs(lhs.l - rhs.l) < 0.005 &&
				abs(lhs.a - rhs.a) < 0.005 &&
				abs(lhs.b - rhs.b) < 0.005 &&
				abs(lhs.alpha - rhs.alpha) < 0.005
		}

		public let l: Float32
		public let a: Float32
		public let b: Float32
		public let alpha: Float32
	}
}
