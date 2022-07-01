//
//  PAL+ColorConversions.swift
//
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

/// Color colorspace conversion protocol
public protocol PAL_ColorSpaceConvertible {
	/// Convert the specified color object to a new color object with the specified colorspace
	func convert(color: PAL.Color, to: PAL.ColorSpace) throws -> PAL.Color
}

/// Core Graphics color space converter.
///
/// By default:
/// * For Apple platforms, uses CoreGraphics (with default intent) for conversion.
/// * For everything else, uses very naive colorspace conversion routines (not recommended if you can help it).
///
/// You can supply your own converter object by creating an object that conforms to ColorSpaceConvertible
/// and setting this variable yourself.
public var PAL_ColorSpaceConverter: PAL_ColorSpaceConvertible = {
#if canImport(CoreGraphics)
	// CoreGraphics
	return CoreGraphicsColorSpaceConversion()
#else
	// Naive implementation
	return NaiveColorSpaceConversion()
#endif
}()

// MARK: - CoreGraphics converter

#if canImport(CoreGraphics)
import CoreGraphics

internal struct CoreGraphicsColorSpaceConversion: PAL_ColorSpaceConvertible {
	func convert(color: PAL.Color, to colorspace: PAL.ColorSpace) throws -> PAL.Color {
		if color.colorSpace == colorspace { return color }
		if let cg = color.cgColor,
			let conv = cg.converted(to: colorspace.cgColorSpace, intent: .defaultIntent, options: nil)
		{
			return try PAL.Color(cgColor: conv, name: color.name, colorType: color.colorType)
		}
		throw PAL.CommonError.cannotConvertColorSpace
	}
}
#endif

// MARK: - Naive converter

internal struct NaiveColorSpaceConversion: PAL_ColorSpaceConvertible {
	func convert(color: PAL.Color, to colorspace: PAL.ColorSpace) throws -> PAL.Color {
		// If this color is already the right colorspace then just return it.
		if color.colorSpace == colorspace { return color }

		if color.colorSpace == .CMYK, colorspace == .RGB {
			let rgb = NaiveConversions.CMYK2RGB(try color.cmykValues())
			return PAL.Color.rgb(name: color.name, rgb.r, rgb.g, rgb.b, color.alpha, colorType: color.colorType)
		}
		if color.colorSpace == .RGB, colorspace == .CMYK {
			let cmyk = NaiveConversions.RGB2CMYK(try color.rgbValues())
			return PAL.Color.cmyk(name: color.name, cmyk.c, cmyk.m, cmyk.y, cmyk.k, color.alpha, colorType: color.colorType)
		}
		if color.colorSpace == .Gray, colorspace == .RGB {
			let rgb = NaiveConversions.Gray2RGB(l: color.colorComponents[0])
			return PAL.Color.rgb(name: color.name, rgb.r, rgb.g, rgb.b, color.alpha, colorType: color.colorType)
		}
		if color.colorSpace == .RGB, colorspace == .Gray {
			let gray = NaiveConversions.RGB2Gray(try color.rgbValues())
			return PAL.Color.gray(name: color.name, white: gray, alpha: color.alpha, colorType: color.colorType)
		}
		if color.colorSpace == .Gray, colorspace == .CMYK {
			let cmyk = NaiveConversions.Gray2CMYK(l: color.colorComponents[0])
			return PAL.Color.cmyk(name: color.name, cmyk.c, cmyk.m, cmyk.y, cmyk.k, color.alpha, colorType: color.colorType)
		}
		if color.colorSpace == .CMYK, colorspace == .Gray {
			let gray = NaiveConversions.CMYK2Gray(try color.cmykValues())
			return PAL.Color.gray(name: color.name, white: gray, alpha: color.alpha, colorType: color.colorType)
		}

		throw PAL.CommonError.cannotConvertColorSpace
	}
}

// Very naive colorspace conversion routines.

internal struct NaiveConversions {

	internal typealias RGBValue = (r: Float32, g: Float32, b: Float32)
	internal typealias CMYKValue = (c: Float32, m: Float32, y: Float32, k: Float32)
	internal typealias XYZValue = (x: Float32, y: Float32, z: Float32)
	internal typealias LABValue = (l: Float32, a: Float32, b: Float32)

	/// Incredibly naive implementation for CMYK to RGB.
	static func CMYK2RGB(_ value: CMYKValue) -> RGBValue {
		let r = (1 - value.c) * (1 - value.k)
		let g = (1 - value.m) * (1 - value.k)
		let b = (1 - value.y) * (1 - value.k)
		return (r, g, b)
	}

	/// Incredibly naive implementation for RGB to CMYK.
	static func RGB2CMYK(_ value: RGBValue) -> CMYKValue {
		let k = 1 - max(max(value.r, value.g), value.b)

		let c = (1 - value.r - k) / (1.0 - k)
		let m = (1 - value.g - k) / (1.0 - k)
		let y = (1 - value.b - k) / (1.0 - k)

		return (c, m, y, k)
	}

	static func CMYK2Gray(_ value: CMYKValue) -> Float32 {
		let rgb = CMYK2RGB(value)
		return RGB2Gray(rgb)
	}

	static func Gray2CMYK(l: Float32) -> CMYKValue {
		return RGB2CMYK(Gray2RGB(l: l))
	}

	static func RGB2Gray(_ value: RGBValue) -> Float32 {
		return 0.299 * value.r + 0.587 * value.g + 0.114 * value.b
	}

	static func Gray2RGB(l: Float32) -> RGBValue {
		return (l, l, l)
	}

	// I cannot verify these, so I'm going to ignore them for the moment

//	// http://www.easyrgb.com/en/math.php
//	// https://web.archive.org/web/20120502065620/http://cookbooks.adobe.com/post_Useful_color_equations__RGB_to_LAB_converter-14227.html
//
//	static func RGB2XYZ(_ value: RGBValue) -> XYZValue {
//		//sR, sG and sB (Standard RGB) input range = 0 ÷ 255
//		//X, Y and Z output refer to a D65/2° standard illuminant.
//
//		var var_R = value.r
//		var var_G = value.g
//		var var_B = value.b
//
//		if ( var_R > 0.04045 ) {
//			var_R = pow( ( ( var_R + 0.055 ) / 1.055 ), 2.4)
//		}
//		else {
//			var_R = var_R / 12.92
//		}
//
//		if ( var_G > 0.04045 ) {
//			var_G = pow( ( ( var_G + 0.055 ) / 1.055 ), 2.4)
//		}
//		else {
//			var_G = var_G / 12.92
//		}
//
//		if ( var_B > 0.04045 ) {
//			var_B = pow( ( ( var_B + 0.055 ) / 1.055 ), 2.4)
//		}
//		else {
//			var_B = var_B / 12.92
//		}
//
//		var_R = var_R * 100
//		var_G = var_G * 100
//		var_B = var_B * 100
//
//		let X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805
//		let Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722
//		let Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505
//		return (X, Y, Z)
//	}
//
//	static func XYZ2LAB(_ value: XYZValue ) -> LABValue{
//		let REF_X: Float32 = 95.047   // Observer= 2°, Illuminant= D65
//		let REF_Y: Float32 = 100.000
//		let REF_Z: Float32 = 108.883
//
//		var x: Float32 = value.x / REF_X
//		var y: Float32 = value.y / REF_Y
//		var z: Float32 = value.z / REF_Z
//
//		if ( x > 0.008856 ) { x = pow( x , 1/3 ) }
//		else { x = ( 7.787 * x ) + ( 16/116 ) }
//		if ( y > 0.008856 ) { y = pow( y , 1/3 ) }
//		else { y = ( 7.787 * y ) + ( 16/116 ) }
//		if ( z > 0.008856 ) { z = pow( z , 1/3 ) }
//		else { z = ( 7.787 * z ) + ( 16/116 ) }
//
//		let l = ( 116.0 * y ) - 16
//		let a = 500.0 * ( x - y )
//		let b = 200.0 * ( y - z )
//
//		return (l, a, b)
//	}
//
//	static func LAB2XYZ(_ value: LABValue) -> XYZValue {
//
//		let REF_X: Float32 = 95.047  // Observer= 2°, Illuminant= D65
//		let REF_Y: Float32 = 100.000
//		let REF_Z: Float32 = 108.883
//
//		var y: Float32 = (value.l + 16) / 116
//		var x: Float32 = value.a / 500 + y
//		var z: Float32 = y - value.b / 200
//
//		if ( pow( y , 3 ) > 0.008856 ) { y = pow( y , 3 ) }
//		else { y = ( y - 16 / 116 ) / 7.787 }
//		if ( pow( x , 3 ) > 0.008856 ) { x = pow( x , 3 ) }
//		else { x = ( x - 16 / 116 ) / 7.787 }
//		if ( pow( z , 3 ) > 0.008856 ) { z = pow( z , 3 ) }
//		else { z = ( z - 16 / 116 ) / 7.787 }
//
//		let xx = REF_X * x
//		let xy = REF_Y * y
//		let xz = REF_Z * z
//
//		return (xx, xy, xz)
//	}
//
//	static func XYZ2RGB(_ value: XYZValue) -> RGBValue {
//		//X from 0 to  95.047      (Observer = 2°, Illuminant = D65)
//		//Y from 0 to 100.000
//		//Z from 0 to 108.883
//
//		let x: Float32 = value.x / 100
//		let y: Float32 = value.y / 100
//		let z: Float32 = value.z / 100
//
//		var r: Float32 = x * 3.2406 + y * -1.5372 + z * -0.4986
//		var g: Float32 = x * -0.9689 + y * 1.8758 + z * 0.0415
//		var b: Float32 = x * 0.0557 + y * -0.2040 + z * 1.0570
//
//		if ( r > 0.0031308 ) { r = 1.055 * pow( r , ( 1 / 2.4 ) ) - 0.055 }
//		else { r = 12.92 * r }
//		if ( g > 0.0031308 ) { g = 1.055 * pow( g , ( 1 / 2.4 ) ) - 0.055 }
//		else { g = 12.92 * g }
//		if ( b > 0.0031308 ) { b = 1.055 * pow( b , ( 1 / 2.4 ) ) - 0.055 }
//		else { b = 12.92 * b }
//
//		//		var rgb:Object = {r:0, g:0, b:0}
//		//		rgb.r = Math.round( r * 255 );
//		//		rgb.g = Math.round( g * 255 );
//		//		rgb.b = Math.round( b * 255 );
//
//		return (r, g, b)
//	}
//
//	static func RGB2LAB(_ value: RGBValue) -> LABValue {
//		return XYZ2LAB(RGB2XYZ(value))
//	}
//
//	static func LAB2RGB(_ value: LABValue) -> RGBValue {
//		return XYZ2RGB(LAB2XYZ(value))
//	}
}
