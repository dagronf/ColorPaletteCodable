//
//  PAL+Image.swift
//
//  Created by Darren Ford on 6/11/21.
//  Copyright © 2021 Darren Ford. All rights reserved.
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

// Image generation routines

#if canImport(CoreGraphics)

import CoreGraphics
import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension PAL {
	struct Image {}
}

public extension PAL.Image {
	/// Generate a CGImage from the list of colors. Useful for simple drag item images etc.
	/// - Parameters:
	///   - colors: The array of colors to include in the resulting image
	///   - size: The point size of the resulting image
	///   - cornerRadius: The corner radius
	///   - scale: The scale to use when creating the image
	/// - Returns: The created CGImage, or nil if an error occurred
	static func CGImage(colors: [PAL.Color], size: CGSize, cornerRadius: CGFloat = 4, scale: CGFloat = 2) throws -> CGImage {
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		guard let bitmapContext = CGContext(
			data: nil,
			width: Int(size.width * scale),
			height: Int(size.height * scale),
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: colorSpace,
			bitmapInfo: bitmapInfo.rawValue
		)
		else {
			throw PAL.CommonError.cannotCreateImage
		}
		
		bitmapContext.saveGState()
		Self.DrawImage(in: bitmapContext, scale: scale, size: size, cornerRadius: cornerRadius, colors: colors)
		bitmapContext.restoreGState()
		
		guard let image = bitmapContext.makeImage() else {
			throw PAL.CommonError.cannotCreateImage
		}
		return image
	}
}

public extension PAL.Image {
#if os(macOS)
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
	
#elseif os(iOS) || os(tvOS) || os(watchOS)
	/// Generate a UIImage of the list of colors. Useful for drag item images etc.
	/// - Parameters:
	///   - colors: The array of colors to include in the resulting image
	///   - size: The point size of the resulting image
	///   - cornerRadius: The corner radius
	///   - scale: The scale to use when creating the image
	/// - Returns: The created CGImage, or nil if an error occurred
	static func Image(colors: [PAL.Color], size: CGSize, cornerRadius: CGFloat = 4, scale: CGFloat = 2) throws -> UIImage {
		let image = try Self.CGImage(colors: colors, size: size, cornerRadius: cornerRadius, scale: scale)
		return UIImage(cgImage: image, scale: scale, orientation: .up)
	}
#endif
}

private extension PAL.Image {
	static func DrawImage(
		in ctx: CGContext,
		scale: CGFloat,
		size: CGSize,
		cornerRadius: CGFloat,
		colors: [PAL.Color]
	) {
		let newSize = CGSize(width: size.width * scale, height: size.height * scale)
		let newRect = CGRect(origin: .zero, size: newSize)
		
		let maskPath = CGPath(
			roundedRect: newRect.insetBy(dx: 0.5, dy: 0.5),
			cornerWidth: cornerRadius * scale,
			cornerHeight: cornerRadius * scale,
			transform: nil
		)
		ctx.addPath(maskPath)
		ctx.clip()
		
		let xdiv = (newSize.width / CGFloat(colors.count)).rounded(.towardZero)
		var template = CGRect(origin: .zero, size: CGSize(width: xdiv, height: newSize.height))
		
		colors.enumerated().forEach { iter in
			ctx.setFillColor(iter.element.cgColor ?? .clear)
			template.origin.x = (xdiv * CGFloat(iter.offset))
			if iter.offset == (colors.count - 1) {
				template.size.width = newRect.width - template.origin.x
			}
			ctx.fill(template)
		}
		ctx.resetClip()
	}
}

#endif
