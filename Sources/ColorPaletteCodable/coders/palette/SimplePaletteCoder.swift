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

import Foundation

/// Specification for the Simple Color Palette format
/// https://sindresorhus.com/simple-color-palette
/// https://github.com/simple-color-palette/spec

public extension PAL.Coder {
	/// A 'Simple Color Palette' encoder/decoder
	///
	/// Specification for the Simple Color Palette format
	/// [https://sindresorhus.com/simple-color-palette](https://sindresorhus.com/simple-color-palette)
	/// [https://github.com/simple-color-palette/spec](https://github.com/simple-color-palette/spec)
	struct SimplePaletteCoder: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .simplePalette
		public let name = "Simple Color Palette"

		public let fileExtension = [ "color-palette" ]
		public static let utTypeString = "com.sindresorhus.simple-color-palette"
	}
}

// Export should only take into a maximum of 4 decimal places
// https://github.com/simple-color-palette/spec?tab=readme-ov-file#why-4-decimal-places
private let MaxDecimalPlaces: UInt = 4

public extension PAL.Coder.SimplePaletteCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let data = inputStream.readAllData()

		let s = try JSONDecoder().decode(SimplePalette.self, from: data)

		// Convert
		var palette = PAL.Palette(format: .simplePalette)
		palette.name = s.name ?? ""

		let colors: [PAL.Color] = s.colors.compactMap {
			// Each color is an object with the following fields:
			// * name: Optional. String.
			// * components: Required. Array of 3 or 4 floating-point numbers.
			//   * [red, green, blue] or [red, green, blue, opacity]
			// * The color should use extended linear sRGB color space.
			//
			// The color components can be negative and more than 1.
			// The opacity defaults to 1 if omitted.
			// The opacity should be clamped to 0...1 range when reading and writing the palette.
			// It should not throw if outside the range.
			let name = $0.name
			// The components should only respect 4 decimal places
			let components = $0.components.map { $0.rounded(toPlaces: MaxDecimalPlaces) }
			// Only 3 or 4 components depending on alpha
			guard components.count > 2, components.count <= 4 else { return nil }

			let lr = components[0]
			let lg = components[1]
			let lb = components[2]
			let la = (components.count == 4) ? components[3].clamped(to: 0.0 ... 1.0) : 1.0

			// Convert from linear extended sRGB to sRGB
			let r = NaiveConversions.ExtendedLinearSRGB2SRGB(lr)
			let g = NaiveConversions.ExtendedLinearSRGB2SRGB(lg)
			let b = NaiveConversions.ExtendedLinearSRGB2SRGB(lb)
			let a = la
			return rgbf(r, g, b, a, name: name ?? "")
		}

		// Map the palette colors to global colors
		palette.colors.append(contentsOf: colors)
		return palette
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		// The palette name
		let name: String? = palette.name.count > 0 ? palette.name : nil

		// Map all the colors to SimplePaletteColors
		let colors = try palette.allColors().compactMap {
			let name: String? = $0.name.count > 0 ? $0.name : nil

			// Make sure we're in sRGB format
			let c = try $0.rgb()

			//  Convert to linear (extended)
			var components = [
				NaiveConversions.SRGB2Linear(c.rf),
				NaiveConversions.SRGB2Linear(c.gf),
				NaiveConversions.SRGB2Linear(c.bf)
			]

			// If there's an alpha value that's not 1, add it to the components
			if c.af.isEqual(to: 1.0, precision: MaxDecimalPlaces) == false {
				components.append(c.af)
			}

			// Encoding should only ever use 4 decimal places max
			components = components.map { $0.rounded(toPlaces: MaxDecimalPlaces) }

			return SimplePaletteColor(name: name, components: components)
		}

		let result = SimplePalette(name: name, colors: colors)
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		return try encoder.encode(result)
	}
}

// MARK: - Private

extension Double {
	/**
	 Rounds the number to specified decimal places using banker's rounding.

	 - Parameter places: Number of decimal places (must be >= 0).
	 - Returns: The rounded number.
	 */
	func rounded(toPlaces places: UInt) -> Self {
		guard places > 0 else {
			return self
		}

		let multiplier = pow(10.0, Self(places))
		return (self * multiplier).rounded(.toNearestOrEven) / multiplier
	}
}

// MARK: JSON structure

private struct SimplePaletteColor: Codable {
	let name: String?
	let components: [Double]
}

private struct SimplePalette: Codable {
	let name: String?
	let colors: [SimplePaletteColor]
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let simpleColorPalette = UTType(
		importedAs: PAL.Coder.SimplePaletteCoder.utTypeString,
		conformingTo: .json
	)
}
#endif
