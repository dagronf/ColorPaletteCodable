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

// iOS, tvOS, watchOS related functions

#if os(iOS) || os(tvOS) || os(watchOS)

import Foundation
import UIKit

public extension UIColor {
	/// Create a UIColor from a hex formatted string
	/// - Parameters:
	///   - hexString: The hex string
	///   - format: The expected color ordering
	convenience init(hexString: String, format: PAL.ColorByteFormat) throws {
		let rgb = try PAL.Color.RGB(hexString, format: format)
		self.init(red: CGFloat(rgb.rf), green: CGFloat(rgb.gf), blue: CGFloat(rgb.bf), alpha: CGFloat(rgb.af))
	}

	/// Create a PAL.Color from a UIColor
	/// - Parameters:
	///   - name: The color's name
	///   - colorType: The color's type
	/// - Returns: A PAL.Color representation of the image
	@inlinable func palColor(name: String = "", colorType: PAL.ColorType = .global) throws -> PAL.Color {
		try PAL.Color(color: self, name: name, colorType: colorType)
	}

	/// Return the HSB components for this color
	/// - Returns: HSB representation
	func hsb() -> PAL.Color.HSB {
		var h: CGFloat = 0.0
		var s: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 0.0
		self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
		return PAL.Color.HSB(hf: Double(h), sf: Double(s), bf: Double(b), af: Double(a))
	}
}

public extension PAL.Color {
	/// Create a color from an UIColor instance
	///
	/// Throws an error if the UIColor cannot be represented as a PAL.Color object
	init(color: UIColor, name: String = "", colorType: PAL.ColorType = .global) throws {
		try self.init(color: color.cgColor, name: name, colorType: colorType)
	}

	/// Returns a UIColor representation of this color
	@inlinable var uiColor: UIColor? {
		return self.cgColor.unwrapping { UIColor(cgColor: $0) }
	}

	/// Returns a UIColor representation of this color
	@inlinable var platformColor: UIColor? { self.uiColor }
}

public extension PAL.Image {
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
}

public extension PAL.Palette {
	/// Create a palette from an array of UIColor
	/// - Parameters:
	///   - colors: The colors
	///   - name: The palette name
	init(_ colors: [UIColor], name: String = "") throws {
		guard colors.count > 0 else { throw PAL.CommonError.tooFewColors }
		self.colors = try colors.map { try PAL.Color(color: $0) }
	}
}

extension UIImage {
	/// Create a `UIImage` by drawing into an image context
	/// - Parameters:
	///   - size: The size of the image
	///   - opaque: Is the context transparent?
	///   - drawBlock: The drawing routine
	/// - Returns: An image containing the results of the drawing block, or nil if the image cannot be
	static func createUsingImageContext(
		_ size: CGSize,
		opaque: Bool = false,
		drawBlock: (CGContext) throws -> Void
	) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(size, opaque, 1)
		defer { UIGraphicsEndImageContext() }

		guard
			let ctx = UIGraphicsGetCurrentContext(),
			let _ = try? drawBlock(ctx),
			let image = UIGraphicsGetImageFromCurrentImageContext()
		else {
			return nil
		}
		return image
	}
}

#endif
