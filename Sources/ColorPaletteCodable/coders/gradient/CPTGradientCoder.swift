//
//  Copyright © 2024 Darren Ford. All rights reserved.
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
import DSFRegex

public extension PAL.Gradients.Coder {
	/// CPT gradient encoder/decoder
	///
	/// https://web.archive.org/web/20131104234459/http://gmtrac.soest.hawaii.edu/doc/latest/GMT_Docs.html#color-palette-tables
	/// https://web.archive.org/web/20131104234459/http://gmtrac.soest.hawaii.edu/doc/latest/GMT_Docs.html#specifying-area-fill-attributes
	///
	/// No support for fill-back, fill-fore or fill-nan
	///
	struct CPT: PAL_GradientsCoder {
		/// The coder's file format
		public static let fileExtension = "cpt"

		/// Create
		public init() {}
	}
}

//   0 152  10 114  50 253 215 243
let _rgbEntry = try! DSFRegex(#"\s*([+-]?[0-9]*[.]?[0-9]+)\s*(\d*)\s*(\d*)\s*(\d*)\s*([+-]?[0-9]*[.]?[0-9]+)\s*(\d*)\s*(\d*)\s*(\d*)"#)

// 0.00000	13/8/135	0.00392	16/7/136
let _rgb2 = try! DSFRegex(#"\s*([+-]?[0-9]*[.]?[0-9]+)\s+([0-9]+)\/([0-9]+)\/([0-9]+)\s+(\d*\.\d+)\s+([0-9]+)\/([0-9]+)\/([0-9]+)"#)


public extension PAL.Gradients.Coder.CPT {

//	func parseColorDefinition(_ str: String) -> PAL.Color? {
//
//	}

	func scanCharacters(_ scanner: Scanner, _ cs: CharacterSet) -> String? {
#if os(Linux)
		var st: String?
		scanner.scanCharacters(from: cs, into: &st)
		return st
#else
		var ns: NSString?
		scanner.scanCharacters(from: cs, into: &ns)
		return ns as? String
#endif
	}

	func scanColor(_ scanner: Scanner) -> PAL.Color? {

		let index = scanner.scanLocation

		var r1: Int = 0
		var g1: Int = 0
		var b1: Int = 0

		// scan for "r g b"
		if scanner.scanInt(&r1),
			scanner.scanInt(&g1),
			scanner.scanInt(&b1)
		{
			return try? PAL.Color(r255: UInt8(r1), g255: UInt8(g1), b255: UInt8(b1))
		}

		scanner.scanLocation = index

		// scan for "r/g/b"
		let cs = CharacterSet(["/"])
		if scanner.scanInt(&r1),
			self.scanCharacters(scanner, cs) != nil,
			scanner.scanInt(&g1),
			self.scanCharacters(scanner, cs) != nil,
			scanner.scanInt(&b1)
		{
			return try? PAL.Color(r255: UInt8(r1), g255: UInt8(g1), b255: UInt8(b1))
		}

		scanner.scanLocation = index

		// scan for "#RRGGBB"
		let hexCS = CharacterSet.alphanumerics.union(CharacterSet(["#"]))
		if let hexRGB = self.scanCharacters(scanner, hexCS),
			let color = try? PAL.Color(rgbaHexString: hexRGB)
		{
			return color
		}

		scanner.scanLocation = index

		// We don't support hsl gradients
//		// scan for "h-s-l"
//		var h1: Int = 0
//		var s1: Double = 0
//		var l1: Double = 0
//		let hslCS = CharacterSet(["-"])
//		if scanner.scanInt(&h1),
//			self.scanCharacters(scanner, hslCS) != nil,
//			scanner.scanDouble(&s1),
//			self.scanCharacters(scanner, hslCS) != nil,
//			scanner.scanDouble(&l1)
//		{
//			return try? PAL.Color(h: Float32(h1) / 360.0, s: Float32(s1), b: Float32(l1))
//		}
//
//		scanner.scanLocation = index

		// scan for known x11 color names
		if let str = self.scanCharacters(scanner, .alphanumerics)?.lowercased() {
			return PAL.Palette.X11ColorPalette.color(named: str)
		}

		scanner.scanLocation = index

		return nil
	}

	func scanLineFormat(line: String) -> [PAL.Gradient.Stop] {
		var result: [PAL.Gradient.Stop] = []
		let sc = Scanner(string: line)
		var p1: Double = 0.0

		guard sc.scanDouble(&p1) else { return result }
		if let c1 = self.scanColor(sc) {
			let s = PAL.Gradient.Stop(position: p1, color: c1)
			result.append(s)
		}

		guard sc.scanDouble(&p1) else { return result }
		if let c2 = self.scanColor(sc) {
			let s = PAL.Gradient.Stop(position: p1, color: c2)
			result.append(s)
		}

		return result
	}

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

		let gradient = PAL.Gradient(stops: stops)
		return PAL.Gradients(gradients: [gradient])
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
