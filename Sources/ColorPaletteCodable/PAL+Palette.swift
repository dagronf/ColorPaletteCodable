//
//  PAL+Palette.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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

public extension PAL {
	/// A color palette
	struct Palette: Equatable, Codable {
		/// Unique object identifier
		public let id = UUID()
		/// The palette name
		public var name: String = ""

		/// Colors that are not assigned to a group ('global' colors)
		public var colors: [Color] = []

		/// Groups of colors
		public var groups = [Group]()

		/// Create an empty palette
		public init() {}

		/// Create a palette
		/// - Parameters:
		///   - name: The palette name
		///   - colors: The global colors
		///   - groups: The palettes groups
		public init(name: String = "", colors: [PAL.Color], groups: [PAL.Group] = []) {
			self.name = name
			self.colors = colors
			self.groups = groups
		}

		/// Equality
		public static func ==(lhs: Palette, rhs: Palette) -> Bool {
			lhs.name == rhs.name &&
			lhs.colors == rhs.colors &&
			lhs.groups == rhs.groups
		}
	}

	/// Palette color groups
	enum ColorGrouping {
		/// Colors at the global level within the palette
		case global
		/// Colors within a palette group
		case group(Int)
	}
}

@available(macOS 10.15, *)
extension PAL.Palette: Identifiable { }

extension PAL.Palette: Hashable { 
	public func hash(into hasher: inout Hasher) { hasher.combine(self.id) }
}

public extension PAL.Palette {
	/// Create a palette by mixing between two colors
	/// - Parameters:
	///   - name: The palette name
	///   - firstColor: The first (starting) color for the palette
	///   - lastColor: The second (ending) color for the palette
	///   - count: Number of colors to generate
	init(named name: String? = nil, firstColor: PAL.Color, lastColor: PAL.Color, count: Int) throws {
		self.init(
			name: name ?? "",
			colors: try PAL.Color.interpolate(firstColor: firstColor, lastColor: lastColor, count: count)
		)
	}
}

// MARK: - Conveniences

public extension PAL.Palette {
	/// Returns all the groups for the palette. Global colors are represented in a group called 'global'
	@inlinable var allGroups: [PAL.Group] {
		return [PAL.Group(name: "global", colors: self.colors)] + self.groups
	}

	/// Returns all the colors in the palette as a flat array of colors (all group information is lost)
	func allColors() -> [PAL.Color] {
		var results: [PAL.Color] = self.colors
		self.groups.forEach { results.append(contentsOf: $0.colors) }
		return results
	}

	/// Returns a copy of this palette with all colors conforming to the specific colorspace
	/// - Parameter colorspace: The colorspace to convert
	/// - Returns: A new palette
	///
	/// Throws an error if any of the palette's colors cannot be converted
	func copy(using colorspace: PAL.ColorSpace) throws -> PAL.Palette {
		let colors = try self.colors.map { try $0.converted(to: colorspace) }
		var groups: [PAL.Group] = []

		// We cannot use `let groups = try self.groups.map {` here as Swift 5.4.3 cannot compile it

		try self.groups.forEach { group in
			let colors = try group.colors.map { color in
				return try color.converted(to: colorspace)
			}
			let group = PAL.Group(name: group.name, colors: colors)
			groups.append(group)
		}
		return PAL.Palette(name: self.name, colors: colors, groups: groups)
	}

	/// Find the first instance of a color by name within the palette
	func color(named name: String, caseSensitive: Bool = false) -> PAL.Color? {
		if caseSensitive {
			return self.allColors().filter({ $0.name == name }).first
		}
		else {
			let name = name.lowercased()
			return self.allColors().filter({ $0.name.lowercased() == name }).first
		}
	}

	/// Return an array of colors for the specified palette group type
	/// - Parameter groupType: The color grouping
	/// - Returns: Color array
	func colors(for groupType: PAL.ColorGrouping) throws -> [PAL.Color] {
		switch groupType {
		case .global:
			return self.colors
		case .group(let offset):
			guard offset >= 0, offset < self.groups.count else {
				throw PAL.CommonError.indexOutOfRange
			}
			return self.groups[offset].colors
		}
	}
}

// MARK: - Encoding/Decoding

public extension PAL.Palette {
	internal enum CodingKeys: String, CodingKey {
		case name
		case colors
		case groups
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		self.colors = try container.decodeIfPresent([PAL.Color].self, forKey: .colors) ?? []
		self.groups = try container.decodeIfPresent([PAL.Group].self, forKey: .groups) ?? []
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		if !self.name.isEmpty {
			try container.encode(name, forKey: .name)
		}
		if !self.colors.isEmpty {
			try container.encode(colors, forKey: .colors)
		}
		if !self.groups.isEmpty {
			try container.encode(groups, forKey: .groups)
		}
	}
}

// MARK: - Bucketting and interpolated colors

public extension PAL.Palette {
	/// Returns a bucketed color for a time value mapped within an evenly spaced array of colors
	/// - Parameters:
	///   - t: The time within the palette
	///   - type: The palette colors to operate on
	/// - Returns: Bucketed color
	@inlinable func bucketedColor(at t: UnitValue<Double>, in type: PAL.ColorGrouping = .global) throws -> PAL.Color {
		try self.colors(for: type).bucketedColor(at: t)
	}

	/// Returns an interpolated color for a time value mapped within an evenly spaced array of colors
	/// - Parameters:
	///   - t: The time within the palette
	///   - type: The palette colors to operate on
	/// - Returns: Interpolated color
	@inlinable func interpolatedColor(at t: UnitValue<Double>, in type: PAL.ColorGrouping = .global) throws -> PAL.Color {
		try self.colors(for: type).bucketedColor(at: t, interpolate: true)
	}
}
