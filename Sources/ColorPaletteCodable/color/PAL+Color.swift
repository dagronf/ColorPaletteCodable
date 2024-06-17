//
//  PAL+Color.swift
//
//  Created by Darren Ford on 16/5/2022.
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
	/// A color in the palette
	struct Color: Equatable, CustomStringConvertible, Codable {
		/// The color name
		public let name: String
		/// The colorspace model for the color
		public let colorSpace: PAL.ColorSpace
		/// The components of the color
		public let colorComponents: [Float32]
		/// The type of color (global, spot, normal)
		public let colorType: ColorType

		/// The color's alpha component
		public let alpha: Float32

		/// Create a color object
		public init(name: String, colorSpace: PAL.ColorSpace, colorComponents: [Float32], colorType: ColorType = .global, alpha: Float32 = 1) throws {
			self.name = name
			self.colorSpace = colorSpace

			self.colorComponents = colorComponents
			self.colorType = colorType
			self.alpha = alpha

			// Validate that our color object is correctly formatted
			try self.checkValidity()
		}

		/// Return a string description of the color
		public var description: String {
			"Color '\(self.name)' [(\(self.colorSpace):\(self.colorType):\(self.colorComponents):\(self.alpha)]"
		}

		/// Returns a printable version of the color
		public var printable: String {
			let s = self.printableComponents
			return "\(self.colorSpace)(\(s),\(self.alpha))"
		}

		public var printableComponents: String {
			return self.colorComponents.map {
				String(format: "%0.03f", $0)
			}.joined(separator: ", ")
		}

		/// Returns true if the underlying color structure is valid for its colorspace and settings
		public var isValid: Bool {
			switch self.colorSpace {
			case .CMYK: if self.colorComponents.count == 4 { return true }
			case .RGB: if self.colorComponents.count == 3 { return true }
			case .LAB: if self.colorComponents.count == 3 { return true }
			case .Gray: if self.colorComponents.count == 1 { return true }
			}
			return false
		}

		/// Throws an error if the color is in an invalid state
		public func checkValidity() throws {
			if self.isValid == false {
				throw CommonError.invalidColorComponentCountForModelType
			}
		}

		/// Returns a comma-delimited string containing the color components
		var componentsString: String {
			String(self.colorComponents.map({ "\($0)" }).joined(separator: ", "))
		}
	}
}

public extension PAL.Color {
	/// Returns a copy of this color without transparency
	func removingTransparency() -> PAL.Color {
		if self.isValid == false { return PAL.Color.black }
		return (try? PAL.Color(
			name: self.name,
			colorSpace: self.colorSpace,
			colorComponents: self.colorComponents,
			colorType: self.colorType,
			alpha: 1
		)) ?? PAL.Color.black
	}

	/// Return a copy of this color with the specified alpha value
	func withAlpha(_ alphaValue: Float32) throws -> PAL.Color {
		return try PAL.Color(
			name: self.name,
			colorSpace: self.colorSpace,
			colorComponents: self.colorComponents,
			colorType: self.colorType,
			alpha: alphaValue
		)
	}
}

public extension PAL.Color {
	internal enum CodingKeys: String, CodingKey {
		case name
		case colorSpace
		case colorComponents
		case colorType
		case alpha
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		self.colorSpace = try container.decode(PAL.ColorSpace.self, forKey: .colorSpace)
		self.colorComponents = try container.decode([Float32].self, forKey: .colorComponents)
		self.colorType = try container.decodeIfPresent(PAL.ColorType.self, forKey: .colorType) ?? .global
		self.alpha = try container.decodeIfPresent(Float32.self, forKey: .alpha) ?? 1

		// Make sure our content is valid
		try self.checkValidity()
	}

	func encode(to encoder: Encoder) throws {
		// Make sure our content is valid
		try self.checkValidity()

		var container = encoder.container(keyedBy: CodingKeys.self)
		if !name.isEmpty { try container.encode(name, forKey: .name) }
		try container.encode(colorSpace, forKey: .colorSpace)
		try container.encode(colorComponents, forKey: .colorComponents)
		if colorType != .global { try container.encode(colorType, forKey: .colorType) }
		if alpha != 1 { try container.encode(alpha, forKey: .alpha) }
	}
}

// MARK: Colorspace converter

public extension PAL.Color {
	/// Convert the color object to a new color object with the specified colorspace
	/// - Parameter colorspace: The colorspace to convert to
	/// - Returns: A new color with the specified namespace
	func converted(to colorspace: PAL.ColorSpace) throws -> PAL.Color {
		if self.colorSpace == colorspace { return self }
		return try PAL_ColorSpaceConverter.convert(color: self, to: colorspace)
	}
}

// MARK: Color manipulations

public extension PAL.Color {
	/// Returns a midpoint color between this color and another color
	/// - Parameters:
	///   - color2: The color to compare against
	///   - t: The fractional distance between the two colors (0 ... 1)
	///   - named: The name for the generated color, or nil for no name
	/// - Returns: The midpoint color
	func midpoint(_ color2: PAL.Color, t: UnitValue<Double>, named name: String? = nil) throws -> PAL.Color {
		if self.colorSpace == color2.colorSpace {
			assert(self.colorComponents.count == color2.colorComponents.count)
			let cs = zip(self.colorComponents, color2.colorComponents).map { i in
				lerp(i.0, i.1, t: Float32(t.value))
			}
			return try PAL.Color(
				name: name ?? "",
				colorSpace: self.colorSpace,
				colorComponents: cs,
				alpha: lerp(self.alpha, color2.alpha, t: Float32(t.value))
			)
		}

		let c1 = try self.rgbaComponents()
		let c2 = try color2.rgbaComponents()
		let t = t.value
		return try PAL.Color(
			name: name ?? "",
			rf: Float32(lerp(c1.0, c2.0, t: t)),
			gf: Float32(lerp(c1.1, c2.1, t: t)),
			bf: Float32(lerp(c1.2, c2.2, t: t)),
			af: Float32(lerp(c1.3, c2.3, t: t))
		)
	}
}

public extension PAL.Color {
	/// Create a color array by interpolating between two colors
	///   - firstColor: The first (starting) color for the palette
	///   - lastColor: The second (ending) color for the palette
	///   - count: Number of colors to generate
	static func interpolate(firstColor: PAL.Color, lastColor: PAL.Color, count: Int) throws -> [PAL.Color] {
		assert(count > 2)
		let c1 = try firstColor.rgbaComponents()
		let c2 = try lastColor.rgbaComponents()
		let step = 1.0 / Double(count - 1)

		let rdiff = (c1.r - c2.r) * step
		let gdiff = (c1.g - c2.g) * step
		let bdiff = (c1.b - c2.b) * step
		let adiff = (c1.a - c2.a) * step

		return try (0 ..< count).map { index in
			let index = Double(index)
			return try PAL.Color(
				rf: Float32(c1.r + (index * rdiff)),
				gf: Float32(c1.g + (index * gdiff)),
				bf: Float32(c1.b + (index * bdiff)),
				af: Float32(c1.a + (index * adiff))
			)
		}
	}
}
