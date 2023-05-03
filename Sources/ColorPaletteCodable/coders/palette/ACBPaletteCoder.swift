//
//  ACBPaletteCoder.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
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

// An object representing an ACB (Adobe Color Book)
//
// Based on the discussion here: https://github.com/jacobbubu/acb/blob/master/decoder.coffee
public extension PAL.Coder {
	struct ACB: PAL_PaletteCoder {
		public let fileExtension = ["acb"]
		public init() {}
	}
}

// MARK: - Internal definitions

// ACO colorspace definitions
private enum ACO_Colorspace: UInt16 {
	case RGB = 0
	case HSB = 1
	case CMYK = 2
	case LAB = 7
	case Grayscale = 8
}

// MARK: - Load/Save

public extension PAL.Coder.ACB {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		var result = PAL.Palette()

		let bom = try readAsciiString(inputStream, length: 4)
		if bom != "8BCB" {
			throw PAL.CommonError.invalidBOM
		}

		let version: UInt16 = try readIntegerBigEndian(inputStream)
		let identifier: UInt16 = try readIntegerBigEndian(inputStream)

		var title = try readPascalStyleUnicodeString(inputStream)

		if title.starts(with: "$$$") {
			title = title.components(separatedBy: "=").last ?? title
		}
		//if value.startsWith '$$$'
		//	 value = value.split('=')[1]

		result.name = title

		let prefix = try readPascalStyleUnicodeString(inputStream)
		let suffix = try readPascalStyleUnicodeString(inputStream)
		let description = try readPascalStyleUnicodeString(inputStream)

		let colorCount: UInt16 = try readIntegerBigEndian(inputStream)
		let pageSize: UInt16 = try readIntegerBigEndian(inputStream)
		let pageSelectorOffset: UInt16 = try readIntegerBigEndian(inputStream)
		let colorSpace: UInt16 = try readIntegerBigEndian(inputStream)

		let colorspace: PAL.ColorSpace
		let componentCount: Int
		switch colorSpace {
		case 0: // RGB
			colorspace = .RGB
			componentCount = 3
		case 2: // CMYK
			colorspace = .CMYK
			componentCount = 4
		case 7: // LAB
			colorspace = .LAB
			componentCount = 3
		case 8: // Grayscale
			colorspace = .Gray
			componentCount = 1
		default:
			throw PAL.CommonError.unsupportedColorSpace
		}

		for _ in 0 ..< colorCount {
			let colorName = try readPascalStyleUnicodeString(inputStream)
			let colorCode = try readAsciiString(inputStream, length: 6)

			let channels = try readData(inputStream, size: componentCount)

			if colorName.trimmingCharacters(in: .whitespaces).isEmpty,
				colorCode.trimmingCharacters(in: .whitespaces).isEmpty
			{
				// Skip dummy record
				continue
			}

//			colorCode = colorCode.replace /^0*(\d+)$/ , '$1'
//			colorCode = colorCode.replace 'X', '-


			let mapped = channels.map { Float32($0) }
			let components: [Float32]

			switch colorspace {
			case .CMYK:
				components = [
					(mapped[0] / 255.0).clamped(to: 0...1),  // 0...1
					(mapped[1] / 255.0).clamped(to: 0...1),  // 0...1
					(mapped[2] / 255.0).clamped(to: 0...1),  // 0...1
					(mapped[3] / 255.0).clamped(to: 0...1),  // 0...1
				]
			case .RGB:
				components = [
					(mapped[0] / 255.0).clamped(to: 0...1),  // 0...1
					(mapped[1] / 255.0).clamped(to: 0...1),  // 0...1
					(mapped[2] / 255.0).clamped(to: 0...1),  // 0...1
				]
			case .LAB:
				components = [
					mapped[0] / 2.55,   // 0...100
					mapped[1] - 128,    // -128...128
					mapped[2] - 128,    // -128...128
				]
			case .Gray:
				components = [
					(mapped[0] / 255.0).clamped(to: 0...1)
				]
			}

			let color = try PAL.Color(name: colorName, colorSpace: colorspace, colorComponents: components)
			result.colors.append(color)
		}

		let spotIdentifier = try readAsciiString(inputStream, length: 8)



//		try (1 ... 2).forEach { type in
//			do {
//				let version: UInt16 = try readIntegerBigEndian(inputStream)
//				if version != type {
//					throw PAL.CommonError.invalidVersion
//				}
//			}
//			catch {
//				// Version 1 file only (no data after v1 section)
//				result.colors = v1Colors
//				return
//			}
//
//			let numberOfColors: UInt16 = try readIntegerBigEndian(inputStream)
//
//			try (0 ..< numberOfColors).forEach { index in
//
//				let colorSpace: UInt16 = try readIntegerBigEndian(inputStream)
//				guard let cs = ACO_Colorspace(rawValue: colorSpace) else {
//					Swift.print("ACOPaletteCoder: Unsupported colorspace \(colorSpace)")
//					throw PAL.CommonError.unsupportedColorSpace
//				}
//
//				let c0: UInt16 = try readIntegerBigEndian(inputStream)
//				let c1: UInt16 = try readIntegerBigEndian(inputStream)
//				let c2: UInt16 = try readIntegerBigEndian(inputStream)
//				let c3: UInt16 = try readIntegerBigEndian(inputStream)
//
//				let name: String = try {
//					if type == 2 {
//						return try readPascalStyleUnicodeString(inputStream)
//					}
//					return ""
//				}()
//
//				var color: PAL.Color
//
//				switch cs {
//				case .RGB:
//					color = try PAL.Color(name: name, colorSpace: .RGB, colorComponents: [Float32(c0) / 65535.0, Float32(c1) / 65535.0, Float32(c2) / 65535.0])
//				case .CMYK:
//					color = try PAL.Color(
//						name: name,
//						colorSpace: .CMYK,
//						colorComponents: [
//							Float32(65535 - c0) / 65535.0,
//							Float32(65535 - c1) / 65535.0,
//							Float32(65535 - c2) / 65535.0,
//							Float32(65535 - c3) / 65535.0,
//						]
//					)
//				case .Grayscale:
//					assert(c0 <= 10000)
//					color = try PAL.Color(name: name, colorSpace: .Gray, colorComponents: [Float32(c0) / 10000])
//
//				case .LAB:
//					Swift.print("ACOPaletteCoder: Unsupported colorspace LAB")
//					throw PAL.CommonError.unsupportedColorSpace
//				case .HSB:
//					Swift.print("ACOPaletteCoder: Unsupported colorspace HSB")
//					throw PAL.CommonError.unsupportedColorSpace
//				}
//
//				if type == 1 {
//					v1Colors.append(color)
//				}
//				else if type == 2 {
//					v2Colors.append(color)
//				}
//				else {
//					Swift.print("ACOPaletteCoder: Unexpected version \(type)")
//					throw PAL.CommonError.invalidVersion
//				}
//			}
//		}
//
//		// If we got here, then we have a v2 file
//		if v2Colors.count > 0 {
//			result.colors = v2Colors
//		}
		return result
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		var outputData = Data(capacity: 1024)

		throw PAL.CommonError.unsupportedCoderType

//		// Write out both v1 and v2 colors
//		try (1 ... 2).forEach { type in
//			outputData.append(try writeUInt16BigEndian(UInt16(type)))
//			outputData.append(try writeUInt16BigEndian(UInt16(palette.colors.count)))
//
//			for color in palette.colors {
//				var c0: UInt16 = 0
//				var c1: UInt16 = 0
//				var c2: UInt16 = 0
//				var c3: UInt16 = 0
//
//				let acoModel: ACO_Colorspace
//				switch color.colorSpace {
//				case .RGB:
//					acoModel = .RGB
//					c0 = UInt16(65535 * color.colorComponents[0])
//					c1 = UInt16(65535 * color.colorComponents[1])
//					c2 = UInt16(65535 * color.colorComponents[2])
//				case .CMYK:
//					acoModel = .CMYK
//					c0 = UInt16(65535 - UInt16(65535 * color.colorComponents[0]))
//					c1 = UInt16(65535 - UInt16(65535 * color.colorComponents[1]))
//					c2 = UInt16(65535 - UInt16(65535 * color.colorComponents[2]))
//					c3 = UInt16(65535 - UInt16(65535 * color.colorComponents[3]))
//				case .Gray:
//					acoModel = .CMYK
//					c0 = UInt16(10000 * color.colorComponents[0])
//
//				case .LAB:
//					throw PAL.CommonError.unsupportedColorSpace
//				}
//
//				outputData.append(try writeUInt16BigEndian(UInt16(acoModel.rawValue)))
//
//				outputData.append(try writeUInt16BigEndian(c0))
//				outputData.append(try writeUInt16BigEndian(c1))
//				outputData.append(try writeUInt16BigEndian(c2))
//				outputData.append(try writeUInt16BigEndian(c3))
//
//				if type == 2 {
//					outputData.append(try writePascalStyleUnicodeString(color.name))
//				}
//			}
//		}
		return outputData
	}
}
