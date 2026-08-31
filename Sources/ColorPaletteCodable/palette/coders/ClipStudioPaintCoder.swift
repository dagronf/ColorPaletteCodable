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

// A Clip Studio Paint palette reader/writer
//
// See: https://github.com/Equbuxu/CLSEncoderDecoder

import Foundation
import BytesParser

public extension PAL.Coder {
	/// An object representing a Clip Studio color palette file
	struct ClipStudioPaint: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .clipStudioPaint
		public let name = "Clip Studio Paint"
		public let fileExtension = ["cls"]
		public static var utTypeString = "public.dagronf.colorpalette.palette.clipstudiopaint"
		public init() {}
	}
}

// MARK: Decode

private let BOM__: String = "SLCC"
//private let version__: UInt16 = 1
//private let groupIdentifier__: UInt8 = 0xEA
//private let colorIdentifier__: UInt8 = 0xC0

public extension PAL.Coder.ClipStudioPaint {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let parser = BytesReader(inputStream: inputStream)
		var result = PAL.Palette(format: self.format)

		guard try parser.readStringASCII(length: 4) == BOM__ else {
			throw PAL.CommonError.invalidBOM
		}

		// Version for the file
		let version = try parser.readUInt16(.little)
		guard version == 256 else {
			throw PAL.CommonError.invalidVersion
		}

		// Header length, measured from immediately after this Int32.
		let headerLength = Int(try parser.readUInt32(.little))
		let _ /*headerEnd*/ = parser.readPosition + headerLength

		// Header:
		// UInt16 ASCII name length
		// ASCII name
		// UInt32 unused value
		// UInt16 UTF-8 name length
		// UTF-8 name

		// Ascii name
		let asciiName = (try? parser.readPascalStyleAsciiString(.little)) ?? ""

		_ = try parser.readUInt32(.little)

		// Utf8 name
		let utf8Name = try parser.readPascalStyleUtf8String(.little)

		result.name = utf8Name.isNotEmpty ? utf8Name : asciiName

		// Read the expected number of groups (channels).
		// NOTE: This isn't used yet - appears that the group information is not exported into the cls file
		let _ /*expectedGroupCount*/ = try parser.readUInt32(.little)

		// The number of colors
		let colorCount = try parser.readUInt32(.little)

		// The length of the colors block (not used yet)
		let _ /*colorsBlockLength*/ = try parser.readUInt32(.little)

		for _ in 0 ..< colorCount {
			// The length of the color block in bytes
			let blockLength = try parser.readUInt32(.little)
			// Read the color bytes
			let colorBytes = try parser.readBytes(count: Int(blockLength))

			let red = colorBytes[0]
			let green = colorBytes[1]
			let blue = colorBytes[2]
			let alpha = blockLength >= 4 ? colorBytes[3] : 255

			let color = PAL.Color(r255: red, g255: green, b255: blue, a255: alpha)
			result.colors.append(color)
		}

		return result
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation of the palette
	///
	/// Currently not supported for CLS (Clip Studio Paint) file types
	func encode(_ palette: PAL.Palette) throws -> Data {
		throw PAL.CommonError.notImplemented
	}
}

// MARK: - UTType identifiers


#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let clipStudioPaint = UTType(PAL.Coder.ClipStudioPaint.utTypeString)!
}
#endif
