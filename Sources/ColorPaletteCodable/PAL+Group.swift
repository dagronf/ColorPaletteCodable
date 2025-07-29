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

public extension PAL {
	/// A grouping of colors
	struct Group: Equatable, Codable {
		public let id = UUID()
		/// The group name
		public var name: String
		/// The colors assigned to the group
		public internal(set) var colors: [PAL.Color]
		/// Create a group with the specified name and colors
		/// - Parameters:
		///   - colors: The colors in the group
		///   - name: The group's name
		public init(colors: [PAL.Color] = [], name: String = "") {
			self.name = name
			self.colors = colors
		}
	}
}

@available(macOS 10.15, *)
extension PAL.Group: Identifiable { }

extension PAL.Group: Hashable { 
	public func hash(into hasher: inout Hasher) { hasher.combine(self.id) }
}

// MARK: - Methods

public extension PAL.Group {
	/// Generate an array of RGB-encoded hex strings for each color in the group
	/// - Parameters:
	///   - hashmark: If true, includes a hashmark at the beginning
	///   - uppercase: If true, uses uppercase characters
	/// - Returns: An array of hex RGBA strings
	@inlinable
	func hexRGB(hashmark: Bool, uppercase: Bool = false) throws -> [String] {
		try self.colors.map {
			try $0.hexRGB(hashmark: hashmark, uppercase: uppercase)
		}
	}

	/// Generate an array of RGBA-encoded hex strings for each color in the group
	/// - Parameters:
	///   - hashmark: If true, includes a hashmark at the beginning
	///   - uppercase: If true, uses uppercase characters
	/// - Returns: An array of hex RGBA strings
	@inlinable
	func hexRGBA(hashmark: Bool, uppercase: Bool = false) throws -> [String] {
		try self.colors.map {
			try $0.hexRGBA(hashmark: hashmark, uppercase: uppercase)
		}
	}
}

// MARK: - Coding

extension PAL.Group {
	enum CodingKeys: String, CodingKey {
		case name
		case colors
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		self.colors = try container.decode([PAL.Color].self, forKey: .colors)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		if !name.isEmpty { try container.encode(name, forKey: .name) }
		try container.encode(colors, forKey: .colors)
	}

	public static func == (lhs: PAL.Group, rhs: PAL.Group) -> Bool {
		return
			lhs.name == rhs.name &&
			lhs.colors == rhs.colors
	}
}
