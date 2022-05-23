//
//  File.swift
//  
//
//  Created by Darren Ford on 23/5/2022.
//

import Foundation

public extension PAL {
	struct RGBA {
		public let name: String
		public let r: Float32
		public let g: Float32
		public let b: Float32
		public let a: Float32
		/// Convenience init for a 1.0,1.0,1.0,1.0 RGBA color
		public init(name: String = "", _ r: Float32, _ g: Float32, _ b: Float32, _ a: Float32 = 1) {
			self.name = name
			self.r = r
			self.g = g
			self.b = b
			self.a = a
		}

		/// Convenience init for a 255,255,255,255 RGBA color
		public init(name: String = "", _ r: Int8, _ g: Int8, _ b: Int8, _ a: Int8) {
			self.name = name
			self.r = Float32(r) / 255.0
			self.g = Float32(g) / 255.0
			self.b = Float32(b) / 255.0
			self.a = Float32(a) / 255.0
		}
		public func color() throws -> PAL.Color {
			try PAL.Color(name: name, model: .RGB, colorComponents: [r, g, b])
		}
	}

	struct RGBAGroup {
		public let name: String
		public let colors: [PAL.RGBA]
		public init(name: String = "", _ colors: [PAL.RGBA]) {
			self.name = name
			self.colors = colors
		}
	}
}

public extension PAL.Palette {
	/// Convenience constructor for creating a palette of RGB colors
	init(rgbaColors: [PAL.RGBA], groups: [PAL.RGBAGroup] = []) throws {
		self.colors = try rgbaColors.map { try $0.color() }
		self.groups = try groups.map {
			PAL.Group(
				name: $0.name,
				colors: try $0.colors.map { try $0.color() }
			)
		}
	}
}
