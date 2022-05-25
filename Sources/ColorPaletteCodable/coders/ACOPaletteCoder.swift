//
//  ACOPaletteCoder.swift
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

// An object representing an ACO (Adobe Photoshop Swatch)
//
// Based on the discussion here: https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#50577411_pgfId-1070626
public extension PAL.Coder {
	struct ACO: PAL_PaletteCoder {
		public let fileExtension = "aco"
		public init() {}
	}
}

// MARK: - Internal definitions

// ACO colorspace definitions
private enum ACO_Colorspace: UInt16 {
	case RGB = 0
	case HSB = 1 // Lightness is a 16-bit value from 0...10000. Chrominance components are each 16-bit values from -12800...12700. Gray values are represented by chrominance components of 0. Pure white = 10000,0,0.
	case CMYK = 2 // 0 = 100% ink. For example, pure cyan = 0,65535,65535,65535.
	case LAB = 7 // Lightness is a 16-bit value from 0...10000. Chrominance components are each 16-bit values from -12800...12700. Gray values are represented by chrominance components of 0. Pure white = 10000,0,0.
	case Grayscale = 8 // The first value in the color data is the gray value, from 0...10000.
}

// MARK: - Load/Save

public extension PAL.Coder.ACO {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		var result = PAL.Palette()

		var v1Colors = [PAL.Color]()
		var v2Colors = [PAL.Color]()

		try (1 ... 2).forEach { type in
			do {
				let version: UInt16 = try readIntegerBigEndian(inputStream)
				if version != type {
					throw PAL.CommonError.invalidVersion
				}
			}
			catch {
				// Version 1 file only (no data after v1 section)
				result.colors = v1Colors
				return
			}

			let numberOfColors: UInt16 = try readIntegerBigEndian(inputStream)

			try (0 ..< numberOfColors).forEach { index in

				let colorSpace: UInt16 = try readIntegerBigEndian(inputStream)
				guard let cs = ACO_Colorspace(rawValue: colorSpace) else {
					throw PAL.CommonError.unsupportedColorSpace
				}

				let c0: UInt16 = try readIntegerBigEndian(inputStream)
				let c1: UInt16 = try readIntegerBigEndian(inputStream)
				let c2: UInt16 = try readIntegerBigEndian(inputStream)
				let c3: UInt16 = try readIntegerBigEndian(inputStream)

				let name: String = try {
					if type == 2 {
						return try readPascalStyleUnicodeString(inputStream)
					}
					return ""
				}()

				var color: PAL.Color

				switch cs {
				case .RGB:
					color = try PAL.Color(name: name, colorSpace: .RGB, colorComponents: [Float32(c0) / 65535.0, Float32(c1) / 65535.0, Float32(c2) / 65535.0])
				case .CMYK:
					color = try PAL.Color(
						name: name,
						colorSpace: .CMYK,
						colorComponents: [
							Float32(65535 - c0) / 65535.0,
							Float32(65535 - c1) / 65535.0,
							Float32(65535 - c2) / 65535.0,
							Float32(65535 - c3) / 65535.0,
						]
					)
				case .Grayscale:
					assert(c0 <= 10000)
					color = try PAL.Color(name: name, colorSpace: .Gray, colorComponents: [Float32(c0) / 10000])

				case .LAB:
					throw PAL.CommonError.unsupportedColorSpace
				case .HSB:
					throw PAL.CommonError.unsupportedColorSpace
				}

				if type == 1 {
					v1Colors.append(color)
				}
				else if type == 2 {
					v2Colors.append(color)
				}
				else {
					throw PAL.CommonError.invalidVersion
				}
			}
		}

		// If we got here, then we have a v2 file
		if v2Colors.count > 0 {
			result.colors = v2Colors
		}
		return result
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		var outputData = Data(capacity: 1024)

		// Write out both v1 and v2 colors
		try (1 ... 2).forEach { type in
			outputData.append(try writeUInt16BigEndian(UInt16(type)))

			outputData.append(try writeUInt16BigEndian(UInt16(palette.colors.count)))

			for color in palette.colors {
				var c0: UInt16 = 0
				var c1: UInt16 = 0
				var c2: UInt16 = 0
				var c3: UInt16 = 0

				let acoModel: ACO_Colorspace
				switch color.colorSpace {
				case .RGB:
					acoModel = .RGB
					c0 = UInt16(65535 * color.colorComponents[0])
					c1 = UInt16(65535 * color.colorComponents[1])
					c2 = UInt16(65535 * color.colorComponents[2])
				case .CMYK:
					acoModel = .CMYK
					c0 = UInt16(65535 - UInt16(65535 * color.colorComponents[0]))
					c1 = UInt16(65535 - UInt16(65535 * color.colorComponents[1]))
					c2 = UInt16(65535 - UInt16(65535 * color.colorComponents[2]))
					c3 = UInt16(65535 - UInt16(65535 * color.colorComponents[3]))
				case .Gray:
					acoModel = .CMYK
					c0 = UInt16(10000 * color.colorComponents[0])

				case .LAB:
					throw PAL.CommonError.unsupportedColorSpace
				}

				outputData.append(try writeUInt16BigEndian(UInt16(acoModel.rawValue)))

				outputData.append(try writeUInt16BigEndian(c0))
				outputData.append(try writeUInt16BigEndian(c1))
				outputData.append(try writeUInt16BigEndian(c2))
				outputData.append(try writeUInt16BigEndian(c3))

				if type == 2 {
					outputData.append(try writePascalStyleUnicodeString(color.name))
				}
			}
		}
		return outputData
	}
}
