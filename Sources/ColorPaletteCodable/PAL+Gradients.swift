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
	struct Gradients: Codable {
		/// The gradients
		public var gradients: [Gradient]
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

public extension PAL.Gradients {
	struct Coder {
		// Hide the init
		private init() {}
	}
}

// MARK: - Import/export

public extension PAL.Gradients {
	/// Load a local gradient file
	/// - Parameters:
	///   - fileURL: The fileURL for the gradients file
	///   - coder: [optional] Override the default gradients coder
	init(_ fileURL: URL, usingCoder coder: PAL_GradientsCoder? = nil) throws {
		let g = try PAL.LoadGradient(fileURL, usingCoder: coder)
		self.gradients = g.gradients
	}

	/// Load a gradient from raw data
	/// - Parameters:
	///   - data: The gradient data
	///   - coder: The gradient coder to use when decoding
	init(_ data: Data, usingCoder coder: PAL_GradientsCoder) throws {
		let g = try coder.decode(from: data)
		self.gradients = g.gradients
	}

	/// Load a gradient from raw data
	/// - Parameters:
	///   - data: The gradient data
	///   - fileExtension: The gradient file's extension (eg. "ggr")
	init(_ data: Data, fileExtension: String) throws {
		let g = try PAL.Gradients.Decode(from: data, fileExtension: fileExtension)
		self.gradients = g.gradients
	}

	/// Export the gradient
	/// - Parameter coder: The gradient coder to use
	/// - Returns: raw gradient format data
	func export(using coder: PAL_GradientsCoder) throws -> Data {
		return try coder.encode(self)
	}
}
