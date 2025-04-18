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
			return try PAL.Color(color: conv, name: color.name, colorType: color.colorType)
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
			let rgb = NaiveConversions.CMYK2RGB(try color.cmyk())
			return rgbf(rgb.rf, rgb.gf, rgb.bf, color.alpha, name: color.name, colorType: color.colorType)
		}
		if color.colorSpace == .RGB, colorspace == .CMYK {
			let cmyk = NaiveConversions.RGB2CMYK(try color.rgb())
			return cmykf(cmyk.cf, cmyk.mf, cmyk.yf, cmyk.kf, color.alpha, name: color.name, colorType: color.colorType)
		}
		if color.colorSpace == .Gray, colorspace == .RGB {
			let rgb = NaiveConversions.Gray2RGB(l: color.colorComponents[0])
			return rgbf(rgb.rf, rgb.gf, rgb.bf, color.alpha, name: color.name, colorType: color.colorType)
		}
		if color.colorSpace == .RGB, colorspace == .Gray {
			let gray = NaiveConversions.RGB2Gray(try color.rgb())
			return grayf(gray, color.alpha, name: color.name, colorType: color.colorType)
		}
		if color.colorSpace == .Gray, colorspace == .CMYK {
			let cmyk = NaiveConversions.Gray2CMYK(l: color.colorComponents[0])
			return cmykf(cmyk.cf, cmyk.mf, cmyk.yf, cmyk.kf, color.alpha, name: color.name, colorType: color.colorType)
		}
		if color.colorSpace == .CMYK, colorspace == .Gray {
			let gray = NaiveConversions.CMYK2Gray(try color.cmyk())
			return grayf(gray, color.alpha, name: color.name, colorType: color.colorType)
		}

		ColorPaletteLogger.log(.error, "Unsupported color space conversion %@ -> %@", "\(color.colorSpace)", "\(colorspace)")
		throw PAL.CommonError.cannotConvertColorSpace
	}
}

// Very naive colorspace conversion routines.

internal struct NaiveConversions {
	/// Incredibly naive implementation for CMYK to RGB.
	static func CMYK2RGB(_ value: PAL.Color.CMYK) -> PAL.Color.RGB {
		let r = (1 - value.cf) * (1 - value.kf)
		let g = (1 - value.mf) * (1 - value.kf)
		let b = (1 - value.yf) * (1 - value.kf)
		return PAL.Color.RGB(rf: r, gf: g, bf: b)
	}

	/// Incredibly naive implementation for RGB to CMYK.
	static func RGB2CMYK(_ value: PAL.Color.RGB) -> PAL.Color.CMYK {
		let k = 1 - max(max(value.rf, value.gf), value.bf)
		let c = (1 - value.rf - k) / (1.0 - k)
		let m = (1 - value.gf - k) / (1.0 - k)
		let y = (1 - value.bf - k) / (1.0 - k)
		return PAL.Color.CMYK(cf: c, mf: m, yf: y, kf: k, af: value.af)
	}

	static func CMYK2Gray(_ value: PAL.Color.CMYK) -> Double {
		let rgb = CMYK2RGB(value)
		return RGB2Gray(rgb)
	}

	static func Gray2CMYK(l: Double) -> PAL.Color.CMYK {
		return RGB2CMYK(Gray2RGB(l: l))
	}

	static func RGB2Gray(_ value: PAL.Color.RGB) -> Double {
		return 0.299 * value.rf + 0.587 * value.gf + 0.114 * value.bf
	}

	static func Gray2RGB(l: Double) -> PAL.Color.RGB {
		return PAL.Color.RGB(rf: l, gf: l, bf: l)
	}

	// MARK: Convert sRGB to linear sRGB and back

	static func SRGB2Linear(_ value: Double) -> Double {
		(value <= 0.04045) ? (value / 12.92) : (pow((value + 0.055) / 1.055, 2.4))
	}

	static func Linear2SRGB(_ value: Double) -> Double {
		(value <= 0.0031308) ? (12.92 * value) : (1.055 * pow(value, 1.0 / 2.4) - 0.055)
	}

	/// Map a extended linear SRGB color to a standard sRGB colorspace
	@inlinable static func ExtendedLinearSRGB2SRGB(_ value: Double) -> Double {
		if (value <= 0.0) { return 0.0 }
		if (value >= 1.0) { return 1.0 }
		return Linear2SRGB(value)
	}

	/// Map a linear extended SRGB color to a standard sRGB colorspace
	@inlinable static func SRGB2ExtendedLinearSRGB(_ value: Double) -> Double {
		SRGB2Linear(value)
	}

	/// A version that handles extended values without clamping (optional tone mapping):
	static func Linear2SRGBExtended(_ value: Double) -> Double {
		let sign = (value < 0.0) ? -1.0 : 1.0
		let abs_c = abs(value)

		let encoded: Double
		if abs_c <= 0.0031308 {
			encoded = 12.92 * abs_c
		}
		else {
			encoded = 1.055 * pow(abs_c, 1.0 / 2.4) - 0.055;
		}
		return sign * encoded
	}

	// MARK: - XYZ and LAB

	//	// http://www.easyrgb.com/en/math.php
	//	// https://web.archive.org/web/20120502065620/http://cookbooks.adobe.com/post_Useful_color_equations__RGB_to_LAB_converter-14227.html

	static func RGB2XYZ(_ value: PAL.Color.RGB) -> PAL.Color.XYZ {
		//sR, sG and sB (Standard RGB) input range = 0 ÷ 255
		//X, Y and Z output refer to a D65/2° standard illuminant.

		var var_R = value.rf
		var var_G = value.gf
		var var_B = value.bf

		if ( var_R > 0.04045 ) {
			var_R = pow( ( ( var_R + 0.055 ) / 1.055 ), 2.4)
		}
		else {
			var_R = var_R / 12.92
		}

		if ( var_G > 0.04045 ) {
			var_G = pow( ( ( var_G + 0.055 ) / 1.055 ), 2.4)
		}
		else {
			var_G = var_G / 12.92
		}

		if ( var_B > 0.04045 ) {
			var_B = pow( ( ( var_B + 0.055 ) / 1.055 ), 2.4)
		}
		else {
			var_B = var_B / 12.92
		}

		//Observer. = 2°, Illuminant = D65

		var_R = var_R * 100
		var_G = var_G * 100
		var_B = var_B * 100

		let X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805
		let Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722
		let Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505
		return PAL.Color.XYZ(xf: X, yf: Y, zf: Z)
	}

	static func XYZ2LAB(_ value: PAL.Color.XYZ) -> PAL.Color.LAB {

		let CIE_E = 216.0 / 24389.0

		let REF_X: Double = 95.047   // Observer= 2°, Illuminant= D65
		let REF_Y: Double = 100.000
		let REF_Z: Double = 108.883

		var x: Double = value.xf / REF_X
		var y: Double = value.yf / REF_Y
		var z: Double = value.zf / REF_Z

		if ( x > CIE_E ) {
			x = pow(x, 1.0 / 3.0)
		}
		else {
			x = ( 7.787 * x ) + (16.0 / 116.0)
		}

		if ( y > CIE_E ) {
			y = pow(y, 1.0 / 3.0)
		}
		else {
			y = ( 7.787 * y ) + (16.0 / 116.0)
		}

		if ( z > CIE_E ) {
			z = pow(z, 1.0 / 3.0)
		}
		else {
			z = ( 7.787 * z ) + (16.0 / 116.0)
		}

		let l = ( 116.0 * y ) - 16
		let a = 500.0 * ( x - y )
		let b = 200.0 * ( y - z )

		return PAL.Color.LAB(l100: l, a128: a, b128: b)
	}

	static func LAB2XYZ(_ value: PAL.Color.LAB) -> PAL.Color.XYZ {

		let REF_X: Double = 95.047  // Observer= 2°, Illuminant= D65
		let REF_Y: Double = 100.000
		let REF_Z: Double = 108.883

		var y: Double = (value.lf + 16) / 116
		var x: Double = value.af / 500 + y
		var z: Double = y - value.bf / 200

		if ( pow( y , 3 ) > 0.008856 ) { y = pow( y , 3 ) }
		else { y = ( y - 16 / 116 ) / 7.787 }
		if ( pow( x , 3 ) > 0.008856 ) { x = pow( x , 3 ) }
		else { x = ( x - 16 / 116 ) / 7.787 }
		if ( pow( z , 3 ) > 0.008856 ) { z = pow( z , 3 ) }
		else { z = ( z - 16 / 116 ) / 7.787 }

		let xx = REF_X * x
		let xy = REF_Y * y
		let xz = REF_Z * z

		return PAL.Color.XYZ(xf: xx, yf: xy, zf: xz)
	}

	static func XYZ2RGB(_ value: PAL.Color.XYZ) -> PAL.Color.RGB {
		//X from 0 to  95.047      (Observer = 2°, Illuminant = D65)
		//Y from 0 to 100.000
		//Z from 0 to 108.883

		let x: Double = value.xf / 100
		let y: Double = value.yf / 100
		let z: Double = value.zf / 100

		var r: Double = x * 3.2406 + y * -1.5372 + z * -0.4986
		var g: Double = x * -0.9689 + y * 1.8758 + z * 0.0415
		var b: Double = x * 0.0557 + y * -0.2040 + z * 1.0570

		if ( r > 0.0031308 ) {
			r = 1.055 * pow( r , ( 1 / 2.4 ) ) - 0.055
		}
		else {
			r = 12.92 * r
		}
		if ( g > 0.0031308 ) {
			g = 1.055 * pow( g , ( 1 / 2.4 ) ) - 0.055
		}
		else {
			g = 12.92 * g
		}
		if ( b > 0.0031308 ) {
			b = 1.055 * pow( b , ( 1 / 2.4 ) ) - 0.055
		}
		else {
			b = 12.92 * b
		}

		return PAL.Color.RGB(rf: r, gf: g, bf: b)
	}

	@inlinable static func RGB2LAB(_ value: PAL.Color.RGB) -> PAL.Color.LAB {
		XYZ2LAB(RGB2XYZ(value))
	}

	@inlinable static func LAB2RGB(_ value: PAL.Color.LAB) -> PAL.Color.RGB {
		return XYZ2RGB(LAB2XYZ(value))
	}
}
