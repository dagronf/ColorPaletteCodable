//
//  Copyright © 2026 Darren Ford. All rights reserved.
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
	/// A simple RGB plain text file importer with three 0 ... 255 components and an optional name
	///
	/// Format of the form
	/// ```
	/// 200	15	5
	/// 5	5	5
	/// 192	168 7  color name
	/// ```
	struct RGB255: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .rgb
		public let name = "RGB255 palette"
		public let fileExtension = ["rgb255", "txt"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.rgb255"   // conforms to `public.text`

		// Regex for the decimal rgb format
		//   250 169 55
		//   250 169 55  Name1 and testing
		//   1 0 1 Name-2
		static let regexDecimal = try! DSFRegex(#"^\s*(\d+)\s+(\d+)\s+(\d+)(.*)$"#)

		public init() {}

		public func decode(from inputStream: InputStream) throws -> PAL.Palette {
			// RGB coder handles the import
			try PAL.Coder.RGB().decode(from: inputStream)
		}

		public func encode(_ palette: PAL.Palette) throws -> Data {
			// Flatten _all_ the colors in the palette (including global and group colors) to an RGB color list
			let flattenedColors = try palette.allColors().map { try $0.converted(to: .RGB) }
			var result = ""
			for rgb in flattenedColors {
				let rv = UInt8(min(255, max(0, rgb.colorComponents[0] * 255)).rounded(.towardZero))
				let gv = UInt8(min(255, max(0, rgb.colorComponents[1] * 255)).rounded(.towardZero))
				let bv = UInt8(min(255, max(0, rgb.colorComponents[2] * 255)).rounded(.towardZero))
				result += "\(rv)\t\(gv)\t\(bv)"
				let name = rgb.name.trimmingCharacters(in: CharacterSet.whitespaces)
				if name.isNotEmpty {
					result += "\t\(name)"
				}
				result += "\r\n"
			}
			guard let data = result.data(using: .utf8) else {
				throw PAL.CommonError.unsupportedColorSpace
			}

			return data
		}
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let rgb255 = UTType(PAL.Coder.RGB255.utTypeString)!
}
#endif
