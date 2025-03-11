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

// MARK: - Global creators

/// Create a color from a gray component
/// - Parameters:
///   - white: The blackness component (0.0 ... 1.0)
///   - alpha: The alpha component (0.0 ... 1.0)
///   - name: The name for the color
///   - colorType: The type of color
/// - Returns: A color
public func grayf(
	_ white: Float32,
	_ alpha: Float32 = 1,
	name: String = "",
	colorType: PAL.ColorType = .global
) -> PAL.Color {
	PAL.Color(white: white, alpha: alpha, name: name, colorType: colorType)
}

/// Create a color from gray components
/// - Parameters:
///   - white: The blackness component (0 ... 255)
///   - alpha: The alpha component (0 ... 255)
///   - name: The name for the color
///   - colorType: The type of color
/// - Returns: A color
public func gray255(
	_ white: UInt8,
	_ alpha: UInt8 = 255,
	name: String = "",
	colorType: PAL.ColorType = .global
) -> PAL.Color {
	PAL.Color(white255: white, alpha255: alpha, name: name, colorType: colorType)
}

// MARK: - Basic gray structure

public extension PAL.Color {
	/// Grau color components
	struct Gray: Equatable {
		/// Create
		/// - Parameters:
		///   - grayf: Gray component (0.0 ... 1.0)
		///   - af: Alpha component (0.0 ... 1.0)
		public init(grayf: Float32, af: Float32 = 1.0) {
			self.grayf = grayf
			self.af = af
		}
		/// Gray component (0.0 ... 1.0)
		public let grayf: Float32
		/// Gray component (0 ... 255)
		public var grey255: UInt8 { UInt8(self.grayf * 255.0) }
		/// Alpha component (0.0 ... 1.0)
		public let af: Float32
		/// Alpha component (0 ... 255)
		public var a255: UInt8 { UInt8(self.af * 255.0) }
	}
}

// MARK: - Color grey support

public extension PAL.Color {
	/// Create a gray color
	/// - Parameters:
	///   - white: white component (0.0 ... 1.0)
	///   - alpha: The alpha component (0.0 ... 1.0)
	///   - name: The color name
	///   - colorType: The type of color
	init(white: Float32, alpha: Float32 = 1.0, name: String = "", colorType: PAL.ColorType = .global) {
		self.name = name
		self.colorSpace = .Gray
		self.colorComponents = [white.unitClamped]
		self.alpha = alpha.unitClamped
		self.colorType = colorType
	}

	/// Create a gray color
	/// - Parameters:
	///   - white255: white component (0 ... 255)
	///   - alpha255: alpha component (0 ... 255)
	///   - name: The color name
	///   - colorType: The type of color
	init(white255: UInt8, alpha255: UInt8 = 255, name: String = "", colorType: PAL.ColorType = .global) {
		self.init(
			white: Float32(white255) / 255.0,
			alpha: Float32(alpha255) / 255.0,
			name: name,
			colorType: colorType
		)
	}

	/// Create a gray color
	/// - Parameters:
	///   - color: The color components
	///   - name: The color name
	///   - colorType: The type of color
	init(color: PAL.Color.Gray, name: String = "", colorType: PAL.ColorType = .global) {
		self.init(white: color.grayf, alpha: color.af, name: name, colorType: colorType)
	}

	/// Returns the gray components for this color
	/// - Returns: Gray components
	func gray() throws -> PAL.Color.Gray {
		let gray = try self.converted(to: .Gray)
		return PAL.Color.Gray(grayf: gray._l, af: self.alpha)
	}

	// Unsafe Gray retrieval. No checks or validation are performed
	@inlinable internal var _l: Float32 { colorComponents[0] }
}
