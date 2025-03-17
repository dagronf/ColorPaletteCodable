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

import Foundation

import BytesParser

public extension PAL.Coder {
	/// A coder supporting 18-bit (3 \* 6-bit channel) RGB VGA palettes
	struct VGA18BitPaletteCoder: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .vga18bit
		public let name = "18-bit RGB VGA Palette"
		public let utType = "public.dagronf.vgargb.18bit.pal"
		public let fileExtension = ["pal"]
		public init() {}
	}
}

public extension PAL.Coder.VGA18BitPaletteCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let data = inputStream.readAllData()
		if (data.count % 3) != 0 {
			/// RGB triplets - if not a multiple of 3 then format error
			throw PAL.CommonError.invalidFormat
		}

		let colors = try stride(from: 0, to: data.count, by: 3).map { index in
			let r = data[index]
			let g = data[index + 1]
			let b = data[index + 2]
			if r > 63 || g > 63 || b > 63 {
				// None of the byte values should be > 63 (max for 6-bit)
				throw PAL.CommonError.invalidFormat
			}
			return rgbf(Double(r) / 63.0, Double(g) / 63.0, Double(b) / 63.0)
		}
		return PAL.Palette(colors: colors, format: self.format)
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		let colors = palette.allColors()
		var data = Data(capacity: colors.count * 3)
		try colors.forEach { color in
			let rgb = try color.rgb()
				.components
				.map { UInt8(($0 * 63).rounded(.toNearestOrAwayFromZero)) }
			data.append(contentsOf: rgb)
		}
		return data
	}
}
