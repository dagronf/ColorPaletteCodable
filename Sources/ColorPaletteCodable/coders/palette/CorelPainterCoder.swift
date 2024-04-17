//
//  CorelPainterCoder.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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
		public let name = "Corel Painter Swatch"
		public let fileExtension = ["txt"]
		public init() {}

		//static let regex = try! DSFRegex(#"R:[ \t]*([0-9]{3}),[ \t]*G:[ \t]*([0-9]{3}),[ \t]*B:[ \t]*([0-9]{3})"#)

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

		var palette = PAL.Palette()

		content.forEach { line in
			let l = line.trimmingCharacters(in: CharacterSet.whitespaces)
			let searchResult = Self.regex.matches(for: l)

			try? searchResult.forEach { match in
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
					let color = try PAL.Color(name: String(name).trimmingCharacters(in: .whitespaces), r: r, g: g, b: b, a: 255, colorType: .normal)
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
			let c1 = try c.rgbValues()
			let r: UInt8 = UInt8(c1.r * 255.0)
			let g: UInt8 = UInt8(c1.g * 255.0)
			let b: UInt8 = UInt8(c1.b * 255.0)
			result += "R: \(r), G:\(g), B:\(b)  HV:0.00, SV:0.00, VV:0.00"
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
