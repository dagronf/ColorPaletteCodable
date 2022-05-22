//
//  ASEPalette+Color.swift
//
//  Created by Darren Ford on 16/5/2022.
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

public extension ASE.Palette {
	/// Convenience constructor for creating a palette of RGB colors
	init(rgbColors: [ASE.RGB], groups: [ASE.RGBGroup] = []) throws {
		self.colors = try rgbColors.map { try $0.color() }
		self.groups = try groups.map {
			ASE.Group(
				name: $0.name,
				colors: try $0.colors.map { try $0.color() }
			)
		}
	}

	/// Returns all the groups for the palette. Global colors are represented in a group called 'global'
	@inlinable var allGroups: [ASE.Group] {
		return [ASE.Group(name: "global", colors: self.colors)] + self.groups
	}

	/// Returns all the colors in the palette as a flat array of colors
	func flattenedColors() -> [ASE.Color] {
		var results: [ASE.Color] = []
		results.append(contentsOf: self.colors)
		groups.forEach { results.append(contentsOf: $0.colors) }
		return results
	}
}

public extension ASE {
	struct RGB {
		public let name: String
		public let r: Float32
		public let g: Float32
		public let b: Float32
		public init(name: String = "", _ r: Float32, _ g: Float32, _ b: Float32) {
			self.name = name
			self.r = r
			self.g = g
			self.b = b
		}
		public init(name: String = "", _ r: Int, _ g: Int, _ b: Int) {
			self.name = name
			self.r = Float32(r) / 255.0
			self.g = Float32(g) / 255.0
			self.b = Float32(b) / 255.0
		}
		public func color() throws -> ASE.Color {
			try ASE.Color(name: name, model: .RGB, colorComponents: [r, g, b])
		}
	}

	struct RGBGroup {
		public let name: String
		public let colors: [ASE.RGB]
		public init(name: String = "", _ colors: [ASE.RGB]) {
			self.name = name
			self.colors = colors
		}
	}
}
