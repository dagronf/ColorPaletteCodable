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
	/// Homesite Palette Decoder/Encoder
	/// Allaire Homesite, Macromedia ColdFusion
	struct HPL: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .hpl
		public let name = "Homesite Palette"
		public static var utTypeString: String = "public.dagronf.colorpalette.palette.homesite"
		public let fileExtension = ["hpl"]
	}
}

public extension PAL.Coder.HPL {
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load a string from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			ColorPaletteLogger.log(.error, "HPLCoder: Unexpected text encoding")
			throw PAL.CommonError.invalidFormat
		}
		let content = decoded.text

		let lines = content.lines
		guard
			lines.count > 0,
			lines[0].contains("Palette"),
			lines[1].contains("Version 4.0")
		else {
			throw PAL.CommonError.invalidFormat
		}

		var palette = PAL.Palette(format: self.format)
		let colorRegex = try DSFRegex(#"^\s*(\d+)\s+(\d+)\s+(\d+).*$"#)

		for line in lines.dropFirst(3) {
			let lineStr = String(line)

			if let match = colorRegex.matches(for: lineStr).matches.first {
				let rs = lineStr[match.captures[0]]
				let gs = lineStr[match.captures[1]]
				let bs = lineStr[match.captures[2]]

				guard
					let rv = Int(rs),
					let gv = Int(gs),
					let bv = Int(bs)
				else {
					continue
				}

				let re = max(0, min(1, Double(rv) / 255.0))
				let ge = max(0, min(1, Double(gv) / 255.0))
				let be = max(0, min(1, Double(bv) / 255.0))

				let c = try PAL.Color(colorSpace: .RGB, colorComponents: [re, ge, be])
				palette.colors.append(c)
			}
		}
		return palette
	}
}

public extension PAL.Coder.HPL {
	func encode(_ palette: PAL.Palette) throws -> Data {
		// Write the header info
		var result = "Palette\nVersion 4.0\n-----------\n"

		// Flatten _all_ the colors in the palette (including global and group colors) to an RGB color list
		let flattenedColors = try palette.allColors().map { try $0.converted(to: .RGB) }

		for rgb in flattenedColors {
			let c = try rgb.rgb()
			result += "\(c.r255) \(c.g255) \(c.b255)\n"
		}
		guard let data = result.data(using: .utf8) else {
			throw PAL.CommonError.unsupportedColorSpace
		}

		return data
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let homesitePalette = UTType(PAL.Coder.HPL.utTypeString)!
}
#endif
