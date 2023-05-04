//
//  HEXPaletteCoder.swift
//
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

import DSFRegex
import Foundation

public extension PAL.Coder {
	/// A coder that handle delimited RGBA strings
	struct HEX: PAL_PaletteCoder {
		public let fileExtension = ["hex"]
		public init() {}
		static let validHexChars = "#0123456789abcdefABCDEF"
	}
}

public extension PAL.Coder.HEX {
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let allData = inputStream.readAllData()
		guard let content = String(data: allData, encoding: allData.stringEncoding ?? .utf8) else {
			throw PAL.CommonError.invalidFormat
		}

		var palette = PAL.Palette()

		// Split into newlines
		let lines = content.split(whereSeparator: \.isNewline)

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
						// Attempt convert to hex
						if let color = try? PAL.Color(rgbHexString: current) {
							palette.colors.append(color)
						}
						current = ""
					}
				}
			}

			if current.isEmpty == false {
				// Attempt convert to hex
				if let color = try? PAL.Color(rgbHexString: current) {
					palette.colors.append(color)
				}
			}
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
		rgbColors.forEach { color in
			if color.alpha < 1.0 {
				// If there's an alpha component, make sure we add it
				if let rgba = color.hexRGBA {
					content += "\(rgba)\n"
				}
			}
			else {
				if let rgb = color.hexRGB {
					content += "\(rgb)\n"
				}
			}
		}

		guard let data = content.data(using: .utf8) else {
			throw PAL.CommonError.invalidString
		}
		return data
	}
}
