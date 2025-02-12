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
	case (.rgb, true): fallthrough
	case (.rgb, false):
		return (r: UInt8(c0), g: UInt8(c1), b: UInt8(c2), a: 255)

	case (.bgr, true): fallthrough
	case (.bgr, false):
		return (r: UInt8(c2), g: UInt8(c1), b: UInt8(c0), a: 255)

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

	case .rgb:
		return (r: c1, g: c2, b: c3, a: 255)
	case .bgr:
		return (r: c3, g: c2, b: c1, a: 255)
	}
}

/// Convert RGBA components to a UInt32 value
/// - Parameters:
///   - r255: red component
///   - g255: green component
///   - b255: blue component
///   - a255: alpha component
///   - colorByteFormat: The output byte format
/// - Returns: UInt32 encoded color value
func convertToUInt32(r255: UInt8, g255: UInt8, b255: UInt8, a255: UInt8, colorByteFormat: PAL.ColorByteFormat) -> UInt32 {
	switch colorByteFormat {
	case .argb:
		return (UInt32(a255) << 24 & 0xFF00_0000) + (UInt32(r255) << 16 & 0x00FF_0000) + (UInt32(g255) << 8 & 0x0000_FF00) + (UInt32(b255) & 0x0000_00FF)
	case .rgba:
		return (UInt32(r255) << 24 & 0xFF00_0000) + (UInt32(g255) << 16 & 0x00FF_0000) + (UInt32(b255) << 8 & 0x0000_FF00) + (UInt32(a255) & 0x0000_00FF)
	case .abgr:
		return (UInt32(a255) << 24 & 0xFF00_0000) + (UInt32(b255) << 16 & 0x00FF_0000) + (UInt32(g255) << 8 & 0x0000_FF00) + (UInt32(r255) & 0x0000_00FF)
	case .bgra:
		return (UInt32(b255) << 24 & 0xFF00_0000) + (UInt32(g255) << 16 & 0x00FF_0000) + (UInt32(r255) << 8 & 0x0000_FF00) + (UInt32(a255) & 0x0000_00FF)

	case .rgb:
		return (UInt32(0) << 24 & 0xFF00_0000) + (UInt32(r255) << 16 & 0x00FF_0000) + (UInt32(g255) << 8 & 0x0000_FF00) + (UInt32(b255) & 0x0000_00FF)
	case .bgr:
		return (UInt32(0) << 24 & 0xFF00_0000) + (UInt32(b255) << 16 & 0x00FF_0000) + (UInt32(g255) << 8 & 0x0000_FF00) + (UInt32(r255) & 0x0000_00FF)
	}
}

/// Convert RGBA components to a UInt32 value
/// - Parameters:
///   - r255: red component
///   - g255: green component
///   - b255: blue component
///   - a255: alpha component
///   - colorByteFormat: The output byte format
/// - Returns: UInt32 encoded color value
func convertToUInt32(rf: Float32, gf: Float32, bf: Float32, af: Float32, colorByteFormat: PAL.ColorByteFormat) -> UInt32 {
	convertToUInt32(r255: _f2p(rf), g255: _f2p(gf), b255: _f2p(bf), a255: _f2p(af), colorByteFormat: colorByteFormat)
}

// MARK: - Hex string representations

func hexRGBString(
	r255: UInt8,
	g255: UInt8,
	b255: UInt8,
	a255: UInt8 = 255,
	format: PAL.ColorByteFormat,
	hashmark: Bool,
	uppercase: Bool
) -> String {
	var result = hashmark ? "#" : ""
	switch format {
	case .rgb:
		result += String(format: uppercase ? "%02X%02X%02X" : "%02x%02x%02x", r255, g255, b255)
	case .bgr:
		result += String(format: uppercase ? "%02X%02X%02X" : "%02x%02x%02x", b255, g255, r255)
	case .argb:
		result += String(format: uppercase ? "%02X%02X%02X%02X" : "%02x%02x%02x%02x", a255, r255, g255, b255)
	case .rgba:
		result += String(format: uppercase ? "%02X%02X%02X%02X" : "%02x%02x%02x%02x", r255, g255, b255, a255)
	case .abgr:
		result += String(format: uppercase ? "%02X%02X%02X%02X" : "%02x%02x%02x%02x", a255, b255, g255, r255)
	case .bgra:
		result += String(format: uppercase ? "%02X%02X%02X%02X" : "%02x%02x%02x%02x", b255, g255, r255, a255)
	}
	return result
}

/// Returns a hex RGBA color representation
/// - Parameters:
///   - rf: red component (clamped to 0 ... 1)
///   - gf: green component (clamped to 0 ... 1)
///   - bf: blue component (clamped to 0 ... 1)
///   - af: alpha component (clamped to 0 ... 1)
///   - colorByteFormat: The byte order format (eg. RGB, BGR)
///   - includeHashmark: If true, start with a hash mark
///   - uppercase: Use uppercase characters
/// - Returns: A string
func hexRGBString<T: BinaryFloatingPoint>(
	rf: T,
	gf: T,
	bf: T,
	af: T = 1.0,
	format: PAL.ColorByteFormat,
	hashmark: Bool = false,
	uppercase: Bool
) -> String {
	hexRGBString(
		r255: _f2p(rf),
		g255: _f2p(gf),
		b255: _f2p(bf),
		a255: _f2p(af),
		format: format,
		hashmark: hashmark,
		uppercase: uppercase
	)
}
