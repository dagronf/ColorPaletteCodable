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

private let _defaultComponentsFormatter = NumberFormatter {
	$0.minimumFractionDigits = 1
	$0.maximumFractionDigits = 3
}

public extension PAL {
	/// A color in the palette
	struct Color: Equatable, CustomStringConvertible {
		public let id = UUID()
		/// The color name
		public var name: String
		/// The type of color (global, spot, normal)
		public var colorType: ColorType

		/// The colorspace model for the color
		public internal(set) var colorSpace: PAL.ColorSpace
		/// The components of the color
		public internal(set) var colorComponents: [Float32]

		/// The color's alpha component
		public var alpha: Float32

		/// Create a color object
		/// - Parameters:
		///   - colorSpace: The expected colorspace for the color components
		///   - colorComponents: The color components (each in the range 0.0 ... 1.0)
		///   - alpha: The alpha value for the color
		///   - name: The color's name
		///   - colorType: The color type
		public init(
			colorSpace: PAL.ColorSpace,
			colorComponents: [Float32],
			alpha: Float32 = 1,
			name: String = "",
			colorType: ColorType = .global
		) throws {
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

		/// Returns a printable version of the color which includes the colorspace
		/// - Parameters:
		///   - includeAlpha: include the alpha component as the last element in the string
		///   - formatter: An optional number formatter
		/// - Returns: A string
		public func printableString(includeAlpha: Bool = true, formatter: NumberFormatter? = nil) -> String {
			"\(self.colorSpace)(\(self.componentsString(includeAlpha: includeAlpha, formatter: formatter))"
		}

		/// Returns a comma-delimited string containing the color components
		/// - Parameters:
		///   - includeAlpha: include the alpha component as the last element in the string
		///   - formatter: An optional number formatter
		/// - Returns: A string
		public func componentsString(includeAlpha: Bool = false, formatter: NumberFormatter? = nil) -> String {
			var components = self.colorComponents
			if includeAlpha { components.append(self.alpha) }
			let f = formatter ?? _defaultComponentsFormatter
			return components
				.map { f.string(for: $0)! }
				.joined(separator: ", ")
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

		/// Equality
		public static func == (lhs: Color, rhs: Color) -> Bool {
			return lhs.colorSpace == rhs.colorSpace &&
			lhs.colorComponents == rhs.colorComponents &&
			lhs.name == rhs.name &&
			lhs.colorType == rhs.colorType &&
			lhs.alpha == rhs.alpha
		}

		/// Equality with a precision
		public func isEqual(to c1: PAL.Color, precision: UInt) -> Bool {
			guard
				self.colorComponents.count == c1.colorComponents.count,
				self.colorSpace == c1.colorSpace,
				self.name == c1.name,
				self.colorType == c1.colorType,
				self.alpha.isEqual(to: c1.alpha, precision: precision)
			else {
				return false
			}

			for index in 0 ..< self.colorComponents.count {
				if self.colorComponents[index].isEqual(to: c1.colorComponents[index], precision: precision) == false {
					return false
				}
			}
			return true
		}

		/// Generate a random color
		/// - Parameters:
		///   - colorSpace: The colorspace when generating the color
		///   - name: color name
		///   - colorType: The color type
		/// - Returns: A random color in the RGB colorspace
		public static func random(
			colorSpace: PAL.ColorSpace = .RGB,
			name: String = "",
			colorType: PAL.ColorType = .global
		) -> PAL.Color {
			switch colorSpace {
			case .CMYK:
				return PAL.Color(
					cf: Float32.random(in: 0...1),
					mf: Float32.random(in: 0...1),
					yf: Float32.random(in: 0...1),
					kf: Float32.random(in: 0...1),
					name: name,
					colorType: colorType
				)
			case .RGB:
				return PAL.Color(
					rf: Float32.random(in: 0...1),
					gf: Float32.random(in: 0...1),
					bf: Float32.random(in: 0...1),
					name: name,
					colorType: colorType
				)
			case .Gray:
				return PAL.Color(
					white: Float32.random(in: 0...1),
					name: name,
					colorType: colorType
				)
			case .LAB:
				// MARK: - TODO: Support random LAB values maybe?
				fatalError()
			}
		}
	}
}

@available(macOS 10.15, *)
extension PAL.Color: Identifiable { }

extension PAL.Color: Hashable {
	public func hash(into hasher: inout Hasher) { hasher.combine(self.id) }
}

public extension PAL.Color {
	private init(
		noVerifyWithColorspace colorSpace: PAL.ColorSpace,
		colorComponents: [Float32],
		alpha: Float32,
		name: String,
		colorType: PAL.ColorType
	) {
		self.name = name
		self.colorSpace = colorSpace
		self.colorComponents = colorComponents
		self.colorType = colorType
		self.alpha = alpha
	}

	/// Make a unique copy of this color
	func uniqueCopy() -> PAL.Color {
		PAL.Color(
			noVerifyWithColorspace: self.colorSpace,
			colorComponents: self.colorComponents,
			alpha: self.alpha,
			name: self.name,
			colorType: self.colorType
		)
	}

	/// Returns a copy of this color without transparency
	func removingTransparency() throws -> PAL.Color {
		if self.isValid == false { return PAL.Color.black }
		return try self.withAlpha(1)
	}

	/// Return a copy of this color with the specified alpha value
	func withAlpha(_ alphaValue: Float32) throws -> PAL.Color {
		return try PAL.Color(
			colorSpace: self.colorSpace,
			colorComponents: self.colorComponents,
			alpha: alphaValue,
			name: self.name,
			colorType: self.colorType
		)
	}

	/// Set the color name
	/// - Parameter name: name description
	func named(_ name: String) -> PAL.Color {
		if let c = try? PAL.Color(
			colorSpace: self.colorSpace,
			colorComponents: self.colorComponents,
			alpha: self.alpha,
			name: name,
			colorType: self.colorType
		) {
			return c
		}
		return self
	}
}

// MARK: - Encode/Decoded

extension PAL.Color: Codable {
	internal enum CodingKeys: String, CodingKey {
		case name
		case colorSpace
		case colorComponents
		case colorType
		case alpha
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		self.colorSpace = try container.decode(PAL.ColorSpace.self, forKey: .colorSpace)
		self.colorComponents = try container.decode([Float32].self, forKey: .colorComponents)
		self.colorType = try container.decodeIfPresent(PAL.ColorType.self, forKey: .colorType) ?? .global
		self.alpha = try container.decodeIfPresent(Float32.self, forKey: .alpha) ?? 1

		// Make sure our content is valid
		try self.checkValidity()
	}

	public func encode(to encoder: Encoder) throws {
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

// MARK: - Colorspace conversion

public extension PAL.Color {
	/// Convert the color object to a new color object with the specified colorspace
	/// - Parameter colorspace: The colorspace to convert to
	/// - Returns: A new color with the specified namespace
	@inlinable func converted(to colorspace: PAL.ColorSpace) throws -> PAL.Color {
		if self.colorSpace == colorspace { return self }
		return try PAL_ColorSpaceConverter.convert(color: self, to: colorspace)
	}
}

// MARK: - Modification

public extension PAL.Color {
	public mutating func setRGB(rf: Float32, gf: Float32, bf: Float32, af: Float32) {
		self.colorSpace = .RGB
		self.colorComponents = [rf.unitClamped, gf.unitClamped, bf.unitClamped]
		self.alpha = af.unitClamped
	}
	public mutating func setGray(whitef: Float32, af: Float32) {
		self.colorSpace = .Gray
		self.colorComponents = [whitef.unitClamped]
		self.alpha = af.unitClamped
	}
}

