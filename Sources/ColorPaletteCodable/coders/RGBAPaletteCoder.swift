//
//  RGBAPaletteCoder.swift
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

/// A simple RGBA plain text file importer
///
/// Format of the form
/// ```
/// #fcfc80aa
/// #fcf87cbb
/// #fcf47812
/// #f8f074c1
/// #f8ec7045
/// #f4ec6c67
/// #ecdc5cb3
/// ```
public extension PAL.Coder {
	struct RGBA: PAL_PaletteCoder {
		public let fileExtension = "rgba"
	}
}

extension PAL.Coder.RGBA {
	public func read(_ inputStream: InputStream) throws -> PAL.Palette {
		let data = inputStream.readAllData()
		guard let text = String(data: data, encoding: .utf8) else {
			throw PAL.CommonError.unableToLoadFile
		}
		let lines = text.split(separator: "\n")
		var palette = PAL.Palette()
		try lines.forEach { line in
			let l = line.trimmingCharacters(in: CharacterSet.whitespaces)

			if l.isEmpty {
				// Skip over empty lines
				return
			}

			do {
				// Try with rgba, and if it throws try rgb
				let color = try PAL.Color(rgbaHexString: l)
				palette.colors.append(color)
			}
			catch {
				// Fallback to trying RGB with alpha 1
				let color = try PAL.Color(rgbHexString: l)
				palette.colors.append(color)
			}
		}
		return palette
	}

	public func data(for palette: PAL.Palette) throws -> Data {
		var result = ""
		for color in palette.colors {
			if !result.isEmpty { result += "\n" }
			guard let h = color.hexRGBA else {
				throw PAL.CommonError.unsupportedColorSpace
			}
			result += h
		}
		guard let d = result.data(using: .utf8) else {
			throw PAL.CommonError.unsupportedColorSpace
		}
		return d
	}
}
