//
//  ASEPalette+CoreGraphics.swift
//
//  Created by Darren Ford on 16/5/2022.
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

// CoreGraphics extensions for ASEPalette.Color

#if os(macOS) || os(iOS) || os(tvOS)

import CoreGraphics
import Foundation

public extension ASE {
	/// CoreGraphics color space definitions for ASE model types
	struct ColorSpaceCG {
		/// RGB colorspace
		static let RGB  = CGColorSpace(name: CGColorSpace.sRGB)!
		/// CMYK colorspace
		static let CMYK = CGColorSpace(name: CGColorSpace.genericCMYK)!
		/// LAB colorspace
		static let LAB  = CGColorSpace(name: CGColorSpace.genericLab)!
		/// Gray colorspace
		static let Gray = CGColorSpace(name: CGColorSpace.linearGray)!
	}
}

public extension ASE.Color {
	/// Create a Color object from a CGColor
	/// - Parameters:
	///   - cgColor: The cgColor to add to the palette. Note any alpha value is lost (as .ase files don't support transparency)
	///   - name: The color's name (optional)
	///   - colorType: The type of color (global, normal, spot) (optional)
	init(cgColor: CGColor, name: String = "", colorType: ASE.ColorType = .normal) throws {
		self.name = name
		self.colorType = colorType

		var model: ASE.ColorSpace?
		var convertedColor: CGColor = cgColor

		if let cs = cgColor.colorSpace {
			if cs.name == ASE.ColorSpaceCG.CMYK.name {
				model = .CMYK
			}
			else if cs.name == ASE.ColorSpaceCG.RGB.name {
				model = .RGB
			}
			else if cs.name == ASE.ColorSpaceCG.LAB.name {
				model = .LAB
			}
			else if cs.name == ASE.ColorSpaceCG.Gray.name {
				model = .Gray
			}
		}

		if model == nil {
			// If we can't figure out the model, fall back to Core Graphics to attempt to convert the color to RGB
			guard let conv = cgColor.converted(to: ASE.ColorSpaceCG.RGB, intent: .defaultIntent, options: nil) else {
				throw ASE.CommonError.unsupportedCGColorType
			}
			convertedColor = conv
			model = .RGB
		}

		guard let comp = convertedColor.components, let model = model else {
			throw ASE.CommonError.unsupportedCGColorType
		}

		// The last component in CG components is the alpha, so we need to drop it (as .ase doesn't use alpha)
		self.colorComponents = comp.dropLast().map { Float32($0) }
		self.alpha = Float32(cgColor.alpha)
		self.model = model
	}

	/// Returns a CGColor representation of the color. Returns nil if the color cannot be converted
	///
	/// Makes no underlying assumptions that the ase file color model is correct for the colorComponent count
	var cgColor: CGColor? {
		let components = colorComponents.map { CGFloat($0) }
		switch model {
		case .CMYK:
			return CGColor(colorSpace: ASE.ColorSpaceCG.CMYK, components: components)?.copy(alpha: CGFloat(self.alpha))
		case .RGB:
			return CGColor(colorSpace: ASE.ColorSpaceCG.RGB, components: components)?.copy(alpha: CGFloat(self.alpha))
		case .LAB:
			return CGColor(colorSpace: ASE.ColorSpaceCG.LAB, components: components)?.copy(alpha: CGFloat(self.alpha))
		case .Gray:
			return CGColor(colorSpace: ASE.ColorSpaceCG.Gray, components: components)?.copy(alpha: CGFloat(self.alpha))
		}
	}

	/// Return a hex RGB string (eg. "#523b50")
	///
	/// If the underlying colorspace is not RGB, attempts to convert to `genericRGBLinear`
	/// before performing the conversion
	var hexRGB: String? { return self.cgColor?.hexRGB }

	/// Return a hex RGBA string (eg. "#523b50FF")
	var hexRGBA: String? {
		guard let s = self.cgColor?.hexRGB else { return nil }
		return s + "FF"
 	}
}

#endif
