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

// Platform specific routines

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

import CoreGraphics

#if os(macOS)
import AppKit
public typealias PlatformImage = NSImage
#elseif !os(Linux)
import UIKit
public typealias PlatformImage = UIImage
#endif

public extension PAL.Gradient {
	/// Returns a CGGradient representation of the gradient object
	/// - Parameter reversed: Reverse the order of the colors and positions in the gradient.
	/// - Returns: A gradient
	func cgGradient(reversed: Bool = false) -> CGGradient? {
		guard let normalized = try? self.normalized().sorted.stops else { return nil }
		var cgcolors: [CGColor] = normalized.compactMap { $0.color.cgColor }
		var positions: [CGFloat] = normalized.compactMap { CGFloat($0.position) }
		guard cgcolors.count == positions.count else {
			ColorPaletteLogger.log(.error, "Could not convert all colors in gradient to CGColors")
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
	/// - Parameter size: The image size
	/// - Returns: A new image
	func image(size: CGSize) throws -> NSImage {
		guard let gradient = self.cgGradient() else {
			throw PAL.CommonError.cannotGenerateGradient
		}

		// If there are transparency stops, map them to a transparency mask
		let maskImage: CGImage?
		if let _ = self.transparencyStops {
			let tgrad = try self.createTransparencyGradient(.clear)
			maskImage = try tgrad.image(size: size).cgImage
		}
		else {
			maskImage = nil
		}

		let rect = CGRect(origin: .zero, size: size)
		let image = NSImage(size: rect.size, flipped: false) { rect in
			let ctx = NSGraphicsContext.current!.cgContext

			// If there are transparency stops for this gradient, map them as an image mask to the context
			if let maskImage = maskImage {
				ctx.clip(to: CGRect(origin: .zero, size: size), mask: maskImage)
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
	@inlinable func cgImage(size: CGSize) throws -> CGImage {
		let image = try self.image(size: size)
		guard let cgi = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
			throw PAL.CommonError.cannotGenerateGradient
		}
		return cgi
	}
}

#elseif os(iOS) || os(tvOS) || os(watchOS)

import UIKit

public extension PAL.Gradient {
	/// Returns an image representation of the gradient.
	func image(size: CGSize) throws -> UIImage {
		guard let gradient = self.cgGradient() else {
			throw PAL.CommonError.cannotGenerateGradient
		}

		let rect = CGRect(origin: .zero, size: size)

		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		let ctx = UIGraphicsGetCurrentContext()!

		// If there are transparency stops for this gradient, map them as an image mask to the context
		if let _ = self.transparencyStops {
			let tgrad = try self.createTransparencyGradient(.clear)
			if let maskImage = try tgrad.image(size: size).cgImage {
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

		guard let cgi = image else {
			throw PAL.CommonError.cannotGenerateGradient
		}

		return cgi
	}

	/// Returns an image representation of the gradient.
	@inlinable func cgImage(size: CGSize) throws -> CGImage {
		guard let cgi = try self.image(size: size).cgImage else {
			throw PAL.CommonError.cannotGenerateGradient
		}
		return cgi
	}
}

#endif

#if canImport(SwiftUI)

import SwiftUI

@available(macOS 12, macCatalyst 15.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension PAL.Gradient {
	/// Returns a SwiftUI Gradient representation of the gradient object
	/// - Parameters:
	///   - reversed: Reverse the order of the colors and positions in the gradient.
	///   - removeTransparency: If true, removes transparency information
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

	public static func DrawPaletteImage(
		palette: PAL.Palette,
		context: CGContext,
		size: CGSize,
		dimension: CGSize = CGSize(width: 8, height: 8)
	) {
		let allColors = palette.allCGColors().compactMap { $0 }
		let hstep = size.width / dimension.width
		let vstep = size.height / dimension.height
		let szh = hstep - 1
		let szv = vstep - 1

		do {
			var yoffset: CGFloat = size.height - vstep
			var xoffset: CGFloat = 0
			var index = 0
			while index < allColors.count, yoffset >= 0 {

				context.setFillColor(allColors[index])
				context.fill([CGRect(x: xoffset, y: yoffset, width: szh, height: szv)])

				xoffset += hstep
				if xoffset > (size.width - hstep + 1) {
					xoffset = 0
					yoffset -= vstep
				}

				index += 1
			}
		}
	}


	/// Generate an image representation for a palette
	/// - Parameters:
	///   - palette: The palette
	///   - size: The generated image size
	///   - dimension: The relative size of swatches in the image
	/// - Returns: An image
	internal static func GeneratePaletteImage(
		palette: PAL.Palette,
		size: CGSize,
		dimension: CGSize = CGSize(width: 8, height: 8)
	) -> PlatformImage? {
		return PlatformImage.generateImage(size: size) { ctx, size in
			Self.DrawPaletteImage(palette: palette, context: ctx, size: size, dimension: dimension)
		}
	}

	/// Generate an image containing the specified gradient
	/// - Parameters:
	///   - gradient: The gradient
	///   - startPoint: The start point (0,0) -> (1,1)
	///   - endPoint: The end point (0,0) -> (1,1)
	///   - size: The resulting image size
	/// - Returns: An image
	internal static func GenerateGradientImage(
		gradient: CGGradient,
		startPoint: CGPoint = CGPoint(x: 0, y: 0),
		endPoint: CGPoint = CGPoint(x: 1, y: 0),
		size: CGSize
	) -> PlatformImage? {
		let startPt = CGPoint(x: startPoint.x * size.width, y: startPoint.y * size.height)
		let endPt = CGPoint(x: endPoint.x * size.width, y: endPoint.y * size.height)
		return PlatformImage.generateImage(size: size) { ctx, size in
			ctx.drawLinearGradient(
				gradient,
				start: startPt,
				end: endPt,
				options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
			)
		}
	}
}

extension PAL.Palette {
	/// Generate an image representation for a palette
	/// - Parameters:
	///   - size: The generated image size
	///   - dimension: The relative size of swatches in the image
	/// - Returns: An image
	public func thumbnailImage(
		size: CGSize,
		dimension: CGSize = CGSize(width: 8, height: 8)
	) -> PlatformImage? {
		PAL.Image.GeneratePaletteImage(palette: self, size: size, dimension: dimension)
	}
}

extension PAL.Gradient {
	/// Generate a thumbnail image representation for the gradient
	/// - Parameters:
	///   - startPoint: The start point (0,0) -> (1,1)
	///   - endPoint: The end point (0,0) -> (1,1)
	///   - size: The resulting image size
	/// - Returns: An image
	public func thumbnailImage(
		startPoint: CGPoint = CGPoint(x: 0, y: 0),
		endPoint: CGPoint = CGPoint(x: 1, y: 0),
		size: CGSize
	) -> PlatformImage? {
		guard let gradient = self.cgGradient() else { return nil }
		return PAL.Image.GenerateGradientImage(
			gradient: gradient,
			startPoint: startPoint,
			endPoint: endPoint,
			size: size)
	}
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
