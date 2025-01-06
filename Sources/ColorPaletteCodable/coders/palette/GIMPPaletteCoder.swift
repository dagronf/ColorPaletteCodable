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
	struct GIMP: PAL_PaletteCoder {
		public let name = "GIMP Palette"
		public let fileExtension = ["gpl"]
		public init() {}
	}
}

public extension PAL.Coder.GIMP {
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load a string from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			ColorPaletteLogger.log(.error, "GGRCoder: Unexpected text encoding")
			throw PAL.CommonError.invalidFormat
		}
		let content = decoded.text

		let lines = content.split(whereSeparator: \.isNewline)
		guard lines.count > 0, lines[0].contains("GIMP Palette") else {
			throw PAL.CommonError.invalidFormat
		}

		var palette = PAL.Palette()

		// Regex to find the name
		let nameRegex = try DSFRegex(#"^Name:\s*(.*)$"#)
		// Regex for the color line(s)
		let colorRegex = try DSFRegex(#"^\s*(\d+)\s+(\d+)\s+(\d+)(.*)$"#)

		for line in lines.dropFirst() {
			let lineStr = String(line)

			if let match = nameRegex.matches(for: lineStr).matches.first {
				let colorlistName = lineStr[match.captures[0]]
				palette.name = String(colorlistName)
				continue
			}

			if let match = colorRegex.matches(for: lineStr).matches.first {
				let rs = lineStr[match.captures[0]]
				let gs = lineStr[match.captures[1]]
				let bs = lineStr[match.captures[2]]
				let ss = lineStr[match.captures[3]]

				guard
					let rv = Int(rs),
					let gv = Int(gs),
					let bv = Int(bs)
				else {
					continue
				}

				let sv = ss.trimmingCharacters(in: .whitespacesAndNewlines)

				let re = max(0, min(1, Float32(rv) / 255.0))
				let ge = max(0, min(1, Float32(gv) / 255.0))
				let be = max(0, min(1, Float32(bv) / 255.0))

				let c = try PAL.Color(name: sv, colorSpace: .RGB, colorComponents: [re, ge, be])
				palette.colors.append(c)
			}
		}
		return palette
	}
}

public extension PAL.Coder.GIMP {
	func encode(_ palette: PAL.Palette) throws -> Data {
		var result = "GIMP Palette\n"
		if !palette.name.isEmpty {
			result += "Name: \(palette.name)\n"
		}

		// Flatten _all_ the colors in the palette (including global and group colors) to an RGB color list
		let flattenedColors = try palette.allColors().map { try $0.converted(to: .RGB) }

		result += "#Colors: \(flattenedColors.count)\n"
		for rgb in flattenedColors {
			let rv = Int(min(255, max(0, rgb.colorComponents[0] * 255)).rounded(.towardZero))
			let gv = Int(min(255, max(0, rgb.colorComponents[1] * 255)).rounded(.towardZero))
			let bv = Int(min(255, max(0, rgb.colorComponents[2] * 255)).rounded(.towardZero))

			result += "\(rv)\t\(gv)\t\(bv)"
			if !rgb.name.isEmpty {
				result += "\t\(rgb.name)"
			}
			result += "\n"
		}
		guard let data = result.data(using: .utf8) else {
			throw PAL.CommonError.unsupportedColorSpace
		}

		return data
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let gimpPalette = UTType("public.dagronf.gimp.gpl")!
}
#endif
