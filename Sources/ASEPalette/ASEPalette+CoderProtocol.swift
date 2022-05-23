//
//  ASEPalette+CoderProtocol.swift
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

/// A Palette coder protocol
public protocol PaletteCoder {
	/// The extension for the file, or a unique name for identifying the coder type.
	var fileExtension: String { get }

	/// Read the palette from an input stream
	func read(_ inputStream: InputStream) throws -> ASE.Palette

	/// Write the palette to data
	func data(for palette: ASE.Palette) throws -> Data
}

extension PaletteCoder {
	/// Load from the contents of a fileURL
	func load(fileURL: URL) throws -> ASE.Palette {
		guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
			throw ASE.CommonError.unableToLoadFile
		}
		inputStream.open()
		return try read(inputStream)
	}

	/// Load from data
	func load(data: Data) throws -> ASE.Palette {
		let inputStream = InputStream(data: data)
		inputStream.open()
		return try read(inputStream)
	}

	/// Return the encoded palette
	func data(_ palette: ASE.Palette) throws -> Data {
		return try self.data(for: palette)
	}
}
