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

/// A simple RGBA plain text file importer
///
/// Format of the form
/// ```
/// #fcfc80aa
/// #fcf87cbb Duck color
/// #fcf47812
/// #f8f074c1 Noodles!
/// #f8ec7045
/// #f4ec6c67
/// #ecdc5cb3
/// ```
public extension PAL.Coder {
	struct RGBA: PAL_PaletteCoder {
		public let name = "RGBA text"
		public let fileExtension = ["rgba", "txt"]
		public init() {}

		// Regex for file of the format
		//   #aabbccdd   The first color
		//   #112423     The second color
		//   acbf
		static let regex = try! DSFRegex(#"^#?\s*([a-f0-9]{3,8})\s*(.*)\s*"#, options: .caseInsensitive)
	}
}

public extension PAL.Coder.RGBA {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	///
	/// Format:
	///    #FFFFFFFF  White color
	///    #000000FF  Black color
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load text from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			throw PAL.CommonError.unableToLoadFile
		}
		let text = decoded.text

		let lines = text.split(separator: "\n")
		var palette = PAL.Palette()

		try lines.forEach { line in
			let l = line.trimmingCharacters(in: CharacterSet.whitespaces)

			if l.isEmpty {
				// Skip over empty lines
				return
			}

			let searchResult = Self.regex.matches(for: l)
			if searchResult.count == 0 {
				throw PAL.CommonError.invalidRGBAHexString(l)
			}

			// Loop over each of the matches found, and add them to the palette
			try searchResult.forEach { match in
				let hex = l[match.captures[0]]
				let name = l[match.captures[1]]

				let color = try PAL.Color(hexString: String(hex), format: .rgba, name: String(name))
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
			if !result.isEmpty { result += "\n" }

			result += try color.hexRGBA(hashmark: true)
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
