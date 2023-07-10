//
//  ACTPaletteCoder.swift
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

/// An ACT file reader (Adobe Color Table)
/// UTI: com.adobe.act
public extension PAL.Coder {
	struct ACT: PAL_PaletteCoder {
		public let fileExtension = ["act"]
		public init() {}
	}
}

extension PAL.Coder.ACT {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// NOTE: Assumption here is that `inputStream` is already open
		// If the input stream isn't open, the reading will hang.

		var result = PAL.Palette()

		// The file is 768 or 772 bytes long and contains 256 RGB colors
		try (0 ..< 256).forEach { _ in
			let rgb = try readData(inputStream, size: 3)
			let r = UInt8(rgb[0])
			let g = UInt8(rgb[1])
			let b = UInt8(rgb[2])
			let color = try PAL.Color(r: r, g: g, b: b, a: 255)
			result.colors.append(color)
		}

		if let numColors: Int16 = try? readIntegerBigEndian(inputStream) {
			// Two bytes for the number of colors to use
			let prefix = [PAL.Color](result.colors.prefix(Int(numColors)))
			result.colors = prefix
		}

		if let alphaIndex: Int16 = try? readIntegerBigEndian(inputStream),
			alphaIndex >= 0 && alphaIndex < result.colors.count
		{
			let index = Int(alphaIndex)
			// Two bytes for the color index with the transparency color to use
			let alpha = try result.colors[index].withAlpha(0)
			result.colors[index] = alpha
		}

		return result
	}
}

extension PAL.Coder.ACT {
	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	public func encode(_ palette: PAL.Palette) throws -> Data {
		var outputData = Data(capacity: 1024)

		// Flatten _all_ the colors in the palette (including global and group colors) to an RGB list
		let flattenedColors = try palette.allColors().map { try $0.converted(to: .RGB) }

		// This format only supports 256 colors max
		let colors = flattenedColors.prefix(256)
		let maxColors = colors.count

		try (0 ..< 256).forEach { index in
			if index < maxColors {
				// All colors in the ACT table are RGB
				let c = try flattenedColors[index].converted(to: .RGB)
				let cc = try c.rgbValues()
				outputData.append(UInt8(cc.r * 255.0))
				outputData.append(UInt8(cc.g * 255.0))
				outputData.append(UInt8(cc.b * 255.0))
			}
			else {
				outputData.append(0)
				outputData.append(0)
				outputData.append(0)
			}
		}

		if maxColors < 256 {
			outputData.append(try writeUInt16BigEndian(UInt16(maxColors)))
			outputData.append(try writeUInt16BigEndian(UInt16(0xFFFF)))
		}

		return outputData
	}
}

