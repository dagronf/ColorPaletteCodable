//
//  PAL+LoadSave.swift
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

// Conveniences for loading and saving

public extension PAL {
	/// Load a palette from a file
	/// - Parameters:
	///   - fileURL: file URL for the palette file
	///   - coder: An optional coder to use when decoding, or nil to autodetect using the file's extension
	/// - Returns: A palette
	@inlinable static func LoadPalette(_ fileURL: URL, usingCoder coder: PAL_PaletteCoder? = nil) throws -> PAL.Palette {
		try PAL.Palette.Decode(from: fileURL, usingCoder: coder)
	}

	/// Load a palette from raw data
	/// - Parameters:
	///   - data: the palette's raw data
	///   - fileExtension: The expected extension for the data (eg. "aco", "gpl" etc)
	/// - Returns: A palette
	@inlinable static func LoadPalette(_ data: Data, for fileExtension: String) throws -> PAL.Palette {
		try PAL.Palette.Decode(from: data, fileExtension: fileExtension)
	}

	/// Save a palette file to data in the format defined by `fileExtension`
	/// - Parameters:
	///   - palette: The palette to save
	///   - fileExtension: The file extension for the coder to use (eg. "gpl")
	/// - Returns: Raw data containing the gradient in the specified format
	@inlinable static func SavePalette(_ palette: PAL.Palette, for fileExtension: String) throws -> Data {
		guard let coder = PAL.Palette.coder(for: fileExtension).first else {
			throw PAL.CommonError.unsupportedPaletteType
		}
		return try coder.encode(palette)
	}
}

public extension PAL {
	/// Load a gradient from a file
	/// - Parameters:
	///   - fileURL: file URL for the gradient file
	///   - coder: An optional coder to use when decoding, or nil to autodetect using the file's extension
	/// - Returns: A gradient
	@inlinable static func LoadGradient(_ fileURL: URL, usingCoder coder: PAL_GradientsCoder? = nil) throws -> PAL.Gradients {
		try PAL.Gradients.Decode(from: fileURL, usingCoder: coder)
	}

	/// Load a gradient from raw data
	/// - Parameters:
	///   - data: the gradient's raw data
	///   - fileExtension: The expected extension for the data (eg. "ggr", "grd" etc)
	/// - Returns: A gradient
	@inlinable static func LoadGradient(_ data: Data, for fileExtension: String) throws -> PAL.Gradients {
		try PAL.Gradients.Decode(from: data, fileExtension: fileExtension)
	}

	/// Save a gradient file to data in the format defined by `fileExtension`
	/// - Parameters:
	///   - gradient: The gradient to save
	///   - fileExtension: The file extension for the coder to use (eg. "ggr")
	/// - Returns: Raw data containing the gradient in the specified format
	@inlinable static func SaveGradient(_ gradient: PAL.Gradients, for fileExtension: String) throws -> Data {
		guard let coder = PAL.Gradients.coder(for: fileExtension) else {
			throw PAL.CommonError.unsupportedPaletteType
		}
		return try coder.encode(gradient)
	}
}
