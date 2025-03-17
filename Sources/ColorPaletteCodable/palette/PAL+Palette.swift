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

		/// If this palette was loaded, the format used to decode
		public internal(set) var format: PAL.PaletteFormat?

		/// Create an empty palette
		public init() {}

		/// Create a palette
		/// - Parameters:
		///   - colors: The global colors
		///   - groups: The palettes groups
		///   - name: The palette name
		public init(colors: [PAL.Color], groups: [PAL.Group] = [], name: String = "") {
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

	internal init(format: PAL.PaletteFormat) {
		self.name = ""
		self.colors = []
		self.groups = []
		self.format = format

	}
	internal init(colors: [PAL.Color], groups: [PAL.Group] = [], name: String = "", format: PAL.PaletteFormat) {
		self.name = name
		self.colors = colors
		self.groups = groups
		self.format = format
	}


	/// Create a palette by interpolating between two colors
	/// - Parameters:
	///   - startColor: The first (starting) color for the palette
	///   - endColor: The second (ending) color for the palette
	///   - count: Number of colors to generate
	///   - useOkLab: If true, use OkLab colorspace when generating colors
	///   - name: The palette's name
	init(
		startColor: PAL.Color,
		endColor: PAL.Color,
		count: Int,
		useOkLab: Bool = false,
		name: String = ""
	) throws {
		let colors = try PAL.Color.interpolate(
			startColor: startColor,
			endColor: endColor,
			count: count,
			useOkLab: useOkLab
		)
		self.init(colors: colors, name: name)
	}

	/// Return a palette containing random colors
	/// - Parameters:
	///   - count: The number of random colors
	///   - colorSpace: The colorspace when generating the color
	///   - colorType: The color type for all colors
	/// - Returns: A palette
	static func random(
		_ count: Int,
		colorSpace: PAL.ColorSpace = .RGB,
		colorType: PAL.ColorType = .global
	) -> PAL.Palette {
		assert(count > 0)
		return PAL.Palette(
			colors: (0 ..< count).map { _ in
				PAL.Color.random(colorSpace: colorSpace, colorType: colorType)
			}
		)
	}
}

// MARK: - Import

public extension PAL.Palette {

	// MARK: Create from file URL

	/// Load a palette from a local file
	/// - Parameters:
	///   - fileURL: The fileURL for the palette file
	///   - coder: [optional] Override the default palette coder
	init(_ fileURL: URL, usingCoder coder: PAL_PaletteCoder? = nil) throws {
		let palette = try PAL.Palette.Decode(from: fileURL, usingCoder: coder)
		self.name = palette.name
		self.colors = palette.colors
		self.groups = palette.groups
		self.format = palette.format
	}

	/// Load a palette from a local file
	/// - Parameters:
	///   - fileURL: The fileURL for the palette file
	///   - format: The format for the palette file
	init(_ fileURL: URL, format: PAL.PaletteFormat) throws {
		try self.init(fileURL, usingCoder: format.coder)
	}

	// MARK: Create from data

	/// Load a palette from raw data
	/// - Parameters:
	///   - data: The raw palette data
	///   - coder: The palette coder to use when decoding
	init(_ data: Data, usingCoder coder: PAL_PaletteCoder) throws {
		let palette = try coder.decode(from: data)
		self.name = palette.name
		self.colors = palette.colors
		self.groups = palette.groups
		self.format = coder.format
	}

	/// Load a palette from raw data
	/// - Parameters:
	///   - data: The gradient data
	///   - fileExtension: The gradient format's extension (eg. "ase")
	init(_ data: Data, fileExtension: String) throws {
		guard let coder = PAL.Palette.coder(for: fileExtension).first else {
			throw PAL.CommonError.unsupportedPaletteType
		}
		try self.init(data, usingCoder: coder)
	}

	/// Load a palette from data
	/// - Parameters:
	///   - data: The gradient data
	///   - format: The format for the palette file
	init(_ data: Data, format: PAL.PaletteFormat) throws {
		try self.init(data, usingCoder: format.coder)
	}
}

// MARK: - Export


public extension PAL.Palette {
	/// Export the palette
	/// - Parameter coder: The palette coder to use
	/// - Returns: raw palette format data
	func export(using coder: PAL_PaletteCoder) throws -> Data {
		try coder.encode(self)
	}

	/// Export the palette
	/// - Parameter format: The format for the palette file
	/// - Returns: raw palette format data
	func export(format: PAL.PaletteFormat) throws -> Data {
		try self.export(using: format.coder)
	}
}

// MARK: - Conveniences

public extension PAL.Palette {
	/// Returns all the groups for the palette. Global colors are represented in a group called 'global'
	@inlinable var allGroups: [PAL.Group] {
		return [PAL.Group(colors: self.colors, name: "global")] + self.groups
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
			let group = PAL.Group(colors: colors, name: group.name)
			groups.append(group)
		}
		return PAL.Palette(colors: colors, groups: groups, name: self.name)
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
		self.format = .json
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

// MARK: - Modify

public extension PAL.Palette {
	/// An index for a color within the palette
	struct ColorIndex: Equatable {
		/// The group index for the color, or nil for global colors
		public let groupIndex: Int?
		/// The color index within the selected group
		public let colorIndex: Int
		/// Create
		/// - Parameters:
		///   - groupIndex: The group index for the color, or nil for global colors
		///   - colorIndex: The color index within the selected group
		public init(groupIndex: Int? = nil, colorIndex: Int) {
			self.groupIndex = groupIndex
			self.colorIndex = colorIndex
		}
	}

	/// Retrieve a color from the palette
	/// - Parameters:
	///   - groupIndex: For palettes containing groups, the group index containing the color, or nil for global colors
	///   - colorIndex: The color index within the group
	/// - Returns: The color at the specified index
	func color(groupIndex: Int? = nil, colorIndex: Int) throws -> PAL.Color {
		if let groupIndex {
			guard
				groupIndex < self.groups.count,
				colorIndex < self.groups[groupIndex].colors.count
			else {
				throw PAL.CommonError.indexOutOfRange
			}
			return self.groups[groupIndex].colors[colorIndex]
		}
		else {
			guard colorIndex < self.colors.count else {
				throw PAL.CommonError.indexOutOfRange
			}
			return self.colors[colorIndex]
		}
	}

	/// Retrieve a color from the palette
	/// - Parameters:
	///   - index: The palette index for the color to update
	/// - Returns: The color at the specified index
	@inlinable func color(index: PAL.Palette.ColorIndex) throws -> PAL.Color {
		try self.color(groupIndex: index.groupIndex, colorIndex: index.colorIndex)
	}

	/// Update a color
	/// - Parameters:
	///   - groupIndex: The group index containing the color index, or nil for global colors
	///   - colorIndex: The color index within the group
	///   - color: The color
	mutating func updateColor(groupIndex: Int? = nil, colorIndex: Int, color: PAL.Color) throws {
		if let groupIndex {
			guard
				groupIndex < self.groups.count,
				colorIndex < self.groups[groupIndex].colors.count
			else {
				throw PAL.CommonError.indexOutOfRange
			}
			self.groups[groupIndex].colors[colorIndex].setColor(color)
		}
		else {
			guard colorIndex < self.colors.count else {
				throw PAL.CommonError.indexOutOfRange
			}
			self.colors[colorIndex].setColor(color)
		}
	}

	/// Update a color
	/// - Parameters:
	///   - index: The palette index for the color to update
	///   - color: The color
	@inlinable mutating func updateColor(index: PAL.Palette.ColorIndex, color: PAL.Color) throws {
		try self.updateColor(groupIndex: index.groupIndex, colorIndex: index.colorIndex, color: color)
	}
}
