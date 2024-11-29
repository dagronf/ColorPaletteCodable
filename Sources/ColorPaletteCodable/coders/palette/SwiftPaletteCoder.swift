//
//  SVGPaletteCoder.swift
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

#if !os(Linux)

public extension PAL.Coder {

	struct SwiftCoder: PAL_PaletteCoder {
		public let name = "Swift Palette Code Generator"
		public let fileExtension = ["swift"]
	}
}

public extension PAL.Coder.SwiftCoder {
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		ColorPaletteLogger.log(.error, "Swift Coder: decode() not implemented")
		throw PAL.CommonError.notImplemented
	}
}

private let formatter_: NumberFormatter = {
	let format = NumberFormatter()
	format.maximumFractionDigits = 4
	format.minimumFractionDigits = 4
	format.decimalSeparator = "."
	return format
}()

public extension PAL.Coder.SwiftCoder {
	func encode(_ palette: PAL.Palette) throws -> Data {
		func mapColors(_ group: PAL.Group, offset: Int) throws -> String {
			let mapped = try group.colors
				.compactMap { try $0.converted(to: .RGB) }
				.map { try $0.rgbValues() }
			if mapped.count == 0 { return "" }

			var result = "   // Group (\(group.name))\n"
			result    += "   static let group\(offset): [CGColor] = ["
			for item in mapped.enumerated() {
				if item.0 % 8 == 0 {
					result += "\n     "
				}

				let rs = formatter_.string(for: item.1.r)!
				let gs = formatter_.string(for: item.1.g)!
				let bs = formatter_.string(for: item.1.b)!
				let aas = formatter_.string(for: item.1.a)!
				result += " #colorLiteral(red: \(rs), green: \(gs), blue: \(bs), alpha: \(aas)),"
			}
			result += "\n   ]\n\n"
			return result
		}

		var result = "struct ExportedPalettes {\n"

		try palette.allGroups.enumerated().forEach { element in
			result += try mapColors(element.1, offset: element.0)
		}

		result += "}\n"

		guard let data = result.data(using: .utf8) else {
			throw PAL.CommonError.invalidString
		}
		return data
	}
}

#endif
