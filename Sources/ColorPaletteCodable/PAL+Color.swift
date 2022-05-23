//
//  PAL+Color.swift
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

public extension PAL {
	/// A color in the palette
	struct Color: Equatable, CustomStringConvertible {
		/// The color name
		public let name: String
		/// The colorspace model for the color
		public let model: PAL.ColorSpace
		/// The components of the color
		public let colorComponents: [Float32]
		/// The type of color (global, spot, normal)
		public let colorType: ColorType

		/// The color's alpha component
		public let alpha: Float32

		/// Create a color object
		public init(name: String, model: PAL.ColorSpace, colorComponents: [Float32], colorType: ColorType = .normal, alpha: Float32 = 1) throws {
			self.name = name
			self.model = model

			// Quick sanity check on the color model and components
			switch model {
			case .CMYK: if colorComponents.count != 4 { throw PAL.CommonError.invalidColorComponentCountForModelType }
			case .RGB: if colorComponents.count != 3 { throw PAL.CommonError.invalidColorComponentCountForModelType }
			case .LAB: if colorComponents.count != 3 { throw PAL.CommonError.invalidColorComponentCountForModelType }
			case .Gray: if colorComponents.count != 1 { throw PAL.CommonError.invalidColorComponentCountForModelType }
			}

			self.colorComponents = colorComponents
			self.colorType = colorType
			self.alpha = alpha
		}

		public var description: String {
			"Color '\(self.name)' [(\(self.model):\(self.colorType):\(self.colorComponents):\(self.alpha)]"
		}

		@inlinable public var modelString: String {
			switch model {
			case .CMYK: return "CMYK"
			case .RGB: return "RGB"
			case .LAB: return "LAB"
			case .Gray: return "Gray"
			}
		}

		@inlinable public var typeString: String {
			switch colorType {
			case .global: return "global"
			case .spot: return "spot"
			case .normal: return "normal"
			}
		}
	}
}

// MARK: Hex color initializers

public extension PAL.Color {
	/// Create a color object from a rgb hex string (eg. "12E5B4" or "#12E5B4")
	init(name: String = "", rgbHexString: String, colorType: PAL.ColorType = .normal) throws {
		guard let color = Self.fromRGBHexString(rgbHexString) else {
			throw PAL.CommonError.invalidRGBHexString(rgbHexString)
		}
		try self.init(name: name, model: .RGB, colorComponents: [color.r, color.g, color.b], colorType: colorType)
	}

	/// Create a color object from a rgb hex string (eg. "12E5B412" or "#12E5B412")
	init(name: String = "", rgbaHexString: String, colorType: PAL.ColorType = .normal) throws {
		if let color = Self.fromRGBAHexString(rgbaHexString) {
			try self.init(name: name, model: .RGB, colorComponents: [color.r, color.g, color.b], colorType: colorType, alpha: color.a)
		}
		else if let color = Self.fromRGBHexString(rgbaHexString) {
			try self.init(name: name, model: .RGB, colorComponents: [color.r, color.g, color.b], colorType: colorType)
		}
		else {
			throw PAL.CommonError.invalidRGBHexString(rgbaHexString)
		}
	}
}

// MARK: Hex color converters

private extension PAL.Color {
	static func fromRGBHexString(_ rgbaHexString: String) -> (r: Float32, g: Float32, b: Float32)? {
		// Validate the string length ('XXXXXX' or '#XXXXXX')
		guard rgbaHexString.count == 6 || (rgbaHexString.count == 7 && rgbaHexString.first == "#") else { return nil }

		// Create scanner
		let scanner = Scanner(string: rgbaHexString)
		scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
		var hexNumber: UInt64 = 0
		if scanner.scanHexInt64(&hexNumber) {
			let r = Float32((hexNumber & 0x00FF_0000) >> 16) / 255
			let g = Float32((hexNumber & 0x0000_FF00) >> 8) / 255
			let b = Float32(hexNumber & 0x0000_00FF) / 255
			return (r, g, b)
		}
		return nil
	}

	static func fromRGBAHexString(_ rgbaHexString: String) -> (r: Float32, g: Float32, b: Float32, a: Float32)? {
		// Validate the string length ('XXXXXXXX' or '#XXXXXXXX')
		guard rgbaHexString.count == 8 || (rgbaHexString.count == 9 && rgbaHexString.first == "#") else { return nil }

		// Create scanner
		let scanner = Scanner(string: rgbaHexString)
		scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
		var hexNumber: UInt64 = 0
		if scanner.scanHexInt64(&hexNumber) {
			let r = Float32((hexNumber & 0xFF00_0000) >> 24) / 255
			let g = Float32((hexNumber & 0x00FF_0000) >> 16) / 255
			let b = Float32((hexNumber & 0x0000_FF00) >> 8) / 255
			let a = Float32(hexNumber & 0x0000_00FF) / 255
			return (r, g, b, a)
		}
		return nil
	}
}
