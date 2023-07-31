//
//  PAL+Gradient+platform.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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
		var positions: [CGFloat] = normalized.compactMap { CGFloat($0.position) }
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

			// If there are transparency stops for this gradient, map them as an image mask to the context
			if let _ = self.transparencyStops {
				let tgrad = self.transparencyGradient(.clear)
				if let maskImage = tgrad.image(size: size)?.cgImage {
					ctx.clip(to: CGRect(origin: .zero, size: size), mask: maskImage)
				}
			}

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

		// If there are transparency stops for this gradient, map them as an image mask to the context
		if let _ = self.transparencyStops {
			let tgrad = self.transparencyGradient(.clear)
			if let maskImage = tgrad.image(size: size)?.cgImage {
				ctx.clip(to: CGRect(origin: .zero, size: size), mask: maskImage)
			}
		}

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

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 12, macCatalyst 15.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension PAL.Gradient {
	/// Returns a SwiftUI Gradient representation of the gradient object
	/// - Parameter reversed: Reverse the order of the colors and positions in the gradient.
	/// - Returns: A gradient
	func SwiftUIGradient(reversed: Bool = false, removeTransparency: Bool = false) -> SwiftUI.Gradient? {
		guard let normalized = try? self.normalized().sorted.stops else { return nil }
		let stops: [SwiftUI.Gradient.Stop] = normalized.compactMap {
			guard var c = $0.color.cgColor else { return nil }
			if removeTransparency, let c1 = $0.color.cgColor?.copy(alpha: 1.0) {
				c = c1
			}
			#if swift(<5.5)
			let sc = Color(c)
			#else
			let sc = Color(cgColor: c)
			#endif
			return SwiftUI.Gradient.Stop(color: sc, location: CGFloat($0.position))
		}
		return SwiftUI.Gradient(stops: stops)
	}

	/// Returns a SwiftUI Gradient representation of the transparency gradient
	/// - Parameter reversed: Reverse the order of the colors and positions in the gradient.
	/// - Returns: A gradient
	func SwiftUITransparencyGradient(reversed: Bool = false) -> SwiftUI.Gradient {
		guard let ts = self.transparencyStops, ts.count > 1 else {
			return Gradient(stops: [
				Gradient.Stop(color: .black, location: 0),
				Gradient.Stop(color: .black, location: 1)
			])
		}

		let stops = ts.map { stop in
			SwiftUI.Gradient.Stop(color: Color(.sRGB, white: 0, opacity: stop.value), location: CGFloat(stop.position))
		}
		return SwiftUI.Gradient(stops: stops)
	}
}

extension PAL.Image {
	#if os(macOS)
	/// Generate an image containing the specified gradient
	/// - Parameters:
	///   - gradient: The gradient
	///   - startPoint: The start point (0,0) -> (1,1)
	///   - endPoint: The end point (0,0) -> (1,1)
	///   - size: The resulting image size
	/// - Returns: An image
	static func GenerateGradientImage(
		gradient: CGGradient,
		startPoint: CGPoint = CGPoint(x: 0, y: 0),
		endPoint: CGPoint = CGPoint(x: 1, y: 0),
		size: CGSize
	) -> NSImage? {
		let startPt = CGPoint(x: startPoint.x * size.width, y: startPoint.y * size.height)
		let endPt = CGPoint(x: endPoint.x * size.width, y: endPoint.y * size.height)
		return NSImage.generateImage(size: size) { ctx, size in
			ctx.drawLinearGradient(
				gradient,
				start: startPt,
				end: endPt,
				options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
			)
		}
	}
	#else
	/// Generate an image containing the specified gradient
	/// - Parameters:
	///   - gradient: The gradient
	///   - startPoint: The start point (0,0) -> (1,1)
	///   - endPoint: The end point (0,0) -> (1,1)
	///   - size: The resulting image size
	/// - Returns: An image
	static func GenerateGradientImage(
		gradient: CGGradient,
		startPoint: CGPoint = CGPoint(x: 0, y: 0),
		endPoint: CGPoint = CGPoint(x: 1, y: 0),
		size: CGSize
	) -> UIImage {
		UIImage.generateImage(size: size) { ctx, size in
			ctx.drawLinearGradient(
				gradient,
				start: CGPoint(x: startPoint.x * size.width, y: startPoint.y * size.height),
				end: CGPoint(x: endPoint.x * size.width, y: endPoint.y * size.height),
				options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
			)
		}!
	}
	#endif
}

#endif

#if os(macOS)
extension NSImage {
	/// Create an image and draw into it
	/// - Parameters:
	///   - size: The size of the image to create
	///   - drawBlock: The block containing drawing command to apply to the image
	/// - Returns: An image
	static func generateImage(
		size: CGSize,
		_ drawBlock: @escaping (CGContext, CGSize) -> Void
	) -> NSImage {
		return NSImage(size: size, flipped: false) { rect in
			let ctx = NSGraphicsContext.current!.cgContext
			drawBlock(ctx, rect.size)
			return true
		}
	}
}
#endif

#if canImport(UIKit)
public extension UIImage {
	/// Create an image and draw into it
	/// - Parameters:
	///   - size: The size of the image to create
	///   - opaque: If false, uses a transparent background
	///   - drawBlock: The block containing drawing command to apply to the image
	/// - Returns: An image
	static func generateImage(
		size: CGSize,
		opaque: Bool = false,
		scale: Double = 1.0,
		_ drawBlock: (CGContext, CGSize) -> Void
	) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
		defer { UIGraphicsEndImageContext() }
		guard let context = UIGraphicsGetCurrentContext() else { return nil }
		drawBlock(context, size)
		return UIGraphicsGetImageFromCurrentImageContext()
	}
}
#endif
