//
//  PAL+macOS.swift
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

// macOS related functions

#if os(macOS)

import AppKit

public extension PAL.Color {
	/// Create a color from an NSColor instance
	///
	/// Throws an error if the CGColor cannot be represented as a PAL.Color object
	init(color: NSColor, name: String = "", colorType: PAL.ColorType = .global) throws {
		try self.init(cgColor: color.cgColor, name: name, colorType: colorType)
	}
	
	/// Returns an NSColor representation of this color
	@inlinable var nsColor: NSColor? {
		return self.cgColor.unwrapping { NSColor(cgColor: $0) }
	}
}

public extension PAL.Image {
	/// Generate an NSImage of the list of colors. Useful for drag item images etc.
	/// - Parameters:
	///   - colors: The array of colors to include in the resulting image
	///   - size: The point size of the resulting image
	///   - cornerRadius: The corner radius
	///   - scale: The scale to use when creating the image
	/// - Returns: The created CGImage, or nil if an error occurred
	static func Image(colors: [PAL.Color], size: CGSize, cornerRadius: CGFloat = 4, scale: CGFloat = 2) throws -> NSImage {
		let image = try Self.CGImage(colors: colors, size: size, cornerRadius: cornerRadius, scale: scale)
		return NSImage(cgImage: image, size: size)
	}
}

#endif
