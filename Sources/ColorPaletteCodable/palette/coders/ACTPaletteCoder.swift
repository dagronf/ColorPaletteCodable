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

/// An ACT file reader (Adobe Color Table)
public extension PAL.Coder {
	struct ACT: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .act
		public let name = "Adobe Color Table"
		public let fileExtension = ["act"]
		public static let utTypeString = "com.adobe.act"  // conforms to `public.data`
		public init() {}
	}
}

extension PAL.Coder.ACT {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let parser = BytesReader(inputStream: inputStream)
		var result = PAL.Palette(format: self.format)

		// The file is 768 or 772 bytes long and contains 256 RGB colors
		try (0 ..< 256).forEach { _ in
			let rgb = try parser.readData(count: 3)
			let r = UInt8(rgb[0])
			let g = UInt8(rgb[1])
			let b = UInt8(rgb[2])
			let color = PAL.Color(r255: r, g255: g, b255: b, a255: 255)
			result.colors.append(color)
		}

		if let numColors: Int16 = try? parser.readInt16(.big) {
			// Two bytes for the number of colors to use
			let prefix = [PAL.Color](result.colors.prefix(Int(numColors)))
			result.colors = prefix
		}

		if let alphaIndex: Int16 = try? parser.readInt16(.big),
			alphaIndex >= 0 && alphaIndex < result.colors.count
		{
			let index = Int(alphaIndex)
			// Two bytes for the color index with the transparency color to use
			let alpha = try result.colors[index].withAlpha(0)
			result.colors[index] = alpha
		}

		return result
	}
}

extension PAL.Coder.ACT {
	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	public func encode(_ palette: PAL.Palette) throws -> Data {
		let writer = try BytesWriter()

		// Flatten _all_ the colors in the palette (including global and group colors) to an RGB list
		let flattenedColors = try palette.allColors().rgb()

		// This format only supports 256 colors max
		let colors = flattenedColors.prefix(256)
		let maxColors = colors.count

		try (0 ..< 256).forEach { index in
			if index < maxColors {
				// All colors in the ACT table are RGB
				let c = flattenedColors[index]
				try writer.writeByte(c.r255)
				try writer.writeByte(c.g255)
				try writer.writeByte(c.b255)
			}
			else {
				try writer.writeByte(0)
				try writer.writeByte(0)
				try writer.writeByte(0)
			}
		}

		if maxColors < 256 {
			try writer.writeUInt16(UInt16(maxColors), .big)
			try writer.writeUInt16(UInt16(0xFFFF), .big)
		}

		return try writer.data()
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let adobeColorTable = UTType(PAL.Coder.ACT.utTypeString)!
}
#endif
