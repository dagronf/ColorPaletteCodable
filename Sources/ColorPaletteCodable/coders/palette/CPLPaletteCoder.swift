//
//  ACBPaletteCoder.swift
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

import Foundation

public extension PAL.Coder {
	/// An object representing a CPL (Corel Color Palette)
	struct CPL: PAL_PaletteCoder {
		public let name = "Corel Palette"
		public let fileExtension = ["cpl"]
		public init() {}
	}
}

// MARK: Decode

public extension PAL.Coder.CPL {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {

		let data = inputStream.readAllData()
		let file = DataParser(data: data)
		var result = PAL.Palette()

		var spot = false
		var paletteType: UInt16 = 0

		let version: UInt16 = try file.readInteger(.big)
		let numberOfColors: UInt16

		switch version {
		case 0xDCDC:
			// This version has a palette name
			let filenamelength = try file.readUInt8()
			if filenamelength > 0 {
				result.name = try file.readAsciiString(count: Int(filenamelength))
			}
			numberOfColors = try file.readInteger(.little)
		case 0xCCBC, 0xCCDC:
			// This version doesn't have a palette name, just colors
			numberOfColors = try file.readInteger(.little)
		default:

			// Read in headers if we can
			let headerCount: Int32 = try file.readInteger(.little)
			let headers = try (0 ..< headerCount).map { _ in
				let hid: Int32 = try file.readInteger(.little)
				let offset: Int32 = try file.readInteger(.little)
				return (hid: hid, offset: Int(offset))
			}

			// Name
			try file.seekSet(headers[0].offset)
			let filenamelength: UInt8 = try file.readUInt8()
			var name: String = ""
			if filenamelength > 0 {
				if version == 0xCDDC {
					name = try file.readAsciiString(count: Int(filenamelength))
				}
				else {
					name = try file.readUTF16String(.little, count: Int(filenamelength))
				}
			}
			result.name = name

			// Palette Type
			try file.seekSet(headers[1].offset)
			paletteType = try file.readInteger(.little)

			// Number of colors
			try file.seekSet(headers[2].offset)
			numberOfColors = try file.readInteger(.little)

			// This position is the start of the colors
			let colorsIndex = file.readPosition

			// There are some other possible headers here, but we don't care about them.
			// Given that CPL isn't really in use anymore just ignore them for now.

			spot = [3,8,9,10,11,16,17,18,20,21,22,23,26,27,28,29,30,31,32,35,36,37].contains(paletteType)

			// Move to the colors definitions
			try file.seekSet(colorsIndex)
		}

		//if version in ('\xcd\xbc','\xcd\xdc','\xcd\xdd') and type < 38 and type not in(5,16):
		let long = [0xCDBC, 0xCDDC, 0xCDDD].contains(version) && paletteType < 38 && paletteType != 5 && paletteType != 16

		for _ in 0 ..< numberOfColors {
			let model: UInt16 = try file.readInteger(.little)
			try file.seek(2, .current)

			var colorspace: PAL.ColorSpace?
			var colorComponents: [Double]?

			var colorspace2: PAL.ColorSpace?
			var colorComponents2: [Double]?

			switch model {
			case 2:  // CMYK percentages
				try file.seek(4, .current)
				let cmyk = try file.readArray(count: 4)
				colorspace = .CMYK
				colorComponents = [Double(cmyk[0]) / 100, Double(cmyk[1]) / 100, Double(cmyk[2]) / 100, Double(cmyk[3]) / 100]
			case 3, 17: // CMYK fractions
				try file.seek(4, .current)
				let cmyk = try file.readArray(count: 4)
				colorspace = .CMYK
				colorComponents = [Double(cmyk[0]) / 255, Double(cmyk[1]) / 255, Double(cmyk[2]) / 255, Double(cmyk[3]) / 255]
			case 4:  // CMY fractions
				try file.seek(4, .current)
				let cmyk = try file.readArray(count: 4)
				colorspace = .CMYK
				colorComponents = [Double(cmyk[0]) / 255, Double(cmyk[1]) / 255, Double(cmyk[2]) / 255]
			case 5, 21:	// BGR fractions
				try file.seek(4, .current)
				let bgr = try file.readArray(count: 3)
				colorComponents = [Double(bgr[2]) / 255, Double(bgr[1]) / 255, Double(bgr[0]) / 255]
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
				let model2: UInt16 = try file.readInteger(.little)
				switch model2 {
				case 2:  // CMYK percentages
					try file.seek(4, .current)
					let cmyk = try file.readArray(count: 4)
					colorspace2 = .CMYK
					colorComponents2 = [Double(cmyk[0]) / 100, Double(cmyk[1]) / 100, Double(cmyk[2]) / 100, Double(cmyk[3]) / 100]
				case 3, 17: // CMYK fractions
					try file.seek(4, .current)
					let cmyk = try file.readArray(count: 4)
					colorspace2 = .CMYK
					colorComponents2 = [Double(cmyk[0]) / 255, Double(cmyk[1]) / 255, Double(cmyk[2]) / 255, Double(cmyk[3]) / 255]
				case 4:  // CMY fractions
					try file.seek(4, .current)
					let cmyk = try file.readArray(count: 4)
					colorspace2 = .CMYK
					colorComponents2 = [Double(cmyk[0]) / 255, Double(cmyk[1]) / 255, Double(cmyk[2]) / 255]
				case 5, 21:	// BGR fractions
					try file.seek(4, .current)
					let bgr = try file.readArray(count: 3)
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
					colorName = try file.readAsciiString(count: Int(nameLength))
				}
				else {
					colorName = try file.readUTF16String(.little, count: Int(nameLength))
				}
			}

			if let colorspace = colorspace, let colorComponents = colorComponents {
				let readColor = try PAL.Color(
					name: colorName,
					colorSpace: colorspace,
					colorComponents: colorComponents.map { Float32($0) },
					colorType: spot ? .spot : .normal
				)
				result.colors.append(readColor)
			}

			if let colorspace = colorspace2, let colorComponents = colorComponents2 {
				let readColor = try PAL.Color(
					name: colorName,
					colorSpace: colorspace,
					colorComponents: colorComponents.map { Float32($0) },
					colorType: spot ? .spot : .normal
				)
				result.colors.append(readColor)
			}

			if version == 0xCDDD {
				// row and column?  -- just skip (but we have to read them to move the read pointer to the
				// correct next color
				let _ /*row*/: UInt32 = try file.readInteger(.little)
				let _ /*col*/: UInt32 = try file.readInteger(.little)
				let _ /*unknown*/: UInt32 = try file.readInteger(.little)
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
	static let cpl = UTType("com.corel.cpl")!
}
#endif
