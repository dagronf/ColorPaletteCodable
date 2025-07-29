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

// Inspiration from https://github.com/Balakov/GrdToAfpalette/

public extension PAL.Coder {
	/// An object representing an AFPalette (v10-v11)
	struct AFPaletteCoder: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .afpalette
		public let name = "Affinity Designer Palette"
		public let fileExtension = ["afpalette"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.afpalette"  // conforms to `public.data`

		public init() {}
	}
}

// MARK: - Load/Save

public extension PAL.Coder.AFPaletteCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let data = inputStream.readAllData()
		let parser = BytesReader(data: data)
		var result = PAL.Palette(format: self.format)

		var hasUnsupportedColorType = false

		let bom = try parser.readUInt32(.little)
		guard bom == 0x414BFF00 else {
			throw PAL.CommonError.invalidBOM
		}

		let version = try parser.readUInt32(.little)
		guard version == 11 || version == 10 else {
			throw PAL.CommonError.invalidBOM
		}

		// NClP
		try parser.readThroughNextInstanceOfPattern(0x4e, 0x43, 0x6c, 0x50)

		// filename
		let filenameLen = try parser.readUInt32(.little)
		let filename = try parser.readStringASCII(length: Int(filenameLen))

		result.name = filename

		// Colors
		var colors: [PAL.Color] = []

		// VlaP
		try parser.readThroughNextInstanceOfPattern(0x56, 0x6c, 0x61, 0x50)
		let colorCount = try parser.readUInt32(.little)
		for index in (0 ..< colorCount) {
			let curPos = parser.readPosition

			// 446C6F63 5F
			// Dloc_
			do {
				// Find the next color
				try parser.readThroughNextInstanceOfASCII("rloC")

				// Skip 6 bytes?
				_ = try parser.readBytes(count: 6)

				// The color type as a string
				let colorType = try parser.readStringASCII(length: 4)

				if colorType == "ABGR" {
					try parser.readThroughNextInstanceOfASCII("Dloc_")
					let r = try parser.readFloat32(.little)
					let g = try parser.readFloat32(.little)
					let b = try parser.readFloat32(.little)
					let color = PAL.Color(rf: Double(r), gf: Double(g), bf: Double(b)) // I think the alpha is ignored?, af: Double(a))
					colors.append(color)
				}
				else if colorType == "ABAL" {
					// Lab color
					try parser.readThroughNextInstanceOfASCII("<loc_")
					let l = try parser.readUInt16(.little)
					let a = try parser.readUInt16(.little)
					let b = try parser.readUInt16(.little)

					let color = PAL.Color.LAB(
						l100: Double(l) / 65535.0 * 100,
						a128: Double(a) / 65535.0 * 256.0 - 128.0,
						b128: Double(b) / 65535.0 * 256.0 - 128.0
					)
					colors.append(PAL.Color(color: color.rgb()))
				}
				else if colorType == "KYMC" {
					// CMYK color
					try parser.readThroughNextInstanceOfASCII("Hloc_")
					let c = try parser.readFloat32(.little)
					let m = try parser.readFloat32(.little)
					let y = try parser.readFloat32(.little)
					let k = try parser.readFloat32(.little)
					let color = PAL.Color(cf: Double(c), mf: Double(m), yf: Double(y), kf: Double(k))
					colors.append(color)
				}
				else if colorType == "ALSH" {
					// HSL color
					try parser.readThroughNextInstanceOfASCII("Dloc_")
					let h = try parser.readFloat32(.little)
					let s = try parser.readFloat32(.little)
					let l = try parser.readFloat32(.little)
					let color = PAL.Color(
						hf: Double(h),
						sf: Double(s),
						lf: Double(l)
					)
					colors.append(color)
				}
				else if colorType == "YARG" {
					// Gray color
					try parser.readThroughNextInstanceOfASCII("<loc_")
					let g1 = try parser.readFloat32(.little)
					let color = PAL.Color(white: Double(g1))
					colors.append(color)
				}
				else {
					hasUnsupportedColorType = true
					ColorPaletteLogger.log(.error, "afpalette: unsupported color type '%@' at index %d, curpos %d", colorType, index, curPos)
					throw PAL.CommonError.cannotCreateColor
				}
			}
			catch {
				if hasUnsupportedColorType {
					// A true error -- an unsupported color type
					throw PAL.CommonError.unsupportedPaletteType
				}

				// Sometimes there seems to be less colors in the file than names
				// Dunno why that is - lets just try to work around it.
				try? parser.seekSet(curPos)
				break
			}
		}

		// Read the color names (VNaP)
		try parser.readThroughNextInstanceOfPattern(0x56, 0x4e, 0x61, 0x50) // 564E6150

		// Dunno what this is? Maybe an offset or something?
		let /*tmp*/ _ = try parser.readUInt32(.little)

		let nameCount = try parser.readUInt32(.little)
		try (0 ..< min(Int(nameCount), colors.count)).forEach { index in
			let colorNameLen = try parser.readUInt32(.little)
			let colorName = try parser.readStringUTF8(byteCount: Int(colorNameLen)) //(length: Int(colorNameLen))
			//let colorName = try parser.readStringASCII(length: Int(colorNameLen))
			colors[Int(index)].name = colorName
		}
		result.colors = colors

		return result
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation of the palette
	///
	/// Currently not supported for Adobe Color Book
	func encode(_ palette: PAL.Palette) throws -> Data {
		ColorPaletteLogger.log(.error, "AFPaletteCoder: encode() not implemented")
		throw PAL.CommonError.notImplemented
	}
}

// UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let afpalette = UTType(PAL.Coder.AFPaletteCoder.utTypeString)!
}
#endif
