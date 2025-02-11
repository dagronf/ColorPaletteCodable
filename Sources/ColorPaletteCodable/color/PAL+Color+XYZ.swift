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
	struct XYZ: Equatable {
		public init(x: Float32, y: Float32, z: Float32, a: Float32 = 1.0) {
			self.x = x.clamped(to: 0.0 ... 1.0)
			self.y = y.clamped(to: 0.0 ... 1.0)
			self.z = z.clamped(to: 0.0 ... 1.0)
			self.a = a.clamped(to: 0.0 ... 1.0)
		}

		public static func == (lhs: PAL.Color.XYZ, rhs: PAL.Color.XYZ) -> Bool {
			return
				abs(lhs.x - rhs.x) < 0.005 &&
				abs(lhs.y - rhs.y) < 0.005 &&
				abs(lhs.z - rhs.z) < 0.005 &&
				abs(lhs.a - rhs.a) < 0.005
		}

		public let x: Float32
		public let y: Float32
		public let z: Float32
		public let a: Float32
	}
}
