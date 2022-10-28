//
//  PAL+Gradient+platform.swift
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

// Platform specific routines

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import CoreGraphics

public extension PAL.Gradient {
	/// Returns a CGGradient representation of the gradient object
	/// - Parameter reversed: Reverse the order of the colors and positions in the gradient.
	/// - Returns: A gradient
	func cgGradient(reversed: Bool = false) -> CGGradient? {
		guard let normalized = try? self.normalized().sorted.stops else { return nil }
		var cgcolors: [CGColor] = normalized.compactMap { $0.color.cgColor }
		var positions: [CGFloat] = normalized.compactMap { $0.position }
		guard cgcolors.count == positions.count else {
			ASEPaletteLogger.log(.error, "Could not convert all colors in gradient to CGColors")
			return nil
		}

		if reversed {
			cgcolors = cgcolors.reversed()
			positions = positions.map { 1.0 - $0 }
		}

		return CGGradient(
			colorsSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
			colors: cgcolors as CFArray,
			locations: positions
		)
	}
}

#endif

#if os(macOS)

import AppKit

public extension PAL.Gradient {
	/// Returns an image representation of the gradient.
	func image(size: CGSize) -> NSImage? {
		guard let gradient = self.cgGradient() else { return nil }
		let rect = CGRect(origin: .zero, size: size)
		let image = NSImage(size: rect.size, flipped: false) { rect in
			let ctx = NSGraphicsContext.current!.cgContext
			ctx.drawLinearGradient(
				gradient,
				start: CGPoint(x: 0, y: 0),
				end: CGPoint(x: rect.width, y: 0),
				options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
			)
			return true
		}
		return image
	}

	/// Returns an image representation of the gradient.
	@inlinable func cgImage(size: CGSize) -> CGImage? {
		return self.image(size: size)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
	}
}

#elseif os(iOS) || os(tvOS) || os(watchOS)

import UIKit

public extension PAL.Gradient {
	/// Returns an image representation of the gradient.
	func image(size: CGSize) -> UIImage? {
		guard let gradient = self.cgGradient() else { return nil }

		let rect = CGRect(origin: .zero, size: size)

		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		let ctx = UIGraphicsGetCurrentContext()!
		ctx.drawLinearGradient(
			gradient,
			start: CGPoint(x: 0, y: 0),
			end: CGPoint(x: rect.width, y: 0),
			options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
		)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image
	}

	/// Returns an image representation of the gradient.
	@inlinable func cgImage(size: CGSize) -> CGImage? {
		return self.image(size: size)?.cgImage
	}
}

#endif
