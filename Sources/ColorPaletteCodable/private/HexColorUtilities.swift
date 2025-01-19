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

/// Extract RGBA components from a hex formatted color string
/// - Parameters:
///   - rgbaHexString: The rgba hex string
///   - hexRGBFormat: The expected rgba format
/// - Returns: Individual color components, or nil if the hex string is invalid
///
/// Supported hex formats :-
/// - [#]FFF      : RGB color  (RGB)
/// - [#]FFFF     : RGBA color (RGBA)
/// - [#]FFFFFF   : RGB color  (RRGGBB)
/// - [#]FFFFFFFF : RGBA color (RRGGBBAA)
func extractHexRGBA(
	hexString: String,
	hexRGBFormat: PAL.ColorByteFormat
) -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8)? {
	var hex = hexString
		.lowercased()
		.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
	if hex.hasPrefix("0x") {
		hex = String(hex.dropFirst(2))
	}

	var val: UInt64 = 0
	guard Scanner(string: hex).scanHexInt64(&val) else {
		return nil
	}

	// The hex string has alpha for XXYYZZAA and XYZA formats only
	let hasAlpha: Bool = (hex.count == 4 || hex.count == 8)

	// Parse the hex components
	let c0, c1, c2, c3: UInt64
	switch hex.count {
	case 3: // RGB (12-bit)
		(c0, c1, c2, c3) = ((val >> 8 & 0xF) * 17, (val >> 4 & 0xF) * 17, (val & 0xF) * 17, 255)
	case 4: // RGBA (12-bit)
		(c0, c1, c2, c3) = ((val >> 12 & 0xF) * 17, (val >> 8 & 0xF) * 17, (val >> 4 & 0xF) * 17, (val & 0xF) * 17)
	case 6: // RRGGBB (24-bit)
		(c0, c1, c2, c3) = (val >> 16 & 0xFF, val >> 8 & 0xFF, val & 0xFF, 255)
	case 8: // RRGGBBAA (32-bit)
		(c0, c1, c2, c3) = (val >> 24 & 0xFF, val >> 16 & 0xFF, val >> 8 & 0xFF, val & 0xFF)
	default:
		return nil
	}

	switch (hexRGBFormat, hasAlpha) {
	case (.rgba, true):
		return (r: UInt8(c0), g: UInt8(c1), b: UInt8(c2), a: UInt8(c3))
	case (.rgba, false):
		return (r: UInt8(c0), g: UInt8(c1), b: UInt8(c2), a: 255)

	case (.argb, true):
		return (r: UInt8(c1), g: UInt8(c2), b: UInt8(c3), a: UInt8(c0))
	case (.argb, false):
		return (r: UInt8(c0), g: UInt8(c1), b: UInt8(c2), a: 255)

	case (.bgra, true):
		return (r: UInt8(c2), g: UInt8(c1), b: UInt8(c0), a: UInt8(c3))
	case (.bgra, false):
		return (r: UInt8(c2), g: UInt8(c1), b: UInt8(c0), a: 255)

	case (.abgr, true):
		return (r: UInt8(c3), g: UInt8(c2), b: UInt8(c1), a: UInt8(c0))
	case (.abgr, false):
		return (r: UInt8(c2), g: UInt8(c1), b: UInt8(c0), a: 255)
	}
}

/// Extract an RGBA color from a UInt32 value
/// - Parameters:
///   - uint32ColorValue: The value to convert
///   - colorByteFormat: The expected byte format
/// - Returns: Individual color components, or nil if the hex string is invalid
func extractRGBA(
	_ uint32ColorValue: UInt32,
	colorByteFormat: PAL.ColorByteFormat
) -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
	let c0 = UInt8(truncatingIfNeeded: (uint32ColorValue >> 24) & 0xFF)
	let c1 = UInt8(truncatingIfNeeded: (uint32ColorValue >> 16) & 0xFF)
	let c2 = UInt8(truncatingIfNeeded: (uint32ColorValue >> 8) & 0xFF)
	let c3 = UInt8(truncatingIfNeeded: uint32ColorValue & 0xFF)
	switch colorByteFormat {
	case .argb:
		return (r: c1, g: c2, b: c3, a: c0)
	case .rgba:
		return (r: c0, g: c1, b: c2, a: c3)
	case .abgr:
		return (r: c3, g: c2, b: c1, a: c0)
	case .bgra:
		return (r: c2, g: c1, b: c0, a: c3)
	}
}
