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

/*

There is no formal specification for CSV palettes, encode and decode support basic formats only

* A single line of RGB(A) values

 363732,53d8fb,66c3ff,dce1e9,d4afb9

* A single line of RGB(A) values

#363732FE, #53d8fbAA, #66c3ff04, #dce1e922, #d4afb9FF

A table of color definitions (name is optional)

363732, Black olive
53d8fb, Vivid sky blue
66c3ff, Maya blue
dce1e9, Alice Blue
d4afb9, Orchid pink
#d4afb999, Orchid pink (modified)
#66c3ff
d4afb9, Orchid pink
*/

import Foundation
import TinyCSV

/// A very basic csv decoder/encoder
public extension PAL.Coder {
	struct CSV: PAL_PaletteCoder {
		public let name = "CSV"
		public let fileExtension = ["csv"]

		/// Create a CSV Coder
		/// - Parameter hexFormat: The format to use when encoding/decoding CSV color values
		public init(hexFormat: PAL.ColorByteFormat = .rgb) {
			self.hexFormat = hexFormat
		}

		let hexFormat: PAL.ColorByteFormat
	}
}

extension PAL.Coder.CSV {
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load text from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			throw PAL.CommonError.unableToLoadFile
		}

		let content = TinyCSV.Coder().decode(text: decoded.text)
		let colors: [PAL.Color]

		switch content.records.count {
		case 0:
			throw PAL.CommonError.invalidFormat
		case 1:
			// Single line of hex colors
			let record = content.records[0]
			colors = try record.map { try PAL.Color(rgbaHexString: $0.trim()) }
		default:
			colors = try content.records.compactMap { record in
				if record.count == 1 {
					// Single RGB(A) entry
					return try PAL.Color(rgbaHexString: record[0].trim())
				}
				else if record.count > 1 {
					// First is color, second is name
					return try PAL.Color(name: record[1].trim(), rgbaHexString: record[0].trim())
				}
				return nil
			}
		}
		if colors.count == 0 {
			throw PAL.CommonError.invalidFormat
		}
		return PAL.Palette(colors: colors)
	}
}

public extension PAL.Coder.CSV {
	func encode(_ palette: PAL.Palette) throws -> Data {
		// Flatten all the colors into the color list
		let cl = palette.allColors()

		var results: String = ""
		try cl.forEach { c in
			results += try c.hexString(format: self.hexFormat, hashmark: true, uppercase: false)
			if c.name.count > 0 {
				results += ", \(c.name)"
			}
			results += "\n"
		}
		guard let d = results.data(using: .utf8) else {
			throw PAL.CommonError.invalidUnicodeFormatString
		}
		return d
	}
}
