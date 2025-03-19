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

// https://www.selapa.net/swatches/colors/fileformats.php

/*

ROWS 12
COLS 22
WIDTH 16
HEIGHT 16
TEXTHEIGHT 0
SPACING 1
R: 003, G:003, B:003
R: 015, G:015, B:015
R: 045, G:045, B:045
R: 059, G:059, B:059

 */


public extension PAL.Coder {
	struct CorelPainter: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .corelPainter
		public let name = "Corel Painter Swatch"
		public let fileExtension = ["txt"]
		public static let utTypeString = "com.dagronf.colorpalette.corel.painter"   // conforms to `public.text`

		public init() {}

		static let regex = try! DSFRegex(#"[ \t]*R[ \t]*:[ \t]*([0-9]*\.?[0-9]+)[ \t,]*G[ \t]*:[ \t]*([0-9]*\.?[0-9]+)[ \t,]*B[ \t]*:[ \t]*([0-9]*\.?[0-9]+)[ \t,]*(?:HV[ \t]*:[ \t]*([0-9]*\.?[0-9]+)[ \t,]*)?(?:SV[ \t]*:[ \t]*([0-9]*\.?[0-9]+)[ \t,]*)?(?:VV[ \t]*:[ \t]*([0-9]*\.?[0-9]+)[ \t,]*)?(.*)"#)
	}
}

public extension PAL.Coder.CorelPainter {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load text from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			throw PAL.CommonError.invalidFormat
		}
		let text = decoded.text

		guard text.prefix(5) == "ROWS " else {
			// Adobe text swatch?
			throw PAL.CommonError.invalidFormat
		}

		let lines = text.lines
		guard lines.count > 7 else {
			throw PAL.CommonError.invalidFormat
		}
		
		guard 
			lines[0].prefix(4)  == "ROWS",
			lines[1].prefix(4)  == "COLS",
			lines[2].prefix(5)  == "WIDTH",
			lines[3].prefix(6)  == "HEIGHT",
			lines[4].prefix(10) == "TEXTHEIGHT",
			lines[5].prefix(7)  == "SPACING"
		else {
			throw PAL.CommonError.invalidFormat
		}

		let content = lines.dropFirst(6)

		var palette = PAL.Palette(format: self.format)

		content.forEach { line in
			let l = line.trimmingCharacters(in: CharacterSet.whitespaces)
			let searchResult = Self.regex.matches(for: l)

			searchResult.forEach { match in
				let red = l[match.captures[0]]
				let green = l[match.captures[1]]
				let blue = l[match.captures[2]]
				let /*HV*/_ = l[match.captures[3]]
				let /*SV*/_ = l[match.captures[4]]
				let /*VV*/_ = l[match.captures[5]]
				let name = l[match.captures[6]]

				if
					let r = UInt8(red),
					let g = UInt8(green),
					let b = UInt8(blue)
				{
					let name = String(name).trimmingCharacters(in: .whitespaces)
					let color = PAL.Color(r255: r, g255: g, b255: b, a255: 255, name: name, colorType: .normal)
					palette.colors.append(color)
				}
			}
		}

		return palette
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {

		var result: String =
"""
ROWS 12
COLS 22
WIDTH 16
HEIGHT 16
TEXTHEIGHT 0
SPACING 1

"""

		let colors = palette.allColors()

		try colors.forEach { c in
			let c1 = try c.rgb()
			result += "R: \(c1.r255), G:\(c1.g255), B:\(c1.b255)  HV:0.00, SV:0.00, VV:0.00"
			if !c.name.isEmpty {
				result += "  \(c.name)"
			}
			result += "\n"
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
	static let corelPainter = UTType(PAL.Coder.CorelPainter.utTypeString)!
}
#endif
