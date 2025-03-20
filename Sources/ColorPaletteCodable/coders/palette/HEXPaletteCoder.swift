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
	/// A coder that handle delimited RGBA strings
	struct HEX: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .hexRGBA
		public let name = "Hex RGBA"
		public let fileExtension = ["hex"]
		public static let utTypeString: String = "public.dagronf.colorpalette.palette.hex"
		public init() {}
		static let validHexChars = "#0123456789abcdefABCDEF"
	}
}

public extension PAL.Coder.HEX {
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load text from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			throw PAL.CommonError.unableToLoadFile
		}
		let content = decoded.text

		var palette = PAL.Palette(format: self.format)

		// Split into newlines
		let lines = content.lines

		for line in lines {
			if line.first == ";" {
				// Assume a comment. Skip the line
				continue
			}

			// Split the line on _anything_ that isn't [#0-9A-Fa-f]

			var current = ""
			line.forEach { character in
				if Self.validHexChars.contains(character) {
					current.append(character)
				}
				else {
					if current.isEmpty == false {
						// Attempt convert from RGB[A] hex
						if let color = try? PAL.Color(hexString: current, format: .rgba) {
							palette.colors.append(color)
						}
						current = ""
					}
				}
			}

			if current.isEmpty == false {
				// Attempt convert from hex
				if let color = try? PAL.Color(hexString: current, format: .rgba) {
					palette.colors.append(color)
				}
			}
		}

		if palette.colors.count == 0 {
			throw PAL.CommonError.invalidFormat
		}

		return palette
	}
}

public extension PAL.Coder.HEX {
	/// Write out the colors in the palette
	/// 1. One color per line, encoded as a HEX value
	/// 2. Hex encoded
	func encode(_ palette: PAL.Palette) throws -> Data {
		let rgbColors = try palette.allColors()
			.compactMap { try $0.converted(to: .RGB) }

		var content = ""
		try rgbColors.forEach { color in
			// If there's an alpha component, make sure we add it
			let format: PAL.ColorByteFormat = (color.alpha < 1.0) ? .rgba : .rgb
			let hex = try color.hexString(format, hashmark: true, uppercase: false)
			content += "\(hex)\n"
		}

		guard let data = content.data(using: .utf8) else {
			throw PAL.CommonError.invalidString
		}
		return data
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let hexPalette = UTType(PAL.Coder.HEX.utTypeString)!
}
#endif
