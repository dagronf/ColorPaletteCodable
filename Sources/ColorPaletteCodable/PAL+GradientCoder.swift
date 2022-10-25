//
//  PAL+GradientCoder.swift
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

/// The built-in supported coders
private let AvailableGradientCoders: [PAL_GradientCoder] = [
	PAL.Gradient.Coder.JSON(),
	PAL.Gradient.Coder.GGR(),
]

public extension PAL.Gradient {
	struct Coder { }
}

/// A gradient coder protocol
public protocol PAL_GradientCoder {
	/// The extension for the file, or a unique name for identifying the coder type.
	static var fileExtension: String { get }

	/// The extension for the file, or a unique name for identifying the coder type.
	var fileExtension: String { get }

	/// Create a gradient from an input stream
	func decode(from inputStream: InputStream) throws -> PAL.Gradient

	/// Write the gradient to data
	func encode(_ gradient: PAL.Gradient) throws -> Data
}

public extension PAL_GradientCoder {
	/// The file extension supported by the coder
	var fileExtension: String { Self.fileExtension }

	/// Create a palette object from the contents of a fileURL
	/// - Parameter fileURL: The file containing the palette
	/// - Returns: A palette object
	func decode(from fileURL: URL) throws -> PAL.Gradient {
		guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
			throw PAL.CommonError.unableToLoadFile
		}
		inputStream.open()
		return try decode(from: inputStream)
	}

	/// Create a gradient object from the provided data
	/// - Parameter data: The encoded gradient
	/// - Returns: A gradient object
	func decode(from data: Data) throws -> PAL.Gradient {
		let inputStream = InputStream(data: data)
		inputStream.open()
		return try decode(from: inputStream)
	}
}

// MARK: - Gradient extension

public extension PAL.Gradient {

	/// Returns a gradient coder for the specified fileExtension
	static func coder(for fileExtension: String) -> PAL_GradientCoder? {
		let lext = fileExtension.lowercased()
		return AvailableGradientCoders.first(where: { $0.fileExtension == lext })
	}

	/// Decode a gradient from the contents of a fileURL
	/// - Parameters:
	///   - fileURL: The file to load
	///   - coder: If set, provides a coder to use instead if using the fileURL extension
	/// - Returns: A palette
	static func Decode(from fileURL: URL, usingCoder coder: PAL_GradientCoder? = nil) throws -> PAL.Gradient {
		let coder: PAL_GradientCoder = try {
			if let coder = coder {
				return coder
			}
			guard let coder = self.coder(for: fileURL.pathExtension) else {
				throw PAL.CommonError.unsupportedCoderType
			}
			return coder
		}()
		return try coder.decode(from: fileURL)
	}

	/// Decode a gradient from the contents of a fileURL
	/// - Parameters:
	///   - data: The data
	///   - fileExtension: The expected file extension for the data
	/// - Returns: A gradient
	static func Decode(from data: Data, fileExtension: String) throws -> PAL.Gradient {
		guard let coder = self.coder(for: fileExtension) else {
			throw PAL.CommonError.unsupportedCoderType
		}
		return try coder.decode(from: data)
	}

	/// Encode the specified gradient using the specified coder
	/// - Parameters:
	///   - palette: The palette to encode
	///   - fileExtension: The coder to use for the encoded data
	/// - Returns: The encoded data
	static func Encode(_ gradient: PAL.Gradient, fileExtension: String) throws -> Data {
		guard let coder = self.coder(for: fileExtension) else {
			throw PAL.CommonError.unsupportedCoderType
		}
		return try coder.encode(gradient)
	}

	/// Encode the gradient using the provided gradient coder
	func encode(using encoder: PAL_GradientCoder) throws -> Data {
		return try encoder.encode(self)
	}
}
