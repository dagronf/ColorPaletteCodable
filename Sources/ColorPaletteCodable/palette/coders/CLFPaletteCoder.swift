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

import DSFRegex
import Foundation

public extension PAL.Coder {
	/// A coder that handles reading CLF formatted LAB colors
	struct CLF: PAL_PaletteCoder {
		public var format: PAL.PaletteFormat = .clf
		public let name = "CLF Lab Colors"
		public let fileExtension = ["clf"]
		public static let utTypeString: String = "public.dagronf.colorpalette.palette.clf"
		public init() {}
	}
}

public extension PAL.Coder.CLF {

	// The clf files can be opened in any text editor.
	// 1 line represents 1 colour, the structure is:
	//
	//  Colourname[tab]L-value[tab]L*-value[tab]a*-value[tab]b*-value

	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// Load text from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			throw PAL.CommonError.unableToLoadFile
		}
		let content = decoded.text

		var palette = PAL.Palette(format: self.format)

		// Split into newlines
		let lines = content.lines

		for line in lines {
			let components = line.components(separatedBy: "\t")

			guard components.count == 4 else {
				continue
			}

			let name = components[0]

			let Ls = String(components[1].map { $0 == "," ? "." : $0 })
			let As = String(components[2].map { $0 == "," ? "." : $0 })
			let Bs = String(components[3].map { $0 == "," ? "." : $0 })

			guard
				let l = Double(Ls.trim()),
				let a = Double(As.trim()),
				let b = Double(Bs.trim())
			else {
				continue
			}

			if let color = try? PAL.Color(colorSpace: .LAB, colorComponents: [l, a, b], alpha: 1, name: name) {
				palette.colors.append(color)
			}
		}

		if palette.colors.count == 0 {
			throw PAL.CommonError.invalidFormat
		}

		return palette
	}
}

public extension PAL.Coder.CLF {
	/// Write out the colors in the palette
	/// 1. One color per line, encoded as a HEX value
	/// 2. Hex encoded
	func encode(_ palette: PAL.Palette) throws -> Data {
		throw PAL.CommonError.notImplemented
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let clfPalette = UTType(PAL.Coder.CLF.utTypeString)!
}
#endif
