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

/// A simple RGB plain text file importer. Any 'A' component is ignored
///
/// Format of the form
/// ```
/// #fcfc80
/// #fcf87c
/// #fcf478
/// ```
public extension PAL.Coder {
	struct RGB: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .rgb
		public let name = "RGB text"
		public let fileExtension = ["rgb", "txt"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.rgb"   // conforms to `public.text`

		public init() {}

		// Regex for file of the format
		//   #aabbccdd   The first color
		//   #112423     The second color
		//   acbf
		static let regex = try! DSFRegex(#"^#?\s*([a-f0-9]{3,8})\s*(.*)\s*"#, options: .caseInsensitive)
	}
}

public extension PAL.Coder.RGB {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load text from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			throw PAL.CommonError.unableToLoadFile
		}
		let text = decoded.text

		var palette = PAL.Palette(format: self.format)

		try text.lines.forEach { line in
			let l = line.trimmingCharacters(in: CharacterSet.whitespaces)
			
			if l.isEmpty {
				// Skip over empty lines
				return
			}
			
			let searchResult = Self.regex.matches(for: l)
			// Loop over each of the matches found, and print them out
			try searchResult.forEach { match in
				let hex = l[match.captures[0]]
				let name = l[match.captures[1]]
				
				let color = try PAL.Color(rgbHexString: String(hex), format: .rgb, name: String(name))
				palette.colors.append(color)
			}
		}
		if palette.allColors().count == 0 {
			throw PAL.CommonError.invalidFormat
		}
		return palette
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		// Flatten _all_ the colors in the palette (including global and group colors) to an RGB list
		let flattenedColors = try palette.allColors().map { try $0.converted(to: .RGB) }

		var result = ""
		for color in flattenedColors {
			if !result.isEmpty { result += "\r\n" }
			result += try color.hexRGB(hashmark: true)
			if color.name.count > 0 {
				result += " \(color.name)"
			}
		}
		guard let d = result.data(using: .utf8) else {
			throw PAL.CommonError.unsupportedColorSpace
		}
		return d
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let rgb = UTType(PAL.Coder.RGB.utTypeString)!
}
#endif
