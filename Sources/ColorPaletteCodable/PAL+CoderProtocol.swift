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
	func decode(from inputStream: InputStream) throws -> PAL.Palette

	/// Write the palette to data
	func encode(_ palette: PAL.Palette) throws -> Data
}

public extension PAL_PaletteCoder {
	/// Create a palette object from the contents of a fileURL
	/// - Parameter fileURL: The file containing the palette
	/// - Returns: A palette object
	func decode(from fileURL: URL) throws -> PAL.Palette {
		guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
			throw PAL.CommonError.unableToLoadFile
		}
		inputStream.open()
		return try decode(from: inputStream)
	}

	/// Create a palette object from the provided data
	/// - Parameter data: The encoded palette
	/// - Returns: A palette object
	func decode(from data: Data) throws -> PAL.Palette {
		let inputStream = InputStream(data: data)
		inputStream.open()
		return try decode(from: inputStream)
	}
}
