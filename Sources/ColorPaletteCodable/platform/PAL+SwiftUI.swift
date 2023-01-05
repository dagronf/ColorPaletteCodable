//
//  PAL+SwiftUI.swift
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

// SwiftUI support routines

import Foundation

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension PAL.Color {
	/// Create a color from a SwiftUI Color
	/// - Parameters:
	///   - name: The color's name
	///   - color: The SwiftUI color
	///   - colorType: The color type
	init(name: String = "", _ color: SwiftUI.Color, colorType: PAL.ColorType = .global) throws {
		guard let cgColor = color.cgColor else { throw PAL.CommonError.unsupportedCGColorType }
		try self.init(cgColor: cgColor, name: name, colorType: colorType)
	}

	/// Extract a SwiftUI color from this color
	@inlinable var SwiftUIColor: Color? {
#if swift(<5.5)
		return unwrapping(self.cgColor) { SwiftUI.Color($0) }
#else
		return unwrapping(self.cgColor) { SwiftUI.Color(cgColor: $0) }
#endif
	}
}

@available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension PAL.Image {
	/// Generate a SwiftUI Image of the list of colors. Useful for drag item images etc.
	/// - Parameters:
	///   - colors: The array of colors to include in the resulting image
	///   - size: The point size of the resulting image
	///   - cornerRadius: The corner radius
	///   - scale: The scale to use when creating the image
	/// - Returns: The created CGImage, or nil if an error occurred
	static func SwiftUIImage(colors: [PAL.Color], size: CGSize, cornerRadius: CGFloat = 4, scale: CGFloat = 2) throws -> SwiftUI.Image {
		let image = try Self.Image(colors: colors, size: size, cornerRadius: cornerRadius, scale: scale)
		#if os(macOS)
		return SwiftUI.Image(nsImage: image)
		#else
		return SwiftUI.Image(uiImage: image)
		#endif
	}
}

#endif
