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
import DSFRegex

public extension PAL.Gradients.Coder {
	/// CPT gradient encoder/decoder
	///
	/// https://web.archive.org/web/20131104234459/http://gmtrac.soest.hawaii.edu/doc/latest/GMT_Docs.html#color-palette-tables
	/// https://web.archive.org/web/20131104234459/http://gmtrac.soest.hawaii.edu/doc/latest/GMT_Docs.html#specifying-area-fill-attributes
	///
	/// • No support for fill-back, fill-fore or fill-nan
	/// • No support for HSV gradients
	struct CPT: PAL_GradientsCoder {
		/// The coder's file format
		public static let fileExtension = "cpt"
		/// Create
		public init() {}
	}
}

public extension PAL.Gradients.Coder.CPT {
	/// Decode a gradient using the GIMP Gradient format
	/// - Parameter inputStream: The input stream containing the data
	/// - Returns: a gradient
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		// Load a string from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			ColorPaletteLogger.log(.error, "GGRCoder: Unexpected text encoding")
			throw PAL.CommonError.invalidString
		}

		let content = decoded.text

		// Remove any blank lines from the input file
		let lines = content
			.components(separatedBy: .newlines).filter { $0.count > 0 }
			.filter { $0.first != "#" }

		var stops: [PAL.Gradient.Stop] = []

		for line in lines {
			let attempt1 = scanLineFormat(line: line)
			if attempt1.count > 0 {
				stops.append(contentsOf: attempt1)
				continue
			}
		}

		// Make sure that the stops are normalized between 0 -> 1
		// (CPT can have arbitrary upper and lower bounds)
		let gradient = try PAL.Gradient(stops: stops).normalized()
		return PAL.Gradients(gradients: [gradient])
	}
}

let _rgbSeparator = CharacterSet(["/"])

private extension PAL.Gradients.Coder.CPT {

	func scanColor(_ scanner: Scanner) -> PAL.Color? {

		let index = scanner.currentIndex

		// scan for "r g b"
		if
			let r1 = scanner._scanInt(),
			let g1 = scanner._scanInt(),
			let b1 = scanner._scanInt()
		{
			return try? PAL.Color(r255: UInt8(r1), g255: UInt8(g1), b255: UInt8(b1))
		}

		// Reset back to the start of the color section
		scanner.currentIndex = index

		// scan for "r/g/b"
		if
			let r1 = scanner._scanInt(),
			let _ = scanner._scanCharacters(in: _rgbSeparator),
			let g1 = scanner._scanInt(),
			let _ = scanner._scanCharacters(in: _rgbSeparator),
			let b1 = scanner._scanInt()
		{
			return try? PAL.Color(r255: UInt8(r1), g255: UInt8(g1), b255: UInt8(b1))
		}

		scanner.currentIndex = index

		// scan for "#RRGGBB"
		let hexCS = CharacterSet.alphanumerics.union(CharacterSet(["#"]))
		if let hexRGB = scanner._scanCharacters(in: hexCS),
			let color = try? PAL.Color(rgbaHexString: hexRGB)
		{
			return color
		}

		scanner.currentIndex = index

		// scan for color names
		if let str = scanner._scanCharacters(in: .alphanumerics)?.lowercased() {
			return PAL.Palette.X11ColorPalette.color(named: str)
		}

		scanner.currentIndex = index

		return nil
	}

	func scanLineFormat(line: String) -> [PAL.Gradient.Stop] {
		var result: [PAL.Gradient.Stop] = []
		let sc = Scanner(string: line)

		guard let p1 = sc._scanDouble() else { return result }
		if let c1 = self.scanColor(sc) {
			let s = PAL.Gradient.Stop(position: p1, color: c1)
			result.append(s)
		}

		guard let p2 = sc._scanDouble() else { return result }
		if let c2 = self.scanColor(sc) {
			let s = PAL.Gradient.Stop(position: p2, color: c2)
			result.append(s)
		}

		return result
	}
}

public extension PAL.Gradients.Coder.CPT {
	/// Encode the gradient using CPT format (CPT Gradient)
	/// - Parameter gradient: The gradient to encode
	/// - Returns: encoded data
	func encode(_ gradients: PAL.Gradients) throws -> Data {
		throw PAL.CommonError.notImplemented
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let cpt = UTType("public.dagronf.cpt")!
}
#endif
