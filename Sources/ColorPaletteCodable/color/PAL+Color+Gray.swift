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
	/// Create a gray color
	/// - Parameters:
	///   - name: The color name
	///   - white: white component (0.0 ... 1.0)
	///   - alpha: The alpha component (0.0 ... 1.0)
	///   - colorType: The type of color
	init(name: String = "", white: Float32, alpha: Float32 = 1.0, colorType: PAL.ColorType = .global) {
		self.name = name
		self.colorSpace = .Gray
		self.colorComponents = [white.unitClamped]
		self.alpha = alpha.unitClamped
		self.colorType = colorType
	}

	/// Create a gray color
	/// - Parameters:
	///   - name: The color name
	///   - white255: white component (0 ... 255)
	///   - alpha255: alpha component (0 ... 255)
	///   - colorType: The type of color
	init(name: String = "", white255: UInt8, alpha255: UInt8 = 255, colorType: PAL.ColorType = .global) {
		self.init(
			name: name,
			white: Float32(white255) / 255.0,
			alpha: Float32(alpha255) / 255.0,
			colorType: colorType
		)
	}
}

public extension PAL.Color {
	/// Create a color from a gray component
	/// - Parameters:
	///   - name: The name for the color
	///   - white: The blackness component (0.0 ... 1.0)
	///   - alpha: The alpha component (0.0 ... 1.0)
	///   - colorType: The type of color
	/// - Returns: A color
	static func gray(
		name: String = "",
		_ white: Float32,
		_ alpha: Float32 = 1,
		colorType: PAL.ColorType = .global
	) -> PAL.Color {
		PAL.Color(name: name, white: white, alpha: alpha, colorType: colorType)
	}
}

// MARK: Gray compoments

// Unsafe Gray retrieval. No checks or validation are performed
internal extension PAL.Color {
	@inlinable var _l: Float32 { colorComponents[0] }
}
