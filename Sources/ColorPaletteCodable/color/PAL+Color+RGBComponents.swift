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
	/// Color RGBA (0 ... 1) component container
	struct RGBAComponents {
		let r: Double
		let g: Double
		let b: Double
		let a: Double
		@usableFromInline init(r: Double, g: Double, b: Double, a: Double) {
			self.r = r.unitClamped()
			self.g = g.unitClamped()
			self.b = b.unitClamped()
			self.a = a.unitClamped()
		}

		/// Map from (0 ... 1) -> (0 ... 255) components
		@usableFromInline func swap() -> RGBA255Components {
			RGBA255Components(
				r: _f2u(self.r),
				g: _f2u(self.g),
				b: _f2u(self.b),
				a: _f2u(self.a)
			)
		}
	}

	/// Color RGBA (0 ... 255)
	struct RGBA255Components {
		let r: UInt8
		let g: UInt8
		let b: UInt8
		let a: UInt8
		@usableFromInline init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
			self.r = r
			self.g = g
			self.b = b
			self.a = a
		}
		/// Map from (0 ... 255) -> (0 ... 1) components
		@usableFromInline func swap() -> RGBAComponents {
			RGBAComponents(r: _u2f(self.r), g: _u2f(self.g), b: _u2f(self.b), a: _u2f(self.a))
		}
	}
}

public extension PAL.Color {
	/// RGBA representation (0 ... 1) for the color
	///
	/// Converts the colorspace as necessary
	@inlinable func rgbaComponents() throws -> RGBAComponents {
		let c = try self.converted(to: .RGB)
		return .init(r: Double(c._r), g: Double(c._g), b: Double(c._b), a: Double(c.alpha))
	}

	/// Returns the RGBA255 components
	@inlinable func rgba255Components() throws -> RGBA255Components {
		let c = try self.converted(to: .RGB)
		return .init(r: _f2u(c._r), g: _f2u(c._g), b: _f2u(c._b), a: _f2u(c.alpha))
	}
}
