//
//  ASEPalette+Types.swift
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
	/// ASE Palette errors
	enum CommonError: Error {
		case unableToLoadFile
		case invalidASEHeader
		case invalidColorComponentCountForModelType
		case invalidEndOfFile
		case invalidString
		case unknownBlockType
		case groupAlreadyOpen
		case groupNotOpen
		case unknownColorMode(String)
		case unknownColorType(Int)
		case unsupportedCGColorType
	}
	
	/// A color model representation
	enum ColorModel: String {
		case CMYK
		case RGB = "RGB "
		case LAB = "LAB "
		case Gray
	}

	/// The type of the color (normal, spot, global)
	enum ColorType: Int {
		case global = 0
		case spot = 1
		case normal = 2
	}
}
