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

// https://www.cyotek.com/blog/reading-coreldraw-palettes-part-1-pal-files

/*

 "Schwarz"                         0   0   0   100
 "Rot"                             0   100 100 0
 "Blau"                            100 100 0   0
 "Dunkelblau"                      67  33  0   40
 "Cyanblau"                        100 0   0   0
 "Gr?n"                            100 0   100 0
 "Grasgr?n"                        100 0   67  40
 "Dunkelgr?n"                      100 0   50  60
 "Olivbraun"                       0   0   67  40
 "Braun"                           0   33  67  40

 */


public extension PAL.Coder {
	struct CorelDraw3PaletteCoder: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .corelDrawV3
		public let name = "Corel Draw V3"
		public let fileExtension = ["pal"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.coreldrawV3.pal"    // conforms to `public.text`
		public init() {}

		static let regex = try! DSFRegex(#""(.*)"[ \t]*([0-9]*\.?[0-9]+)[ \t]*([0-9]*\.?[0-9]+)[ \t]*([0-9]*\.?[0-9]+)[ \t]*([0-9]*\.?[0-9]+)[ \t]*"#)
	}
}

public extension PAL.Coder.CorelDraw3PaletteCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load text from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			throw PAL.CommonError.invalidFormat
		}

		var palette = PAL.Palette(format: self.format)

		decoded.text.lines.forEach { line in
			let l = line.trimmingCharacters(in: CharacterSet.whitespaces)
			let searchResult = Self.regex.matches(for: l)

			searchResult.forEach { match in
				let name = l[match.captures[0]]		// color name
				let cyan = l[match.captures[1]]		// cyan percent
				let magenta = l[match.captures[2]]	// magenta percent
				let yellow = l[match.captures[3]]	// yellow percent
				let black = l[match.captures[4]]		// black percent

				let color: PAL.Color

				if
					let c = Double(cyan),
					let m = Double(magenta),
					let y = Double(yellow),
					let k = Double(black)
				{
					color = cmykf(c / 100.0, m / 100.0, y / 100.0, k / 100.0, name: String(name))
				}
				else {
					ColorPaletteLogger.log(.error, "CorelDraw3PaletteCoder: Unknown color at index %d, inserting placeholder...", palette.colors.count + 1)
					color = rgbf(1.0, 0.0, 0.0, 0.5, name: "Invalid color in palette")
				}
				palette.colors.append(color)
			}
		}

		if palette.allColors().count == 0 {
			// Couldn't load any colors - invalid format?
			throw PAL.CommonError.invalidFormat
		}

		return palette
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {

		var result = ""

		let colors = palette.allColors()

		try colors.forEach { c in
			let color = try c.cmyk()
			let ci = Int((color.cf * 100).rounded(.toNearestOrAwayFromZero))
			let mi = Int((color.mf * 100).rounded(.toNearestOrAwayFromZero))
			let yi = Int((color.yf * 100).rounded(.toNearestOrAwayFromZero))
			let ki = Int((color.kf * 100).rounded(.toNearestOrAwayFromZero))

			result += "\"\(c.name)\"    \(ci)    \(mi)    \(yi)    \(ki)\r\n"
		}

		guard let d = result.data(using: .utf8) else {
			throw PAL.CommonError.invalidUnicodeFormatString
		}
		return d
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let corelDrawV3 = UTType(PAL.Coder.CorelDraw3PaletteCoder.utTypeString)!
}
#endif
