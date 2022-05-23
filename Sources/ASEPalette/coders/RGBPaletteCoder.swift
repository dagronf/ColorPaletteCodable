//
//  RGBPaletteCoder.swift
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

/// A simple RGB plain text file importer. Any 'A' component is ignored
///
/// Format of the form
/// ```
/// #fcfc80
/// #fcfc80
/// #fcf87c
/// #fcf87c
/// #fcf478
/// #f8f478
/// ```
public extension ASE.Coder {
	struct RGB: PaletteCoder {
		public let fileExtension = "rgb"
	}
}

extension ASE.Coder.RGB {
	public func read(_ inputStream: InputStream) throws -> ASE.Palette {
		let data = inputStream.readAllData()
		guard let text = String(data: data, encoding: .utf8) else {
			throw ASE.CommonError.unableToLoadFile
		}
		let lines = text.split(separator: "\n")
		var palette = ASE.Palette()
		try lines.forEach { line in
			let l = line.trimmingCharacters(in: CharacterSet.whitespaces)

			if l.isEmpty {
				// Skip over empty lines
				return
			}

			do {
				// Try with rgba, and if it throws try rgb
				let color = try ASE.Color(rgbaHexString: l)
				palette.colors.append(color)
			}
			catch {
				// Try with rgb
				let color = try ASE.Color(rgbHexString: l)
				palette.colors.append(color)
			}
		}
		return palette
	}

	public func data(for palette: ASE.Palette) throws -> Data {
		var result = ""
		for color in palette.colors {
			if !result.isEmpty { result += "\n" }
			guard let h = color.hexRGB else {
				throw ASE.CommonError.unsupportedColorSpace
			}
			result += h
		}
		guard let d = result.data(using: .utf8) else {
			throw ASE.CommonError.unsupportedColorSpace
		}
		return d
	}
}
