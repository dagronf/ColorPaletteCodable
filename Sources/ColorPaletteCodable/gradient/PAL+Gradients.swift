//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

// MARK: Multi gradient definition

public extension PAL {
	/// A collection of gradients
	struct Gradients {
		/// The gradients
		public var gradients: [Gradient]

		/// If the gradient was populated from a file, the format of the loaded file
		public internal(set) var format: PAL.GradientsFormat? = nil

		/// The number of gradients
		@inlinable public var count: Int { gradients.count }
		/// Create a collection of gradients
		public init(gradients: [Gradient] = []) {
			self.gradients = gradients
		}

		/// Create with a single gradient
		@inlinable public init(gradient: Gradient) {
			self.gradients = [gradient]
		}

		/// Return a palette containing all the gradients as mapped color groups
		public var palette: PAL.Palette {
			let grs = gradients.map { gradient in
				PAL.Group(colors: gradient.sorted.colors, name: gradient.name ?? "")
			}
			return PAL.Palette(colors: [], groups: grs)
		}

		/// Locate a gradient via its id.
		@inlinable public func find(id: UUID) -> PAL.Gradient? {
			self.gradients.first { $0.id == id }
		}

		/// Map all the gradients to a 0 -> 1 range
		public func expandAllGradientsToEdges() -> PAL.Gradients {
			PAL.Gradients(gradients: self.gradients.map { $0.expandGradientToEdges() })
		}
	}
}

extension PAL.Gradients {
	/// Create from a single gradient and a format
	/// - Parameters:
	///   - gradient: The gradient
	///   - format: The format
	internal init(gradient: PAL.Gradient, format: PAL.GradientsFormat) {
		self.gradients = [gradient]
		self.format = format
	}

	/// Create with a format
	/// - Parameters:
	///   - format: The format
	internal init(format: PAL.GradientsFormat) {
		self.gradients = []
		self.format = format
	}
}

// MARK: - Codable support

extension PAL.Gradients: Codable {
	public struct Coder {
		// Hide the init
		private init() {}
	}

	enum CodingKeys: String, CodingKey {
		case gradients
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.gradients = try container.decode([PAL.Gradient].self, forKey: .gradients)
		self.format = .json
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.gradients, forKey: .gradients)
	}
}

// MARK: - Load from file/data

public extension PAL.Gradients {

	// MARK: Create from file URL

	/// Load a local gradient file
	/// - Parameters:
	///   - fileURL: The local fileURL for the gradients file
	///   - coder: [optional] Override the default gradients coder
	init(_ fileURL: URL, usingCoder coder: PAL_GradientsCoder? = nil) throws {
		let decoded = try PAL.Gradients.Decode(from: fileURL, usingCoder: coder)
		self.gradients = decoded.gradients
		self.format = decoded.format
	}

	/// Load a local gradient file
	/// - Parameters:
	///   - fileURL: The local fileURL for the gradients file
	///   - format: The file's gradient format
	@inlinable init(_ fileURL: URL, format: PAL.GradientsFormat) throws {
		try self.init(fileURL, usingCoder: format.coder)
	}

	// MARK: Create from data

	/// Load a gradient from raw data
	/// - Parameters:
	///   - data: The gradient data
	///   - coder: The gradient coder to use when decoding
	init(_ data: Data, usingCoder coder: PAL_GradientsCoder) throws {
		let g = try coder.decode(from: data)
		self.gradients = g.gradients
		self.format = g.format
	}

	/// Load a gradient from raw data
	/// - Parameters:
	///   - data: The gradient data
	///   - format: The file's gradient format
	init(_ data: Data, format: PAL.GradientsFormat) throws {
		try self.init(data, usingCoder: format.coder)
	}

	/// Load a gradient from raw data
	/// - Parameters:
	///   - data: The gradient data
	///   - fileExtension: The gradient file's extension (eg. "ggr")
	init(_ data: Data, fileExtension: String) throws {
		let g = try PAL.Gradients.Decode(from: data, fileExtension: fileExtension)
		self.gradients = g.gradients
		self.format = g.format
	}
}

// MARK: - Export formatted gradients data

public extension PAL.Gradients {
	/// Export the gradient
	/// - Parameter coder: The gradient coder to use
	/// - Returns: raw gradient format data
	@inlinable func export(using coder: PAL_GradientsCoder) throws -> Data {
		return try coder.encode(self)
	}

	/// Export the gradient
	/// - Parameter format: The gradient format
	/// - Returns: raw gradient format data
	@inlinable func export(format: PAL.GradientsFormat) throws -> Data {
		try self.export(using: format.coder)
	}

	/// Export the gradient
	/// - Parameter fileExtension: The file extension representing the coder type
	/// - Returns: raw gradient format data
	func export(fileExtension: String) throws -> Data {
		guard let coder = PAL.Gradients.coder(for: fileExtension) else {
			throw PAL.CommonError.unsupportedCoderType
		}
		return try self.export(using: coder)
	}
}
