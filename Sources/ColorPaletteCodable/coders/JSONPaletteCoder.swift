//
//  JSONPaletteCoder.swift
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

public extension PAL.Coder {
	/// A JSON encoder/decoder
	struct JSON: PAL_PaletteCoder {
		public let fileExtension = "jsoncolorpalette"

		/// Should the output be pretty-printed?
		public let prettyPrint: Bool

		/// Create a JSON coder
		/// - Parameter prettyPrint: Should the generated data be pretty printed?
		public init(prettyPrint: Bool = false) {
			self.prettyPrint = prettyPrint
		}
	}
}

public extension PAL.Coder.JSON {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let data = inputStream.readAllData()
		return try JSONDecoder().decode(PAL.Palette.self, from: data)
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		let encoder = JSONEncoder()
		if self.prettyPrint {
			encoder.outputFormatting = .prettyPrinted
		}
		return try encoder.encode(palette)
	}
}
