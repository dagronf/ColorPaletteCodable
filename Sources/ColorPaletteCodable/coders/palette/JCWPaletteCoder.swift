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

public extension PAL.Coder {
	/// An object representing an ACB (Adobe Color Book)
	///
	/// Based on the discussion [here](https://magnetiq.ca/pages/acb-spec/)
	///
	/// [Coffeescript implementation](https://github.com/jacobbubu/acb/blob/master/decoder.coffee)
	struct JCW: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .xara
		public let name = "Xara Palette"
		public let fileExtension = ["jcw"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.xara.palette"  // conforms to `public.data`

		public init() {}
	}
}

// MARK: - Decode

public extension PAL.Coder.JCW {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let parser = BytesReader(inputStream: inputStream)
		var result = PAL.Palette(format: self.format)

		let bom = try parser.readStringASCII(length: 3)
		if bom != "JCW" {
			ColorPaletteLogger.log(.error, "JCWCoder: Invalid palette file")
			throw PAL.CommonError.invalidBOM
		}

		let version = try parser.readUInt8()
		if version != 1 {
			ColorPaletteLogger.log(.info, "JCW: Found untested version %d... decoder may not work", version)
		}

		// Number of colors?
		let numColors = try parser.readUInt16(.little)

		// Expected color space for ALL colors
		let colorSpace = try parser.readUInt8()

		// Expected length of color names
		let nameLength = try parser.readUInt8()

		enum SupportedCS {
			case cmyk
			case rgb
			case hsb
		}

		let ct: (s: SupportedCS, t: PAL.ColorType) = try {
			switch colorSpace {
			case 1: return (.cmyk, .normal)
			case 8: return (.cmyk, .normal)
			case 9: return (.cmyk, .spot)
			case 2: return (.rgb, .normal)
			case 10: return (.rgb, .normal)
			case 11: return (.rgb, .spot)
			case 3: return (.hsb, .normal)
			case 12: return (.hsb, .normal)
			case 13: return (.hsb, .spot)
			default: throw PAL.CommonError.invalidFormat
			}
		}()

		for index in (0 ..< numColors) {
			let c0 = try parser.readUInt16(.little).clamped(to: 0 ... 10000)
			let c1 = try parser.readUInt16(.little).clamped(to: 0 ... 10000)
			let c2 = try parser.readUInt16(.little).clamped(to: 0 ... 10000)
			let c3 = try parser.readUInt16(.little).clamped(to: 0 ... 10000)

			let name = try parser.readStringSingleByteEncoding(
				.isoLatin1,
				length: Int(nameLength),
				lengthIncludesTerminator: false
			).stripTrailingNulls()

			if ct.s == .rgb {
				let c = rgbf(Double(c0) / 10000, Double(c1) / 10000, Double(c2) / 10000, name: name, colorType: ct.t)
				result.colors.append(c)
			}
			else if ct.s == .cmyk {
				let c = cmykf(Double(c0) / 10000, Double(c1) / 10000, Double(c2) / 10000, Double(c3) / 10000, name: name, colorType: ct.t)
				result.colors.append(c)
			}
			else if ct.s == .hsb {
				let c = PAL.Color(hf: Double(c0) / 10000, sf: Double(c1) / 10000, bf: Double(c2) / 10000, name: name, colorType: ct.t)
				result.colors.append(c)
			}
			else {
				ColorPaletteLogger.log(.error, "JCWCoder: Unsupported color type %d at index %d", colorSpace, index)
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

		let file = try BytesWriter()

		// Palette colors (all RGB for the first attempt)
		let colors = try palette.allColors().map { try $0.converted(to: .RGB) }

		// BOM
		try file.writeStringASCII("JCW")
		// version
		try file.writeUInt8(1)

		// The number of colors (all RGB for the moment)
		try file.writeUInt16(UInt16(colors.count), .little)

		// Colorspace (basic RGB)
		try file.writeUInt8(10)

		// Name length
		try file.writeUInt8(14)

		try colors.forEach { color in
			// Color components
			let rgb = try color.rgb()
			try file.writeUInt16(UInt16(rgb.rf * 10000), .little)
			try file.writeUInt16(UInt16(rgb.gf * 10000), .little)
			try file.writeUInt16(UInt16(rgb.bf * 10000), .little)
			try file.writeUInt16(0, .little)

			// Write the name
			// * converted to iso-latin1
			// * trimmed to fit length
			guard let name = color.name.data(using: .isoLatin1) else {
				throw PAL.CommonError.invalidString
			}
			var nData = Data(name.prefix(14))
			// pad out to 14 if its shorter
			if nData.count < 14 {
				let padding = Array<UInt8>(repeating: 0x0, count: 14 - nData.count)
				nData += padding
			}
			try file.writeData(nData)
		}

		file.complete()
		return try file.data()
	}
}

// UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let xaraPalette = UTType(PAL.Coder.JCW.utTypeString)!
}
#endif
