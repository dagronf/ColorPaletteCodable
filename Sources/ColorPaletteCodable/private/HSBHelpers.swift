//
//  HSBHelpers.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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

// Some utilities for RGB/HSB conversion that don't rely on UIKit/AppKit

import Foundation

/// Convert RGB to HSB values
///
/// https://web.archive.org/web/20120717202441/http://www.cocoabuilder.com/archive/cocoa/198570-here-is-code-to-convert-rgb-hsb.html
internal func RGB_to_HSB<T: BinaryFloatingPoint>(RGB: (r: T, g: T, b: T)) -> (h: T, s: T, b: T) {

	// RGB are each on [0, 1]. S and V are returned on [0, 1] and H is
	// returned on [0, 1]. Exception: H is returned UNDEFINED if S==0.

	let R = RGB.r
	let G = RGB.g
	let B = RGB.b

	let x: T = min(R, G, B)
	let v: T = max(R, G, B)

	if v == x {
		return (0, 0, v)
	}

	let f = (R == x) ? G - B : ((G == x) ? B - R : R - G)
	let i = (R == x) ? 3 : ((G == x) ? 5 : 1);

	return (h: ((T(i) - (f / (v - x))) / 6), s: (v - x) / v, b: v)
}

/// Convert HSB to RGB values
///
/// https://web.archive.org/web/20120717202441/http://www.cocoabuilder.com/archive/cocoa/198570-here-is-code-to-convert-rgb-hsb.html
internal func HSB_to_RGB<T: BinaryFloatingPoint>(_ HSV: (h: T, s: T, b: T)) -> (r: T, g: T, b: T) {

	let H = HSV.h
	let s = HSV.s
	let v = HSV.b

	// H is given on [0, 1] or UNDEFINED. S and V are given on [0, 1].
	// RGB are each returned on [0, 1].
	var h = H * 6

	if (h == 0) { h = 0.01 }
	let i_ = floor(h)
	let i = Int(i_)
	var f = h - i_

	if i % 2 == 0 {
		// if i is even
		f = 1 - f
	}
	let m = v * (1 - s)
	let n = v * (1 - s * f)

	switch i {
	case 6: fallthrough
	case 0: return (r: v, g: n, b: m)  // RETURN_RGB(v, n, m);
	case 1: return (r: n, g: v, b: m)  // RETURN_RGB(n, v, m);
	case 2: return (r: m, g: v, b: n)  // RETURN_RGB(m, v, n);
	case 3: return (r: m, g: n, b: v)  // RETURN_RGB(m, n, v);
	case 4: return (r: n, g: m, b: v)  // RETURN_RGB(n, m, v);
	case 5: return (r: v, g: m, b: n)  // RETURN_RGB(v, m, n);
	default:
		fatalError()
	}
}


/*

 HSVType RGB_to_HSV( RGBType RGB )
	  {
	  // RGB are each on [0, 1]. S and V are returned on [0, 1] and H is
	  // returned on [0, 1]. Exception: H is returned UNDEFINED if S==0.
	  float R = RGB.R, G = RGB.G, B = RGB.B, v, x, f;
	  int i;
	  HSVType HSV;
	  //x = fminx(R, G, B);
	  x = fminf(R, G);
	  x = fminf(x, B);
	  //v = fmaxf(R, G, B);
	  v = fmaxf(R, G);
	  v = fmaxf(v, B);
	  if(v == x) RETURN_HSV(UNDEFINED, 0, v);
	  f = (R == x) ? G - B : ((G == x) ? B - R : R - G);
	  i = (R == x) ? 3 : ((G == x) ? 5 : 1);
	  RETURN_HSV(((i - f /(v - x))/6), (v - x)/v, v);
	  }

RGBType HSV_to_RGB( HSVType HSV )
	 {
	 // H is given on [0, 1] or UNDEFINED. S and V are given on [0, 1].
	 // RGB are each returned on [0, 1].
	 float h = HSV.H * 6, s = HSV.S, v = HSV.V, m, n, f;
	 int i;
	 RGBType RGB;
	 if (h == 0) h=.01;
	 if(h == UNDEFINED) RETURN_RGB(v, v, v);
	 i = floorf(h);
	 f = h - i;
	 if(!(i & 1)) f = 1 - f; // if i is even
	 m = v * (1 - s);
	 n = v * (1 - s * f);
	 switch (i)
		  {
		  case 6:
		  case 0: RETURN_RGB(v, n, m);
		  case 1: RETURN_RGB(n, v, m);
		  case 2: RETURN_RGB(m, v, n);
		  case 3: RETURN_RGB(m, n, v);
		  case 4: RETURN_RGB(n, m, v);
		  case 5: RETURN_RGB(v, m, n);
		  }
	 RETURN_RGB(0, 0, 0);
	 }
*/


#if canImport(CoreGraphics)
import CoreGraphics

private let DefaultHueConversionColorspace = CGColorSpace(name: CGColorSpace.sRGB)!

extension CGColor {
	/// Return the HSB representation for this color (converted to sRGB)
	func hue() -> (h: CGFloat, s: CGFloat, b: CGFloat)? {
		var mapped = self
		if self.colorSpace != DefaultHueConversionColorspace {
			guard let m = self.converted(to: DefaultHueConversionColorspace, intent: .defaultIntent, options: nil) else {
				return nil
			}
			mapped = m
		}

		guard let rgb = mapped.components, rgb.count == 4 else {
			return nil
		}

		let hsb = RGB_to_HSB(RGB: (r: rgb[0], g: rgb[1], b: rgb[2]))
		return (h: hsb.h, s: hsb.s, b: hsb.b)
	}

	/// Create an sRGB CGColor from HSB values
	static func fromHSB(h: CGFloat, s: CGFloat, b: CGFloat) -> CGColor? {
		let h = max(0, min(1, h))
		let s = max(0, min(1, s))
		let b = max(0, min(1, b))
		let rgb = HSB_to_RGB((h: h, s: s, b: b))
		let components: [CGFloat] = [rgb.r, rgb.g, rgb.b, 1.0]
		return CGColor(colorSpace: DefaultHueConversionColorspace, components: components)
	}
}
#endif
