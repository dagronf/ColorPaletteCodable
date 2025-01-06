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
	/// https://beamreach.org/maps/gmt/GMT4.3.1/www/gmt/doc/html/GMT_Docs/node63.html
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
			ColorPaletteLogger.log(.error, "CPTCoder: Unexpected text encoding")
			throw PAL.CommonError.invalidString
		}

		// Split the input into lines, and remove any blank lines
		let rawlines = decoded.text
			.lines
			.filter { $0.count > 0 }

		// Check to see if the gradient is HSV. If it is, we don't support it.
		let hsbCheck = rawlines
			.filter({ $0.hasPrefix("# COLOR_MODEL") })
			.filter({ $0.contains("HSV") })
		if hsbCheck.count > 0 {
			ColorPaletteLogger.log(.error, "CPTCoder: Unsupported colorspace (HSV)")
			throw PAL.CommonError.unsupportedColorSpace
		}

		// Remove the comments
		let lines = rawlines.filter { $0.first != "#" }

		var stops: [PAL.Gradient.Stop] = []

		for line in lines {
			if line.hasPrefix("B") || line.hasPrefix("F") || line.hasPrefix("N") {
				// Just skip the background/foreground/NaN rows, we don't care for them
				continue
			}

			let attempt1 = scanLineFormat(line: line)
			if attempt1.count > 0 {
				stops.append(contentsOf: attempt1)
				continue
			}
		}

		return PAL.Gradients(gradient: PAL.Gradient(stops: stops))
	}
}

let _rgbSeparator = CharacterSet(["/"])

private extension PAL.Gradients.Coder.CPT {

	func scanColor(_ scanner: Scanner) -> PAL.Color? {

		let tag = scanner.tagLocation()

		// scan for "r g b"
		if
			let r1 = scanner._scanInt(in: 0 ... 255),
			let g1 = scanner._scanInt(in: 0 ... 255),
			let b1 = scanner._scanInt(in: 0 ... 255)
		{
			return try? PAL.Color(r255: UInt8(r1), g255: UInt8(g1), b255: UInt8(b1))
		}

		// Reset back to the start of the color section
		scanner.resetLocation(tag)

		// scan for "r/g/b"
		if
			let r1 = scanner._scanInt(in: 0 ... 255),
			let _ = scanner._scanCharacters(in: _rgbSeparator),
			let g1 = scanner._scanInt(in: 0 ... 255),
			let _ = scanner._scanCharacters(in: _rgbSeparator),
			let b1 = scanner._scanInt(in: 0 ... 255)
		{
			return try? PAL.Color(r255: UInt8(r1), g255: UInt8(g1), b255: UInt8(b1))
		}

		// Reset back to the start of the color section
		scanner.resetLocation(tag)

		// scan for "#RRGGBB"
		let hexCS = CharacterSet.alphanumerics.union(CharacterSet(["#"]))
		if let hexRGB = scanner._scanCharacters(in: hexCS),
			let color = try? PAL.Color(rgbaHexString: hexRGB)
		{
			return color
		}

		// Reset back to the start of the color section
		scanner.resetLocation(tag)

		// scan for color names
		if let str = scanner._scanCharacters(in: .alphanumerics)?.lowercased(),
			let color = PAL.Palette.X11ColorPalette.color(named: str)
		{
			return color
		}

		// Reset back to the start of the color section
		scanner.resetLocation(tag)

		// A simple grayscale value maybe?
		if let gr1 = scanner._scanInt(in: 0 ... 255),
			let color = try? PAL.Color(white255: UInt8(gr1))
		{
			return color
		}

		// Reset back to the start of the color section
		scanner.resetLocation(tag)

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

private let _positionFormatter = NumberFormatter(minimumFractionDigits: 0, maximumFractionDigits: 5, decimalSeparator: ".")

public extension PAL.Gradients.Coder.CPT {
	/// Encode the gradient using CPT format (CPT Gradient)
	/// - Parameter gradients: The gradients to encode
	/// - Returns: encoded data
	func encode(_ gradients: PAL.Gradients) throws -> Data {

		// Basic format
		//
		// # comment header
		// # COLOR_MODEL = RGB
		//  0  152/10/114     50  253/215/243
		// 50  253/215/243    99  84/10/64
		// 99  84/10/64      100  84/10/64

		guard let gradient = gradients.gradients.first else {
			ColorPaletteLogger.log(.error, "CPTCoder: No gradients to export")
			throw PAL.GradientError.noGradients
		}

		if gradients.gradients.count > 1 {
			ColorPaletteLogger.log(.info, "CPTCoder: Exporting first gradient only...")
		}

		var result = """
# CPT gradient file
# Generated by ColorPaletteCodable
# COLOR_MODEL = RGB

"""
		if let name = gradient.name {
			result += "# NAME = \(name)\n"
		}

		try gradient.stops.enumerated().forEach { item in

			let stop = item.element
			let first = (item.offset == 0)
			let last = (item.offset == gradient.stops.count - 1)

			// Position
			let ps = _positionFormatter.string(for: stop.position)!
			// Color
			let rgb = try stop.color.converted(to: .RGB).rgba255Components()

			// Encoded color
			let ec = "\(ps)\t\(rgb.r)/\(rgb.g)/\(rgb.b)"

			// Write
			result += ec

			if first == false && last == false {
				// Repeat the last stop on a new line
				result += "\n\(ec)\t"
			}
			else {
				result += "\t"
			}
		}

		guard let data = result.data(using: .utf8) else {
			ColorPaletteLogger.log(.error, "CPTCoder: invalid utf8 data during write")
			throw PAL.GradientError.invalidStringData
		}

		return data
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let cpt = UTType("public.dagronf.cpt")!
}
#endif
