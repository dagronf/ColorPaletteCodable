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

import DSFRegex
import Foundation

public extension PAL.Coder {
	/// A coder for SK1 color palettes
	///
	/// The decoder here is _very_ rudimentary, as the SKP format appears to be Python code
	/// I was too lazy to write a full python executable, so I'm just using very simple regex matching for RGB entries
	struct SKP: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .skp
		public let name = "SK1 Color Palette"
		public let fileExtension = ["skp"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.sk1"   // conforms to `public.text`

		public init() {}
	}
}

private let __rgbColorRegex = try! DSFRegex(#"color\(\['RGB', \[(\b\d+(?:\.\d+)?\b), (\b\d+(?:\.\d+)?\b), (\b\d+(?:\.\d+)?\b)\], (\b\d+(?:\.\d+)?\b),.*?'(.*?)'"#)
private let __paletteNameRegex = try! DSFRegex(#"set_name\((?:.*?)'(.*?)'\)"#)

// MARK: - Decoding

public extension PAL.Coder.SKP {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load text from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			throw PAL.CommonError.unableToLoadFile
		}

		// All the lines in the file
		let lines = decoded.text.lines

		// Check we're a valid
		guard let first = lines.first, first.hasPrefix("##sK1 palette") else {
			throw PAL.CommonError.invalidFormat
		}

		var palette = PAL.Palette(format: self.format)

		for line in lines.dropFirst() {
			let l = line.trimmingCharacters(in: CharacterSet.whitespaces)

			if l.isEmpty {
				// Skip over empty lines
				break
			}

			do {
				// Check if it's the palette name
				//   set_name('Bluecurve icon colors')
				let namedefs = __paletteNameRegex.matches(for: l)
				namedefs.forEach { match in
					let name = String(l[match.captures[0]])
					if name.isNotEmpty {
						palette.name = name
					}
				}
			}

			// Check if it's a color definition
			do {
				let searchResult = __rgbColorRegex.matches(for: l)
				// Loop over each of the matches found, and print them out
				searchResult.forEach { match in
					if
						let red = Double(l[match.captures[0]]),
						let green = Double(l[match.captures[1]]),
						let blue = Double(l[match.captures[2]]),
						let alpha = Double(l[match.captures[3]])
					{
						let name = String(l[match.captures[4]])
						let color = rgbf(red, green, blue, alpha, name: name)
						palette.colors.append(color)
					}
				}
			}
		}
		if palette.allColors().count == 0 {
			throw PAL.CommonError.invalidFormat
		}
		return palette
	}
}

// MARK: - Encoding

public extension PAL.Coder.SKP {
	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {

		var result = "##sK1 palette\n"
		result += "palette()\n"
		result += "set_name('\(palette.name)')\n"
		result += "set_source('ColorPaletteCodable')\n"
		result += "set_columns(4)\n"

		for color in palette.allColors() {
			let rgb = try color.rgb()
			let colorName = color.name.replacingOccurrences(of: "'\"", with: "_")
			result += "color(['RGB', [\(rgb.rf), \(rgb.gf), \(rgb.bf)], \(rgb.af), '\(colorName)'])\n"
		}

		result += "palette_end()\n"

		guard let data = result.data(using: .utf8) else {
			throw PAL.CommonError.invalidFormat
		}
		return data
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let sk1 = UTType(exportedAs: PAL.Coder.SKP.utTypeString, conformingTo: .text)
}
#endif


// MARK: - Notes


/*
##sK1 palette
palette()
set_name('iOS 7 colors')
set_source('Apple')
add_comments('The palette is published here:')
add_comments('https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/ColorImagesText.html')
set_columns(4)
color(['RGB', [0.35294117647058826, 0.7843137254901961, 0.9803921568627451], 1.0, '#5AC8FA'])
color(['RGB', [1.0, 0.8, 0.0], 1.0, '#FFCC00'])
color(['RGB', [1.0, 0.5843137254901961, 0.0], 1.0, '#FF9500'])
color(['RGB', [1.0, 0.17647058823529413, 0.3333333333333333], 1.0, '#FF2D55'])
color(['RGB', [0.0, 0.47843137254901963, 1.0], 1.0, '#007AFF'])
color(['RGB', [0.2980392156862745, 0.8509803921568627, 0.39215686274509803], 1.0, '#4CD964'])
color(['RGB', [1.0, 0.23137254901960785, 0.18823529411764706], 1.0, '#FF3B30'])
color(['RGB', [0.5568627450980392, 0.5568627450980392, 0.5764705882352941], 1.0, '#8E8E93'])
palette_end()
*/
