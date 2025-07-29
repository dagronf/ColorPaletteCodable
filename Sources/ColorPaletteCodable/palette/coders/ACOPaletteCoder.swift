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

// An object representing an ACO (Adobe Photoshop Swatch)
//
// Based on the discussion here: https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#50577411_pgfId-1070626
public extension PAL.Coder {
	struct ACO: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .aco
		public let name = "Adobe Photoshop Swatch"
		public let fileExtension = ["aco"]
		public static let utTypeString = "com.adobe.aco"  // conforms to `public.data`
		public init() {}
	}
}

// MARK: - Internal definitions

// ACO colorspace definitions
private enum ACO_Colorspace: UInt16 {
	case RGB = 0
	case HSB = 1 // The first three values in the color data are hue, saturation, and brightness. They are full unsigned 16-bit values as in Apple's HSVColor data structure. Pure red = 0,65535, 65535.
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
		let parser = BytesReader(inputStream: inputStream)
		var result = PAL.Palette(format: self.format)

		var v1Colors = [PAL.Color]()
		var v2Colors = [PAL.Color]()

		try (1 ... 2).forEach { type in
			do {
				let version: UInt16 = try parser.readUInt16(.big)
				if version != type {
					throw PAL.CommonError.invalidVersion
				}
			}
			catch {
				// Version 1 file only (no data after v1 section)
				result.colors = v1Colors
				return
			}

			let numberOfColors: UInt16 = try parser.readUInt16(.big)

			try (0 ..< numberOfColors).forEach { index in

				let colorSpace: UInt16 = try parser.readUInt16(.big)

				let cs = ACO_Colorspace(rawValue: colorSpace)

				let c0: UInt16 = try parser.readUInt16(.big)
				let c1: UInt16 = try parser.readUInt16(.big)
				let c2: UInt16 = try parser.readUInt16(.big)
				let c3: UInt16 = try parser.readUInt16(.big)

				let name: String = try {
					if type == 2 {
						return try parser.readAdobePascalStyleString()
					}
					return ""
				}()

				var color: PAL.Color?

				switch cs {
				case .RGB:
					color = try PAL.Color(
						colorSpace: .RGB,
						colorComponents: [Double(c0) / 65535.0, Double(c1) / 65535.0, Double(c2) / 65535.0],
						name: name
					)
				case .CMYK:
					color = try PAL.Color(
						colorSpace: .CMYK,
						colorComponents: [
							Double(65535 - c0) / 65535.0,
							Double(65535 - c1) / 65535.0,
							Double(65535 - c2) / 65535.0,
							Double(65535 - c3) / 65535.0,
						],
						name: name
					)
				case .Grayscale:
					assert(c0 <= 10000)
					color = try PAL.Color(colorSpace: .Gray, colorComponents: [Double(c0) / 10000], name: name)

				case .LAB:
					// Lightness is a 16-bit value from 0...10000
					// Chrominance components are each 16-bit values from -12800...12700
					let l0 = Double(c0) / 100.0
					let a0 = Double(c1) / 100.0
					let b0 = Double(c2) / 100.0
					color = try PAL.Color(
						colorSpace: .LAB,
						colorComponents: [l0, a0, b0],
						name: name
					)
				case .HSB:
					ColorPaletteLogger.log(.error, "ACOPaletteCoder: Unsupported color space HSB for color at index %d, converting to RGB...")
					let h = Double(c0) / 65535.0
					let s = Double(c1) / 65535.0
					let b = Double(c2) / 65535.0
					color = PAL.Color(hf: h, sf: s, bf: b, name: name)
				default:
					ColorPaletteLogger.log(.error, "ACOPaletteCoder: Unknown color space for color at index %d, inserting placeholder...", index)
					color = rgbf(1.0, 0.0, 0.0, 0.5, name: "Unsupported Colorspace")
				}

				if let color {
					if type == 1 {
						v1Colors.append(color)
					}
					else if type == 2 {
						v2Colors.append(color)
					}
					else {
						ColorPaletteLogger.log(.error, "ACOPaletteCoder: Unexpected version $d", type)
						throw PAL.CommonError.invalidVersion
					}
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
		let writer = try BytesWriter()

		// Flatten the palette -- this format doesn't support color groups
		let allColors = palette.allColors()

		// Write out both v1 and v2 colors
		try (1 ... 2).forEach { type in
			try writer.writeUInt16(UInt16(type), .big)
			try writer.writeUInt16(UInt16(allColors.count), .big)

			for color in allColors {
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
					// 0 = 100% ink. For example, pure cyan = 0,65535,65535,65535.
					acoModel = .CMYK
					c0 = UInt16(65535 - UInt16(65535 * color.colorComponents[0]))
					c1 = UInt16(65535 - UInt16(65535 * color.colorComponents[1]))
					c2 = UInt16(65535 - UInt16(65535 * color.colorComponents[2]))
					c3 = UInt16(65535 - UInt16(65535 * color.colorComponents[3]))
				case .Gray:
					acoModel = .CMYK
					c0 = UInt16(10000 * color.colorComponents[0])

				case .LAB:
					// Being lazy here. Just converting LAB colors to RGB
					acoModel = .RGB
					let converted = try color.converted(to: .RGB)
					c0 = UInt16(65535 * converted.colorComponents[0])
					c1 = UInt16(65535 * converted.colorComponents[1])
					c2 = UInt16(65535 * converted.colorComponents[2])
				}

				try writer.writeUInt16(UInt16(acoModel.rawValue), .big)

				try writer.writeUInt16(c0, .big)
				try writer.writeUInt16(c1, .big)
				try writer.writeUInt16(c2, .big)
				try writer.writeUInt16(c3, .big)

				if type == 2 {
					try writer.writeAdobePascalStyleString(color.name)
				}
			}
		}
		return try writer.data()
	}
}


#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let adobePhotoshopSwatches = UTType(PAL.Coder.ACO.utTypeString)!
}
#endif
