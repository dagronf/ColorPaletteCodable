//
//  PAL+CoderProtocol.swift
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

public extension PAL {
	/// Coder namespace
	class Coder { }
}

/// A Palette coder protocol
public protocol PAL_PaletteCoder {
	/// The extension for the file, or a unique name for identifying the coder type.
	var fileExtension: String { get }

	/// Create a palette from an input stream
	func create(from inputStream: InputStream) throws -> PAL.Palette

	/// Write the palette to data
	func data(for palette: PAL.Palette) throws -> Data
}

extension PAL_PaletteCoder {
	/// Load from the contents of a fileURL
	func create(from fileURL: URL) throws -> PAL.Palette {
		guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
			throw PAL.CommonError.unableToLoadFile
		}
		inputStream.open()
		return try create(from: inputStream)
	}

	/// Load from data
	func create(from data: Data) throws -> PAL.Palette {
		let inputStream = InputStream(data: data)
		inputStream.open()
		return try create(from: inputStream)
	}

	/// Return the encoded palette
	func data(_ palette: PAL.Palette) throws -> Data {
		return try self.data(for: palette)
	}
}
