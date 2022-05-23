//
//  ASEPalette+Factory.swift
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

public extension ASE {
	class Factory {
		/// A shared instance of the factory
		public static let shared = ASE.Factory()

		/// The supported coders
		lazy var engines: [String: PaletteCoder] = [
			self.ase.fileExtension.lowercased(): self.ase,
			self.aco.fileExtension.lowercased(): self.aco,
			self.clr.fileExtension.lowercased(): self.clr,
		]

		public let ase: PaletteCoder = ASEPaletteCoder()
		public let aco: PaletteCoder = ACOPaletteCoder()
		public let clr: PaletteCoder = CLRPaletteCoder()

		/// Returns a coder for the given file extension type. If a coder cannot be found, returns nil
		public func coder(for fileExtension: String) -> PaletteCoder? {
			return self.engines[fileExtension.lowercased()]
		}

		/// Load a palette from the contents of a fileURL
		/// - Parameters:
		///   - fileURL: The file to load
		///   - extn: The extension for determining the coder type, or nil to use the file's extension
		/// - Returns: A palette
		public func load(fileURL: URL, usingExtension extn: String? = nil) throws -> ASE.Palette {
			let pathExtension = extn ?? fileURL.pathExtension
			guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
				throw ASE.CommonError.unableToLoadFile
			}
			return try self.load(fileExtension: pathExtension, inputStream: inputStream)
		}

		/// Load a palette from data
		///
		/// This function uses the specified fileExtension to determine the coder type to use
		public func load(fileExtension: String, data: Data) throws -> ASE.Palette {
			let inputStream = InputStream(data: data)
			return try self.load(fileExtension: fileExtension, inputStream: inputStream)
		}

		/// Load a palette from an inputstream.
		///
		/// This function uses the specified fileExtension to determine the coder type to use
		public func load(fileExtension: String, inputStream: InputStream) throws -> ASE.Palette {
			guard let engine = self.engines[fileExtension.lowercased()] else {
				throw ASE.CommonError.unsupportedPaletteType
			}
			inputStream.open()
			return try engine.read(inputStream)
		}

		/// Encode the specified palette using the specified coder
		/// - Parameters:
		///   - palette: The palette to encode
		///   - fileExtension: The coder to use for the encoded data
		/// - Returns: The encoded data
		public func data(_ palette: ASE.Palette, _ fileExtension: String) throws -> Data {
			guard let engine = self.engines[fileExtension.lowercased()] else {
				throw ASE.CommonError.unsupportedPaletteType
			}
			return try engine.data(for: palette)
		}
	}
}
