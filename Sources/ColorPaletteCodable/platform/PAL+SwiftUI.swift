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

// SwiftUI support routines

#if canImport(SwiftUI)

import Foundation
import SwiftUI

@available(macOS 11, iOS 14.0, tvOS 14.0, watchOS 8.0, *)
public extension PAL.Color {
	/// Create a color from a SwiftUI Color
	/// - Parameters:
	///   - name: The color's name
	///   - color: The SwiftUI color
	///   - colorType: The color type
	init(name: String = "", _ color: SwiftUI.Color, colorType: PAL.ColorType = .global) throws {
		#if os(macOS)
		// Convert via NSColor
		let rawColor = NSColor(color).cgColor
		#else
		// Convert via UIColor
		let rawColor = UIColor(color).cgColor
		#endif
		try self.init(name: name, color: rawColor, colorType: colorType)
	}
}

@available(macOS 10.15, iOS 14.0, tvOS 14.0, watchOS 8.0, *)
public extension PAL.Color {
	/// Extract a SwiftUI color from this color
	@inlinable var SwiftUIColor: Color? {
		guard let cgColor = self.cgColor else { return nil }
		#if os(macOS)
		guard let nsColor = NSColor(cgColor: cgColor) else { return nil }
		return Color(nsColor)
		#else
		return Color(UIColor(cgColor: cgColor))
		#endif
	}
}

@available(macOS 10.15, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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

@available(macOS 11, iOS 14.0, tvOS 14.0, watchOS 8.0, *)
public extension PAL.Palette {
	/// Generate a gradient using the colors in this palette
	/// - Parameter style: The style to apply when generating the gradient
	/// - Returns: A  SwiftUI Gradient
	func SwiftUIGradient(style: ExportGradientStyle = .smooth) throws -> Gradient {
		let allColors: [Color] = self.allColors().compactMap { $0.SwiftUIColor }
		guard allColors.count > 1 else { throw PAL.CommonError.notEnoughColorsToGenerateGradient }
		var stops: [Gradient.Stop] = []

		switch style {
		case .stepped:
			let step: CGFloat = 1.0 / CGFloat(colors.count)
			var offset = step

			// First stop
			stops.append(Gradient.Stop(color: allColors[0], location: 0))
			stops.append(Gradient.Stop(color: allColors[0], location: step - 0.0001))

			allColors
				.dropFirst()
				.dropLast()
				.enumerated()
				.forEach { color in
					stops.append(Gradient.Stop(color: color.1, location: offset))
					stops.append(Gradient.Stop(color: color.1, location: offset + step - 0.0001))
					offset += step
				}

			stops.append(Gradient.Stop(color: allColors.last!, location: offset))
			stops.append(Gradient.Stop(color: allColors.last!, location: 1.0))
		case .smooth:
			let step: CGFloat = 1.0 / CGFloat(colors.count - 1)
			var offset: CGFloat = 0.0
			allColors.forEach { color in
				stops.append(Gradient.Stop(color: color, location: offset))
				offset += step
			}
		}
		return Gradient(stops: stops)
	}
}

#endif
