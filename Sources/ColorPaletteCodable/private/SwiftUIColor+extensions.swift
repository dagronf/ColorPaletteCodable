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

#if canImport(SwiftUI)
import Foundation
import SwiftUI

@available(macOS 10.15, iOS 14.0, tvOS 14.0, watchOS 8.0, *)
extension Color {
	/// Create a color from a hex string
	///   - hex: The hex string
	///   - format: The expected rgba format
	///
	/// Supported hex formats :-
	/// - [#]FFF      : RGB color
	/// - [#]FFFF     : RGBA color (RRGGBB)
	/// - [#]FFFFFF   : RGB color
	/// - [#]FFFFFFFF : RGBA color (RRGGBBAA)
	///
	/// Returns clear color if the hex string is invalid
	init(hex: String, format: PAL.ColorByteFormat = .rgba) {
		guard let c = extractHexRGBA(hexString: hex, format: format) else {
			self = .clear
			return
		}
		self.init(.sRGB, red: Double(c.rf), green: Double(c.gf), blue: Double(c.bf), opacity: Double(c.af))
	}

	/// Create a color from a hex RGBA string
	///   - hex: The rgba hex string
	///
	/// Supported hex formats :-
	/// - [#]FFF      : RGB color
	/// - [#]FFFF     : RGBA color (RRGGBB)
	/// - [#]FFFFFF   : RGB color
	/// - [#]FFFFFFFF : RGBA color (RRGGBBAA)
	init(rgbaHexString: String) {
		self.init(hex: rgbaHexString, format: .argb)
	}
}

#endif
