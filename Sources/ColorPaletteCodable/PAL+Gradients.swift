//
//  PAL+Gradients.swift
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

		/// Return a palette containing all the gradients as mapped color groups
		public var palette: PAL.Palette {
			let grs = gradients.map { gradient in
				PAL.Group(name: gradient.name ?? "", colors: gradient.sorted.colors)
			}
			return PAL.Palette(colors: [], groups: grs)
		}

		/// Locate a gradient via its id.
		@inlinable public func find(id: UUID) -> PAL.Gradient? {
			self.gradients.first { $0.id == id }
		}
	}
}

public extension PAL.Gradients {
	struct Coder { }
}
