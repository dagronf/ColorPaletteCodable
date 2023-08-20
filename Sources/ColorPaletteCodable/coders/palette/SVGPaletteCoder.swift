//
//  SVGPaletteCoder.swift
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

import Foundation

public extension PAL.Coder {
	/// A coder that handles export a palette to an SVG swatch representation
	struct SVG: PAL_PaletteCoder {
		public let fileExtension = ["svg"]
		public let swatchSize: PAL.Size
		public let maxExportWidth: Double
		public let edgeInset: PAL.EdgeInsets

		/// Create a SVG coder/decoder
		/// - Parameters:
		///   - maxExportWidth: The maximum width of the exported SVG
		///   - swatchSize: The size for each color swatch
		///   - edgeInset: The inset from the edges of the SVG page
		public init(
			maxExportWidth: Double = 600,
			swatchSize: PAL.Size = PAL.Size(width: 40, height: 40),
			edgeInset: PAL.EdgeInsets = PAL.EdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
		) {
			self.swatchSize = swatchSize
			self.maxExportWidth = maxExportWidth
			self.edgeInset = edgeInset
		}
	}
}

public extension PAL.Coder.SVG {
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		ASEPaletteLogger.log(.error, "SVG Coder: decode() not implemented")
		throw PAL.CommonError.notImplemented
	}
}

public extension PAL.Coder.SVG {
	func encode(_ palette: PAL.Palette) throws -> Data {

		var xOffset: CGFloat = edgeInset.left
		var yOffset: CGFloat = edgeInset.top

		var colors: String = ""

		func exportGrouping(_ colors: [PAL.Color]) -> String {
			var result = ""
			colors.forEach { color in
				if let c = color.hexRGB {
					// <rect x="4.0" y="4.0" width="40.0" height="40.0" fill="#5e315b" fill-opacity="0.73333335" />
					result += "      <rect x=\"\(xOffset)\" y=\"\(yOffset)\" width=\"\(self.swatchSize.width)\" height=\"\(self.swatchSize.height)\" "
					result += "fill=\"\(c)\" fill-opacity=\"\(color.alpha)\""
					result += " />\n"

					xOffset += self.swatchSize.width + 1
					if xOffset + self.swatchSize.width + edgeInset.right > self.maxExportWidth {
						yOffset += self.swatchSize.height + 1
						xOffset = edgeInset.left
					}
				}
			}
			return result
		}

		// Global colors first
		colors += exportGrouping(palette.colors)

		palette.groups.forEach { group in
			xOffset = edgeInset.left
			colors += exportGrouping(group.colors)

			if !group.name.isEmpty {
				yOffset += self.swatchSize.height + 10
				colors += "      <text x='5' y='\(yOffset)' font-size='8' alignment-baseline='middle'>\(group.name)</text>\n\n"
			}

			yOffset += 10
		}

		yOffset += edgeInset.bottom

		// Build the final SVG

		var result = """
<?xml version="1.0" encoding="utf-8"?>
   <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" viewBox="0 0 \(maxExportWidth) \(yOffset + swatchSize.height)" xml:space="preserve">

"""
		result += colors
		result += "</svg>\n"

		if let data = result.data(using: .utf8) {
			return data
		}
		throw PAL.CommonError.invalidString
	}
}
