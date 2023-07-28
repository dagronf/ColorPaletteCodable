//
//  PAL+CoreGraphics.swift
//
//  Created by Darren Ford on 16/5/2022.
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

// CoreGraphics convenience extensions

#if canImport(CoreGraphics)

import CoreGraphics
import Foundation

public extension PAL.ColorSpace {
	/// Return the CGColorspace representation used for this colorspace
	var cgColorSpace: CGColorSpace {
		switch self {
		case .CMYK: return CGColorSpace(name: CGColorSpace.genericCMYK)!
		case .RGB: return CGColorSpace(name: CGColorSpace.sRGB)!
		case .LAB: return CGColorSpace(name: CGColorSpace.genericLab)!
		case .Gray: return CGColorSpace(name: CGColorSpace.linearGray)!
		}
	}
}

public extension PAL.Color {
	/// Create a Color object from a CGColor
	/// - Parameters:
	///   - cgColor: The cgColor to add to the palette.
	///   - name: The color's name (optional)
	///   - colorType: The type of color (global, normal, spot) (optional)
	///
	/// Throws an error if the CGColor cannot be represented as a PAL.Color object
	init(cgColor: CGColor, name: String = "", colorType: PAL.ColorType = .global) throws {
		self.name = name
		self.colorType = colorType

		var model: PAL.ColorSpace?
		var convertedColor: CGColor = cgColor

		if let cs = cgColor.colorSpace {
			if cs.name == PAL.ColorSpace.CMYK.cgColorSpace.name {
				model = .CMYK
			}
			else if cs.name == PAL.ColorSpace.RGB.cgColorSpace.name {
				model = .RGB
			}
			else if cs.name == PAL.ColorSpace.LAB.cgColorSpace.name {
				model = .LAB
			}
			else if cs.name == PAL.ColorSpace.Gray.cgColorSpace.name {
				model = .Gray
			}
		}

		if model == nil {
			// If we can't figure out the model, fall back to Core Graphics to attempt to convert the color to RGB
			guard let conv = cgColor.converted(to: PAL.ColorSpace.RGB.cgColorSpace, intent: .defaultIntent, options: nil) else {
				throw PAL.CommonError.unsupportedCGColorType
			}
			convertedColor = conv
			model = .RGB
		}

		guard let comp = convertedColor.components, let cs = model else {
			throw PAL.CommonError.unsupportedCGColorType
		}

		// The last component in CG components is the alpha, so we need to drop it (as .ase doesn't use alpha)
		self.colorComponents = comp.dropLast().map { Float32($0) }
		self.alpha = Float32(cgColor.alpha)
		self.colorSpace = cs
	}

	/// Returns a CGColor representation of the color. Returns nil if the color cannot be converted
	///
	/// Makes no underlying assumptions that the ase file color model is correct for the colorComponent count
	var cgColor: CGColor? {
		guard self.isValid else { return nil }
		let components = colorComponents.map { CGFloat($0) }
		switch colorSpace {
		case .CMYK:
			return CGColor(colorSpace: PAL.ColorSpace.CMYK.cgColorSpace, components: components)?.copy(alpha: CGFloat(self.alpha))
		case .RGB:
			return CGColor(colorSpace: PAL.ColorSpace.RGB.cgColorSpace, components: components)?.copy(alpha: CGFloat(self.alpha))
		case .LAB:
			return CGColor(colorSpace: PAL.ColorSpace.LAB.cgColorSpace, components: components)?.copy(alpha: CGFloat(self.alpha))
		case .Gray:
			return CGColor(colorSpace: PAL.ColorSpace.Gray.cgColorSpace, components: components)?.copy(alpha: CGFloat(self.alpha))
		}
	}
}

public extension Array where Element == PAL.Color {
	/// Returns an array of the colors as `CGColor`s
	@inlinable func cgColors() -> [CGColor?] {
		self.map { $0.cgColor }
	}
}

public extension PAL.Palette {
	/// Returns an array of the global colors as `CGColor`s
	@inlinable func globalCGColors() -> [CGColor?] {
		self.colors.cgColors()
	}

	/// Returns a flattened array of all colors defined in the palette as `CGColor`s
	@inlinable func allCGColors() -> [CGColor?] {
		self.allColors().cgColors()
	}
}

public extension PAL.Palette {
	/// The style to use when exporting a CG/SwiftUI gradient object
	enum ExportGradientStyle {
		/// An evenly spaced smooth gradient
		case smooth
		/// An evenly stepped gradient
		case stepped
	}

	/// Generate a gradient using the colors in this palette
	/// - Parameter style: The style to apply when generating the gradient
	/// - Returns: A CGGradient
	func cgGradient(style: ExportGradientStyle = .smooth) throws -> CGGradient {
		let allColors: [CGColor] = self.allCGColors().compactMap { $0 }
		guard allColors.count > 1 else { throw PAL.CommonError.notEnoughColorsToGenerateGradient }

		var stops: [(CGColor, CGFloat)] = []

		switch style {
		case .stepped:
			let step: CGFloat = 1.0 / CGFloat(colors.count)
			var offset = step

			// First stop
			stops.append((allColors[0], 0.0))
			stops.append((allColors[0], step - 0.0001))

			allColors
				.dropFirst()
				.dropLast()
				.enumerated()
				.forEach { color in
					stops.append((color.1, offset))
					stops.append((color.1, offset + step - 0.0001))
					offset += step
				}

			stops.append((allColors.last!, offset))
			stops.append((allColors.last!, 1.0))
		case .smooth:
			let step: CGFloat = 1.0 / CGFloat(colors.count - 1)
			var offset: CGFloat = 0.0
			allColors.forEach { color in
				stops.append((color, offset))
				offset += step
			}
		}
		guard let gradient = CGGradient(
			colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
			colors: stops.map { $0.0 } as CFArray,
			locations: stops.map { $0.1 }
		)
		else {
			throw PAL.CommonError.cannotGenerateGradient
		}
		return gradient
	}
}

#endif

#if os(iOS) || os(tvOS) || os(watchOS)
extension CGColor {
	static let clear = CGColor(colorSpace: PAL.ColorSpace.RGB.cgColorSpace, components: [0, 0, 0, 0])!
}
#endif
