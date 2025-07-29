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

/// https://www.selapa.net/swatches/colors/fileformats.php#corel_cpl
/// https://web.archive.org/web/20250320193326/https://www.selapa.net/swatches/colors/fileformats.php

public extension PAL.Coder {
	/// A coder for Corel .cpl palette files
	struct CPL: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .corelPalette
		public let name = "Corel Palette"
		public let fileExtension = ["cpl"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.corel.cpl"   // conforms to `public.data`
		public init() {}
	}
}

// MARK: Decode

// Known spot palette types
private let __spotPaletteTypes: [UInt16] = [3, 8, 9, 10, 11, 16, 17, 18, 20, 21, 22, 23, 26, 27, 28, 29, 30, 31, 32, 35, 36, 37]

public extension PAL.Coder.CPL {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {

		let data = inputStream.readAllData()
		let file = BytesReader(data: data)

		var result = PAL.Palette(format: self.format)

		var spot = false
		var paletteType: UInt16 = 0

		let version: UInt16 = try file.readUInt16(.big)
		let numberOfColors: UInt16

		switch version {
		case 0xDCDC:
			// This version has a palette name
			let filenamelength = try file.readUInt8()
			if filenamelength > 0 {
				result.name = try file.readStringASCII(length: Int(filenamelength))
			}
			numberOfColors = try file.readUInt16(.little)
		case 0xCCBC, 0xCCDC:
			// This version doesn't have a palette name, just colors
			numberOfColors = try file.readUInt16(.little)
		default:

			// Read in headers if we can
			let headerCount: Int32 = try file.readInt32(.little)

			// Header ID 1*int32 (0 ⇒ Name, 1 ⇒ Palette type, 2 ⇒ Number of colors, 3 ⇒ Special inks, 4 ⇒ UI Color models, 5 ⇒ UI Columns & Rows)

			let headers: [(hid: Int32, offset: Int)] = try (0 ..< headerCount).map { _ in
				let hid: Int32 = try file.readInt32(.little)
				let offset: Int32 = try file.readInt32(.little)
				return (hid: hid, offset: Int(offset))
			}

			// Name
			try file.seekSet(headers[0].offset)
			let filenamelength: UInt8 = try file.readUInt8()
			var name: String = ""
			if filenamelength > 0 {
				if version == 0xCDDC {
					let nameData = try file.readData(count: Int(filenamelength))
					name = String(data: nameData, encoding: .isoLatin1) ?? ""
				}
				else {
					name = try file.readStringUTF16(.little, length: Int(filenamelength))
				}
			}
			result.name = name

			// Palette Type
			try file.seekSet(headers[1].offset)
			paletteType = try file.readUInt16(.little)

			// Number of colors
			try file.seekSet(headers[2].offset)
			numberOfColors = try file.readUInt16(.little)

			// There are some other possible headers here, but we don't care about them.
			// Given that CPL isn't really in use anymore just ignore them for now.

			// Check if we are a spot palette
			spot = __spotPaletteTypes.contains(paletteType)


			try file.seekSet(headers[2].offset + 2)

			// Move to the colors definitions
			//try file.seekSet(colorsIndex)
		}

		//if version in ('\xcd\xbc','\xcd\xdc','\xcd\xdd') and type < 38 and type not in(5,16):
		let long = [0xCDBC, 0xCDDC, 0xCDDD].contains(version) && paletteType < 38 && paletteType != 5 && paletteType != 16

		for _ in 0 ..< numberOfColors {
			if long {
				let id = try file.readUInt32(.little)
				_ = id
			}
			let model: UInt16 = try file.readUInt16(.little)
			try file.seek(2, .current)

			var colorspace: PAL.ColorSpace?
			var colorComponents: [Double]?

			var colorspace2: PAL.ColorSpace?
			var colorComponents2: [Double]?

			switch model {
			case 2:  // CMYK percentages
				try file.seek(4, .current)
				let cmyk = try file.readBytes(count: 4)
				colorspace = .CMYK
				colorComponents = [Double(cmyk[0]) / 100.0, Double(cmyk[1]) / 100.0, Double(cmyk[2]) / 100.0, Double(cmyk[3]) / 100.0]
			case 3, 17: // CMYK fractions
				try file.seek(4, .current)
				let cmyk = try file.readBytes(count: 4)
				colorspace = .CMYK
				colorComponents = [Double(cmyk[0]) / 255.0, Double(cmyk[1]) / 255.0, Double(cmyk[2]) / 255.0, Double(cmyk[3]) / 255.0]
			case 4:  // CMY fractions
				try file.seek(4, .current)
				let cmyk = try file.readBytes(count: 4)
				colorspace = .CMYK
				colorComponents = [Double(cmyk[0]) / 255.0, Double(cmyk[1]) / 255.0, Double(cmyk[2]) / 255.0]
			case 5, 21:	// BGR fractions
				try file.seek(4, .current)
				let bgr = try file.readBytes(count: 3)
				colorComponents = [Double(bgr[2]) / 255.0, Double(bgr[1]) / 255.0, Double(bgr[0]) / 255.0]
				colorspace = .RGB
				try file.seek(1, .current)
			case 9:
				try file.seek(4, .current)
				let K = try file.readUInt8()
				colorComponents = [Double(255 - K) / 255]
				colorspace = .Gray
				try file.seek(3, .current)
			default:
				// unknown type?  Try to recover
				ColorPaletteLogger.log(.error, "CPL: Unsupported color type %d, attempting to recover...", model)
				try file.seek(8, .current)
			}

			if long {
				let model2: UInt16 = try file.readUInt16(.little)
				switch model2 {
				case 2:  // CMYK percentages
					try file.seek(4, .current)
					let cmyk = try file.readBytes(count: 4)
					colorspace2 = .CMYK
					colorComponents2 = [Double(cmyk[0]) / 100, Double(cmyk[1]) / 100, Double(cmyk[2]) / 100, Double(cmyk[3]) / 100]
				case 3, 17: // CMYK fractions
					try file.seek(4, .current)
					let cmyk = try file.readBytes(count: 4)
					colorspace2 = .CMYK
					colorComponents2 = [Double(cmyk[0]) / 255, Double(cmyk[1]) / 255, Double(cmyk[2]) / 255, Double(cmyk[3]) / 255]
				case 4:  // CMY fractions
					try file.seek(4, .current)
					let cmyk = try file.readBytes(count: 4)
					colorspace2 = .CMYK
					colorComponents2 = [Double(cmyk[0]) / 255, Double(cmyk[1]) / 255, Double(cmyk[2]) / 255]
				case 5, 21:	// BGR fractions
					try file.seek(4, .current)
					let bgr = try file.readBytes(count: 3)
					colorComponents2 = [Double(bgr[2]) / 255, Double(bgr[1]) / 255, Double(bgr[0]) / 255]
					colorspace2 = .RGB
					try file.seek(1, .current)
				case 9:
					try file.seek(4, .current)
					let K = try file.readUInt8()
					colorComponents2 = [Double(255 - K) / 255]
					colorspace2 = .Gray
					try file.seek(3, .current)
				default:
					// unknown type?  Try to recover
					ColorPaletteLogger.log(.error, "CPL: Unsupported color type %d (2), attempting to recover...", model2)
					try file.seek(8, .current)
				}
			}

			let nameLength: UInt8 = try file.readUInt8()
			var colorName = ""
			if nameLength > 0 {
				if version == 0xCDDC || version == 0xDCDC || version == 0xCCDC {
					let nameData = try file.readData(count: Int(nameLength))
					colorName = String(data: nameData, encoding: .isoLatin1) ?? ""
					//colorName = try file.readAsciiString(count: Int(nameLength))
				}
				else {
					colorName = try file.readStringUTF16(.little, length: Int(nameLength))
				}
			}

			if let colorspace = colorspace, let colorComponents = colorComponents {
				let readColor = try PAL.Color(
					colorSpace: colorspace,
					colorComponents: colorComponents,
					name: colorName,
					colorType: spot ? .spot : .normal
				)
				result.colors.append(readColor)
			}

			if let colorspace = colorspace2, let colorComponents = colorComponents2 {
				let readColor = try PAL.Color(
					colorSpace: colorspace,
					colorComponents: colorComponents,
					name: colorName,
					colorType: spot ? .spot : .normal
				)
				result.colors.append(readColor)
			}

			if version == 0xCDDD {
				// row and column?  -- just skip (but we have to read them to move the read pointer to the
				// correct next color
				let _ /*row*/: UInt32 = try file.readUInt32(.little)
				let _ /*col*/: UInt32 = try file.readUInt32(.little)
				let _ /*unknown*/: UInt32 = try file.readUInt32(.little)
			}
		}

		return result
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation of the palette
	///
	/// Currently not supported for Adobe Color Book
	func encode(_ palette: PAL.Palette) throws -> Data {
		ColorPaletteLogger.log(.error, "CPLCoder: encode() not implemented")
		throw PAL.CommonError.notImplemented
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let corelPaintPalette = UTType(PAL.Coder.CPL.utTypeString)!
}
#endif
