//
//  PAL+ColorStructs.swift
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

public extension PAL.Color {
	/// The components for a color with a CGColorSpace.RGB colorspace
	struct RGB: Equatable {
		public init(r: Float32, g: Float32, b: Float32, a: Float32 = 1.0) {
			self.r = r.clamped(to: 0.0 ... 1.0)
			self.g = g.clamped(to: 0.0 ... 1.0)
			self.b = b.clamped(to: 0.0 ... 1.0)
			self.a = a.clamped(to: 0.0 ... 1.0)
		}

		/// Create RGBA components from an RGB(A) hex string
		public init(hexString: String) throws {
			var string = hexString.lowercased()
			if hexString.hasPrefix("#") {
				string = String(string.dropFirst())
			}
			switch string.count {
			case 3:
				string += "f"
				fallthrough
			case 4:
				let chars = Array(string)
				let red = chars[0]
				let green = chars[1]
				let blue = chars[2]
				let alpha = chars[3]
				string = "\(red)\(red)\(green)\(green)\(blue)\(blue)\(alpha)\(alpha)"
			case 6:
				string += "ff"
			case 8:
				break
			default:
				throw PAL.CommonError.invalidRGBHexString(hexString)
			}

			guard let rgba = Double("0x" + string)
				.flatMap( {UInt32(exactly: $0) } )
			else {
				throw PAL.CommonError.invalidRGBHexString(hexString)
			}
			let red = Float32((rgba & 0xFF00_0000) >> 24) / 255.0
			let green = Float32((rgba & 0x00FF_0000) >> 16) / 255.0
			let blue = Float32((rgba & 0x0000_FF00) >> 8) / 255.0
			let alpha = Float32((rgba & 0x0000_00FF) >> 0) / 255.0

			self.r = red
			self.g = green
			self.b = blue
			self.a = alpha
		}

		public static func == (lhs: PAL.Color.RGB, rhs: PAL.Color.RGB) -> Bool {
			return
				abs(lhs.r - rhs.r) < 0.005 &&
				abs(lhs.g - rhs.g) < 0.005 &&
				abs(lhs.b - rhs.b) < 0.005 &&
				abs(lhs.a - rhs.a) < 0.005
		}

		public let r: Float32
		public let g: Float32
		public let b: Float32
		public let a: Float32
	}
}

public extension PAL.Color {
	/// The components for an HSB color
	struct HSB {
		public init(h: Float32, s: Float32, b: Float32, a: Float32 = 1.0) {
			self.h = h.clamped(to: 0...1)
			self.s = s.clamped(to: 0...1)
			self.b = b.clamped(to: 0...1)
			self.a = a.clamped(to: 0...1)
		}

		public init(h360: Float32, s100: Float32, b100: Float32, a: Float32 = 1.0) {
			self.h = (h360 / 360.0).clamped(to: 0...1)
			self.s = (s100 / 100.0).clamped(to: 0...1)
			self.b = (b100 / 100.0).clamped(to: 0...1)
			self.a = a.clamped(to: 0...1)
		}

		public static func == (lhs: PAL.Color.HSB, rhs: PAL.Color.HSB) -> Bool {
			return
				abs(lhs.h - rhs.h) < 0.005 &&
				abs(lhs.s - rhs.s) < 0.005 &&
				abs(lhs.b - rhs.b) < 0.005 &&
				abs(lhs.a - rhs.a) < 0.005
		}

		/// Hue value as a value in the range 0 ... 1
		public let h: Float32
		/// Hue value as a value in the range 0 ... 360
		public var h360: Int { Int(h * 360.0).clamped(to: 0 ... 360) }
		/// Saturation value as a value in the range 0 ... 1
		public let s: Float32
		/// Saturation value as a value in the range 0 ... 100
		public var s100: Int { Int(s * 100.0).clamped(to: 0 ... 100) }
		/// Brightness value as a value in the range 0 ... 1
		public let b: Float32
		/// Brightness value as a value in the range 0 ... 100
		public var b100: Int { Int(b * 100.0).clamped(to: 0 ... 100) }
		/// Alpha value as a value in the range 0 ... 1
		public let a: Float32
	}
}

public extension PAL.Color {
	/// The components for a color with the CGColorSpace.CMYK colorspace
	struct CMYK: Equatable {
		public init(c: Float32, m: Float32, y: Float32, k: Float32, a: Float32 = 1.0) {
			self.c = c.clamped(to: 0.0 ... 1.0)
			self.m = m.clamped(to: 0.0 ... 1.0)
			self.y = y.clamped(to: 0.0 ... 1.0)
			self.k = k.clamped(to: 0.0 ... 1.0)
			self.a = a.clamped(to: 0.0 ... 1.0)
		}

		public static func == (lhs: PAL.Color.CMYK, rhs: PAL.Color.CMYK) -> Bool {
			return
				abs(lhs.c - rhs.c) < 0.005 &&
				abs(lhs.m - rhs.m) < 0.005 &&
				abs(lhs.y - rhs.y) < 0.005 &&
				abs(lhs.k - rhs.k) < 0.005 &&
				abs(lhs.a - rhs.a) < 0.005
		}

		public let c: Float32
		public let m: Float32
		public let y: Float32
		public let k: Float32
		public let a: Float32
	}
}

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
