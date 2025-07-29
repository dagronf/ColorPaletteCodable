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

// ##Sketch RGBPalette 0
// 0.000000 0.000000 0.000000	Black
// 0.100000 0.100000 0.100000	90% Black
// 0.200000 0.200000 0.200000	80% Black
// 0.300000 0.300000 0.300000	70% Black
// 0.400000 0.400000 0.400000	60% Black

public extension PAL.Coder {
	struct Skencil: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .skencil
		public let name = "Skencil Palette"
		public static var utTypeString: String = "public.dagronf.colorpalette.palette.skencil"
		public let fileExtension = ["spl"]
	}
}

public extension PAL.Coder.Skencil {
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load a string from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			ColorPaletteLogger.log(.error, "Skencil coder: Unexpected text encoding")
			throw PAL.CommonError.invalidFormat
		}
		let content = decoded.text

		let lines = content.lines
		guard
			lines.count > 0,
			lines[0].contains("##Sketch RGBPalette 0")
		else {
			throw PAL.CommonError.invalidFormat
		}

		var palette = PAL.Palette(format: self.format)

		// Regex for the color line(s)
		let colorRegex = try DSFRegex(#"^\s*(\d*\.\d+|\d+)\s+(\d*\.\d+|\d+)\s+(\d*\.\d+|\d+)\s+(.*)$"#)

		for line in lines.dropFirst() {
			let lineStr = String(line)

			if let match = colorRegex.matches(for: lineStr).matches.first {
				let rs = lineStr[match.captures[0]]
				let gs = lineStr[match.captures[1]]
				let bs = lineStr[match.captures[2]]
				let ss = lineStr[match.captures[3]]

				guard
					let rv = Double(rs),
					let gv = Double(gs),
					let bv = Double(bs)
				else {
					continue
				}

				let sv = ss.trimmingCharacters(in: .whitespacesAndNewlines)

				let re = max(0, min(1, rv))
				let ge = max(0, min(1, gv))
				let be = max(0, min(1, bv))

				let c = try PAL.Color(colorSpace: .RGB, colorComponents: [re, ge, be], name: sv)
				palette.colors.append(c)
			}
		}
		return palette
	}
}

private let __formatter = NumberFormatter(
	minimumFractionDigits: 6,
	maximumFractionDigits: 6,
	decimalSeparator: "."
)

public extension PAL.Coder.Skencil {
	func encode(_ palette: PAL.Palette) throws -> Data {

		var result = "##Sketch RGBPalette 0\n"
		let flattenedColors = try palette.allColors().map { try $0.converted(to: .RGB) }

		flattenedColors.forEach { color in
			if
				let rs = __formatter.string(for: color._r),
				let gs = __formatter.string(for: color._g),
				let bs = __formatter.string(for: color._b)
			{
				result += "\(rs) \(gs) \(bs)"
				if color.name.count > 0 {
					result += " \(color.name)"
				}
				result += "\n"
			}
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
	static let skencilPalette = UTType(PAL.Coder.Skencil.utTypeString)!
}
#endif
