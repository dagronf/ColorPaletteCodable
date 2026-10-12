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

import Foundation
import BytesParser

/// A Microsoft RIFF palette file reader
/// See https://www.codeproject.com/Articles/1172812/Loading-Microsoft-RIFF-Palette-pal-Files-with-Csha
public extension PAL.Coder {
	struct RIFF: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .riff
		public let name = "Microsoft RIFF"
		public let fileExtension = ["pal"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.microsoft.riff"   // conforms to `public.data`

		/// Create a RIFF encoder/decoder
		public init() { }
	}
}

extension PAL.Coder.RIFF {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// NOTE: Assumption here is that `inputStream` is already open
		// If the input stream isn't open, the reading will hang.
		let parser = BytesReader(inputStream: inputStream)

		var result = PAL.Palette(format: self.format)

		// Check header
		let header: Int32 = try parser.readInt32(.big)
		guard header == 0x52494646 else { // 'RIFF'
			throw PAL.CommonError.invalidFormat
		}

		// Document size - we don't really care about this
		let _: Int32 = try parser.readInt32(.big)

		let riffType: Int32 = try parser.readInt32(.big)
		guard riffType == 0x50414C20 else { // 'PAL '
			throw PAL.CommonError.invalidFormat
		}

		// We are going to ignore the fact that a RIFF file can contain multiple chunks
		let dataHeader: Int32 = try parser.readInt32(.big)
		let _: Int32 = try parser.readInt32(.little)        // chunk size
		guard dataHeader == 0x64617461 else {
			// Not palette data - just read all the data in the chunk
			//_ = try readData(inputStream, size: Int((chunkSize % 2 != 0) ? chunkSize + 1 : chunkSize))
			throw PAL.CommonError.invalidFormat
		}

		let _: Int16 = try parser.readInt16(.little) // palVersion
		let palNumEntries: Int16 = try parser.readInt16(.little)
		try (0 ..< palNumEntries).forEach { index in
			let rgb = try parser.readData(count: 4)
			let r = UInt8(rgb[0])
			let g = UInt8(rgb[1])
			let b = UInt8(rgb[2])
			let color = PAL.Color(r255: r, g255: g, b255: b)
			result.colors.append(color)
		}

		return result
	}
}

extension PAL.Coder.RIFF {
	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation of the palette
	///
	/// See: https://web.archive.org/web/20260704080410/https://www.cyotek.com/blog/writing-microsoft-riff-palette-pal-files-with-csharp
	public func encode(_ palette: PAL.Palette) throws -> Data {

		// We can only have a maximum of 256 colors in a RIFF palette
		let flatColors = palette.allColors().prefix(256)
		let count = flatColors.count
		let chunkSize = 4 + (count * 4)

		let writer = try BytesWriter()

		// Header
		try writer.writeStringASCII("RIFF")

		// 4 bytes for RIFF
		// 4 bytes for document size
		// 4 bytes for PAL
		// 4 bytes for data
		// 4 bytes for chunk size
		// 2 bytes for the version
		// 2 bytes for the count
		// (4*n) for the colors
		let length = 4 + 4 + 4 + 4 + 4 + 2 + 2 + count * 4

		// Document size
		try writer.writeInt32(Int32(length - 8), .little)

		// Header
		try writer.writeStringASCII("PAL ")

		// data chunk header
		try writer.writeStringASCII("data")

		// data chunk size
		try writer.writeInt32(Int32(chunkSize), .little)

		// log palette
		try writer.writeByte(0)

		// version
		try writer.writeByte(3)

		// number of colors
		try writer.writeInt16(Int16(count), .little)

		// Write all the colors
		try flatColors.forEach { color in
			let c = try color.rgb()
			try writer.writeBytes(c.r255, c.g255, c.b255, 0)
		}

		// Finished writing
		writer.complete()

		// Return the result
		return try writer.data()
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let microsoftRIFF = UTType(PAL.Coder.RIFF.utTypeString)!
}
#endif
