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

public extension ASE {
	/// A color in the palette
	struct Color: Equatable, CustomStringConvertible {
		/// The color name
		public let name: String
		/// The colorspace model for the color
		public let model: ColorModel
		/// The components of the color
		public let colorComponents: [Float32]
		/// The type of color (global, spot, normal)
		public let colorType: ColorType
		
		/// Create a color object
		public init(name: String, model: ColorModel, colorComponents: [Float32], colorType: ColorType = .normal) throws {
			self.name = name
			self.model = model
			
			// Quick sanity check on the color model and components
			switch model {
			case .CMYK: if colorComponents.count != 4 { throw ASE.CommonError.invalidColorComponentCountForModelType }
			case .RGB: if colorComponents.count != 3 { throw ASE.CommonError.invalidColorComponentCountForModelType }
			case .LAB: if colorComponents.count != 3 { throw ASE.CommonError.invalidColorComponentCountForModelType }
			case .Gray: if colorComponents.count != 1 { throw ASE.CommonError.invalidColorComponentCountForModelType }
			}
			
			self.colorComponents = colorComponents
			self.colorType = colorType
		}

		/// Create a color object from a rgb hex string (eg. "#12E5B4")
		public init(name: String = "", rgbHexString: String) throws {
			guard let color = CGColor.fromRGBHexString(rgbHexString) else {
				throw ASE.CommonError.invalidRGBHexString(rgbHexString)
			}
			try self.init(cgColor: color, name: name)
		}

		/// Create a color object from a rgb hex string (eg. "#12E5B412")
		///
		/// Strips the alpha component
		public init(name: String = "", rgbaHexString: String) throws {
			guard let color = CGColor.fromRGBAHexString(rgbaHexString) else {
				throw ASE.CommonError.invalidRGBHexString(rgbaHexString)
			}
			try self.init(cgColor: color, name: name)
		}
		
		public var description: String {
			"Color '\(self.name)' [(\(self.model):\(self.colorType):\(self.colorComponents)]"
		}
	}
}
