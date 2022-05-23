//
//  PAL+LoadSave.swift
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

private let AvailableCoders: [PAL_PaletteCoder] = [
	PAL.Coder.ASE(),
	PAL.Coder.ACO(),
	PAL.Coder.CLR(),
	PAL.Coder.RGB(),
	PAL.Coder.RGBA(),
]

public extension PAL.Palette {
	/// Returns a coder for the specified fileExtension
	static func coder(for fileExtension: String) -> PAL_PaletteCoder? {
		let lext = fileExtension.lowercased()
		return AvailableCoders.first(where: { $0.fileExtension == lext })
	}
	
	/// Returns a coder for the specified fileURL
	static func coder(for fileURL: URL) -> PAL_PaletteCoder? {
		let lext = fileURL.pathExtension.lowercased()
		return AvailableCoders.first(where: { $0.fileExtension == lext })
	}
	
	/// Create a palette from the contents of a fileURL
	/// - Parameters:
	///   - fileURL: The file to load
	///   - forcedExtension: If set, overrides the coder used for loading to `forcedExtension` rather than the fileURL extension
	/// - Returns: A palette
	static func Create(from fileURL: URL, forcedExtension: String? = nil) throws -> PAL.Palette {
		let extn = forcedExtension ?? fileURL.pathExtension
		guard let coder = self.coder(for: extn) else {
			throw PAL.CommonError.unsupportedCoderType
		}
		return try coder.create(from: fileURL)
	}
	
	/// Load a palette from the contents of a fileURL
	/// - Parameters:
	///   - data: The data
	///   - fileExtension: The expected file extension for the data
	/// - Returns: A palette
	static func Create(from data: Data, fileExtension: String) throws -> PAL.Palette {
		guard let coder = self.coder(for: fileExtension) else {
			throw PAL.CommonError.unsupportedCoderType
		}
		return try coder.create(from: data)
	}
	
	/// Encode the specified palette using the specified coder
	/// - Parameters:
	///   - palette: The palette to encode
	///   - fileExtension: The coder to use for the encoded data
	/// - Returns: The encoded data
	static func data(_ palette: PAL.Palette, fileExtension: String) throws -> Data {
		guard let coder = self.coder(for: fileExtension) else {
			throw PAL.CommonError.unsupportedCoderType
		}
		return try coder.data(for: palette)
	}
}
