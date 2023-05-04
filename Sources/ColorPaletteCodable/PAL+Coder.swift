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
	PAL.Coder.ACB(),
	PAL.Coder.ACO(),
	PAL.Coder.ASE(),
	PAL.Coder.CLR(),
	PAL.Coder.RGB(),
	PAL.Coder.RGBA(),
	PAL.Coder.JSON(),
	PAL.Coder.GIMP(),
	PAL.Coder.PaintShopPro(),
	PAL.Coder.ACT(),
	PAL.Coder.RIFF(),
	PAL.Coder.SketchPalette(),
	PAL.Coder.XMLPalette(),
	PAL.Coder.HEX()
]

public extension PAL.Palette {
	/// Returns a coder for the specified fileExtension
	static func coder(for fileExtension: String) -> [PAL_PaletteCoder] {
		let lext = fileExtension.lowercased()
		return AvailableCoders.filter({ $0.fileExtension.contains(lext) })
	}
	
	/// Returns a coder for the specified fileURL
	static func coder(for fileURL: URL) -> [PAL_PaletteCoder] {
		let lext = fileURL.pathExtension.lowercased()
		return AvailableCoders.filter({ $0.fileExtension.contains(lext) })
	}

	/// Returns the first coder for the file type
	@inlinable static func firstCoder(for fileExtension: String) -> PAL_PaletteCoder? {
		PAL.Palette.coder(for: fileExtension).first
	}

	/// Returns the first coder for the file type
	@inlinable static func firstCoder(for fileURL: URL) -> PAL_PaletteCoder? {
		PAL.Palette.coder(for: fileURL).first
	}
	
	/// Decode a palette from the contents of a fileURL
	/// - Parameters:
	///   - fileURL: The file to load
	///   - coder: If set, provides a coder to use instead if using the fileURL extension
	/// - Returns: A palette
	static func Decode(from fileURL: URL, usingCoder coder: PAL_PaletteCoder? = nil) throws -> PAL.Palette {
		let coders: [PAL_PaletteCoder] = try {
			if let coder = coder {
				return [coder]
			}

			let coders = self.coder(for: fileURL.pathExtension)
			guard coders.count > 0 else {
				throw PAL.CommonError.unsupportedCoderType
			}

			return coders
		}()

		var lastError: Error = PAL.CommonError.unsupportedPaletteType

		// Loop through coders that support this path extension and try each one until one works
		for coder in coders {
			do {
				return try coder.decode(from: fileURL)
			}
			catch {
				lastError = error
			}
		}

		// None of our coders worked
		throw lastError
	}
	
	/// Decode a palette from the contents of a fileURL
	/// - Parameters:
	///   - data: The data
	///   - fileExtension: The expected file extension for the data
	/// - Returns: A palette
	static func Decode(from data: Data, fileExtension: String) throws -> PAL.Palette {
		let coders = self.coder(for: fileExtension)
		guard coders.count > 0 else {
			throw PAL.CommonError.unsupportedCoderType
		}

		// Loop through coders that support this path extension and try each one until one works
		for coder in coders {
			do {
				return try coder.decode(from: data)
			}
			catch {

			}
		}

		// None of our coders worked
		throw PAL.CommonError.unsupportedPaletteType
	}
	
//	/// Encode the specified palette using the specified coder
//	/// - Parameters:
//	///   - palette: The palette to encode
//	///   - fileExtension: The coder to use for the encoded data
//	/// - Returns: The encoded data
//	static func Encode(_ palette: PAL.Palette, fileExtension: String) throws -> Data {
//		guard let coder = self.coder(for: fileExtension) else {
//			throw PAL.CommonError.unsupportedCoderType
//		}
//		return try coder.encode(palette)
//	}
}
