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

// GNUPlot gradient definition

import Foundation

public extension PAL.Gradients.Coder {
	/// GIMP gradient encoder/decoder
	///
	/// ```
	/// # Gnuplot colour map
	/// # cptutils 1.46, Wed Aug 15 23:30:10 2012
	/// 0.00000 0.00000 0.21176 0.00000
	/// 0.00790 0.00000 0.21176 0.00000
	/// 0.01590 0.00000 0.21176 0.00000
	/// 0.02380 0.00000 0.21176 0.00000
	/// 0.03170 0.00000 0.21176 0.00000
	///   ...
	/// ```
	struct GPF: PAL_GradientsCoder {

		/// The coder's file format
		public static let fileExtension = "gpf"

		/// Create
		public init() {}
	}
}

public extension PAL.Gradients.Coder.GPF {
	/// Decode a gradient using the GIMP Gradient format
	/// - Parameter inputStream: The input stream containing the data
	/// - Returns: a gradient
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		// Load a string from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			ColorPaletteLogger.log(.error, "GGRCoder: Unexpected text encoding")
			throw PAL.CommonError.invalidFormat
		}

		let content = decoded.text

		// Remove any blank lines from the input file
		let lines = content.components(separatedBy: .newlines)
			.filter { $0.count > 0 }
			.filter { $0.starts(with: "#") == false }
		guard lines.count > 0 else {
			ColorPaletteLogger.log(.error, "GGRCoder: Not enough data in file")
			throw PAL.CommonError.invalidFormat
		}

		let gradientStops: [PAL.Gradient.Stop] = lines.compactMap { line in
			let scanner = Scanner(string: line)

			var p: Float = 0
			var r: Float = 0
			var g: Float = 0
			var b: Float = 0

			var result: PAL.Gradient.Stop? = nil

			if
				scanner.scanFloat(&p),
				scanner.scanFloat(&r),
				scanner.scanFloat(&g),
				scanner.scanFloat(&b),
				let color = try? PAL.Color(rf: Float32(r), gf: Float32(g), bf: Float32(b))
			{
				result = PAL.Gradient.Stop(position: Double(p), color: color)
			}
			return result
		}
		return PAL.Gradients(gradients: [PAL.Gradient(stops: gradientStops)])
	}
}

private let _defaultDoubleFormatter = NumberFormatter {
	$0.minimumFractionDigits = 1
	$0.maximumFractionDigits = 3
}

public extension PAL.Gradients.Coder.GPF {
	/// Encode the gradient using GGR format (GIMP Gradient)
	/// - Parameter gradient: The gradient to encode
	/// - Returns: encoded data
	func encode(_ gradients: PAL.Gradients) throws -> Data {
		// GGR only supports a single gradient, so just grab the first one
		guard let gradient = gradients.gradients.first else {
			ColorPaletteLogger.log(.error, "GPFCoder: invalid utf8 data during write")
			throw PAL.CommonError.unknownBlockType
		}

		var result = """
		# Gnuplot colour map
		# Generated with ColorPaletteCodable

		"""

		for stop in gradient.stops {
			let position = stop.position
			let c = try stop.color.rgbaComponents()
			guard
				let ps = _defaultDoubleFormatter.string(for: position),
				let rs = _defaultDoubleFormatter.string(for: c.r),
				let gs = _defaultDoubleFormatter.string(for: c.g),
				let bs = _defaultDoubleFormatter.string(for: c.b)
			else {
				ColorPaletteLogger.log(.error, "GPFCoder: cannot generate")
				throw PAL.CommonError.unknownBlockType
			}

			result += "\(ps) \(rs) \(gs) \(bs)\n"
		}

		guard let data = result.data(using: .utf8) else {
			ColorPaletteLogger.log(.error, "GPFCoder: invalid utf8 data during write")
			throw PAL.CommonError.unknownBlockType
		}

		return data
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let gpf = UTType("public.dagronf.gnuplot.gpf")!
}
#endif
