//
//  ACBPaletteCoder.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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
	/// An object representing an ACB (Adobe Color Book)
	///
	/// Based on the discussion [here](https://magnetiq.ca/pages/acb-spec/)
	///
	/// [Coffeescript implementation](https://github.com/jacobbubu/acb/blob/master/decoder.coffee)
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
			ASEPaletteLogger.log(.error, "ACBCoder: Invalid palette file")
			throw PAL.CommonError.invalidBOM
		}

		let version: UInt16 = try readIntegerBigEndian(inputStream)
		if version != 1 {
			ASEPaletteLogger.log(.info, "ACB: Found untested version %d... decoder may not work", version)
		}

		let _ /*identifier*/: UInt16 = try readIntegerBigEndian(inputStream)

		var title = try readPascalStyleUnicodeString(inputStream)

		if title.starts(with: "$$$") {
			title = title.components(separatedBy: "=").last ?? title
		}

		result.name = title

		let _ /*prefix*/ = try readPascalStyleUnicodeString(inputStream)
		let _ /*suffix*/ = try readPascalStyleUnicodeString(inputStream)
		let _ /*description*/ = try readPascalStyleUnicodeString(inputStream)

		let colorCount: UInt16 = try readIntegerBigEndian(inputStream)
		ASEPaletteLogger.log(.info, "ACBCoder: Expecting %d colors", colorCount)

		let _ /*pageSize*/: UInt16 = try readIntegerBigEndian(inputStream)
		let _ /*pageSelectorOffset*/ : UInt16 = try readIntegerBigEndian(inputStream)
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
			ASEPaletteLogger.log(.error, "ACBCoder: Colorspace %d not supported", colorSpace)
			throw PAL.CommonError.unsupportedColorSpace
		}

		for _ in 0 ..< colorCount {
			let colorName = try readPascalStyleUnicodeString(inputStream)
			let colorCode = try readAsciiString(inputStream, length: 6)

			// Color channels
			let channels = try readData(inputStream, size: componentCount)

			if colorName.trimmingCharacters(in: .whitespaces).isEmpty,
				colorCode.trimmingCharacters(in: .whitespaces).isEmpty
			{
				// Skip empty records
				continue
			}

			let mapped = channels.map { Float32($0) }
			let components: [Float32]

			switch colorspace {
			case .CMYK:
				components = [
					((255.0 - mapped[0]) / 255.0).unitClamped(),
					((255.0 - mapped[1]) / 255.0).unitClamped(),
					((255.0 - mapped[2]) / 255.0).unitClamped(),
					((255.0 - mapped[3]) / 255.0).unitClamped()
				]
			case .RGB:
				components = [
					(mapped[0] / 255.0).unitClamped(),
					(mapped[1] / 255.0).unitClamped(),
					(mapped[2] / 255.0).unitClamped(),
				]
			case .LAB:
				components = [
					mapped[0] / 2.55,   // 0...100
					mapped[1] - 128,    // -128...128
					mapped[2] - 128,    // -128...128
				]
			case .Gray:
				components = [
					(mapped[0] / 255.0).unitClamped(),
				]
			}

			let color = try PAL.Color(name: colorName, colorSpace: colorspace, colorComponents: components, alpha: 1)
			result.colors.append(color)
		}

		let _ /* spotIdentifier */ = try readAsciiString(inputStream, length: 8)

		return result
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation of the palette
	///
	/// Currently not supported for Adobe Color Book
	func encode(_ palette: PAL.Palette) throws -> Data {
		ASEPaletteLogger.log(.error, "ACBCoder: encode() not implemented")
		throw PAL.CommonError.notImplemented
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let acb = UTType("com.adobe.acb")!
}
#endif
