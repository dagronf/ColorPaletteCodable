//
//  GGRGradientCoder.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
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

public extension PAL.Gradient.Coder {
	/// GIMP gradient encoder/decoder
	struct GGR: PAL_GradientCoder {

		public enum GimpGradientError: Error {
			case invalidData
			case unexpectedTextEncoding
			case notEnoughData
			case missingBOM
			case missingName
			case invalidCount
			case unsupportedSegmentFormat
		}

		/// The coder's file format
		public static let fileExtension = "ggr"

		/// Create
		public init() {}

		/// Attempt to decode a gradient using the
		/// - Parameter inputStream: The input stream containing the data
		/// - Returns: a gradient
		public func decode(from inputStream: InputStream) throws -> PAL.Gradient {
			let data = inputStream.readAllData()
			guard let content = String(bytes: data, encoding: .utf8) else {
				ASEPaletteLogger.log(.error, "GGRCoder: Unexpected text encoding")
				throw GimpGradientError.unexpectedTextEncoding
			}

			// Remove any blank lines from the input file
			let lines = content.components(separatedBy: .newlines).filter { $0.count > 0 }
			guard lines.count > 3 else {
				ASEPaletteLogger.log(.error, "GGRCoder: Not enough data in file")
				throw GimpGradientError.notEnoughData
			}

			// Read the BOM
			guard lines[0] == "GIMP Gradient" else {
				ASEPaletteLogger.log(.error, "GGRCoder: Invalid file format (missing header)")
				throw GimpGradientError.missingBOM
			}

			// Read the name line
			guard lines[1].hasPrefix("Name: ") else {
				ASEPaletteLogger.log(.error, "GGRCoder: Invalid file format (missing name)")
				throw GimpGradientError.missingName
			}
			let name = lines[1].suffix(from: lines[1].index(lines[1].startIndex, offsetBy: 6))

			// Read the number of stops
			guard
				let stopCount = Int(lines[2]),
				lines.count == stopCount + 3
			else {
				ASEPaletteLogger.log(.error, "GGRCoder: Invalid palette count")
				throw GimpGradientError.invalidCount
			}

			var stops: [PAL.Gradient.Stop] = []

			for index in (3 ..< 3 + stopCount) {
				let stop = lines[index].components(separatedBy: " ")
				guard stop.count == 13 else { continue }

				guard
					let startPoint = Double(stop[0]),
					let _ = Double(stop[1]),							// midPoint - ignored
					let endPoint = Double(stop[2]),
					let r0 = Float32(stop[3]),
					let g0 = Float32(stop[4]),
					let b0 = Float32(stop[5]),
					let a0 = Float32(stop[6]),
					let r1 = Float32(stop[7]),
					let g1 = Float32(stop[8]),
					let b1 = Float32(stop[9]),
					let a1 = Float32(stop[10]),
					let _ = Int(stop[11]),								// This is the gradient function type - we will ignore
					let GimpGradientSegmentType = Int(stop[12])	// This is the segment color function type, we only support RGB (0)
				else {
					continue
				}

				if GimpGradientSegmentType != 0 {
					ASEPaletteLogger.log(.error, "GGRCoder: Unsupported segment format (%d)", GimpGradientSegmentType)
					throw GimpGradientError.unsupportedSegmentFormat
				}

				let sc = PAL.Color.rgb(r0, g0, b0, a0)
				let s1 = PAL.Gradient.Stop(position: startPoint, color: sc)

				// Given that GGR format works on gradient segments (eg. 0.0 -> 0.2, 0.2 -> 1.0), the end point of the
				// last stop and the start point of the next stop may be the same. If they are the same, lets just
				// ignore the new 'start' point.
				if s1 != stops.last {
					stops.append(s1)
				}

				let ec = PAL.Color.rgb(r1, g1, b1, a1)
				let e1 = PAL.Gradient.Stop(position: endPoint, color: ec)
				stops.append(e1)
			}

			return PAL.Gradient(name: String(name), stops: stops)

		}

		/// Encode the gradient using the default JSON format
		/// - Parameter gradient: The gradient to encode
		/// - Returns: encoded data
		public func encode(_ gradient: PAL.Gradient) throws -> Data {

			// Make sure all positions are 0 -> 1, and are ordered from 0 to 1
			let exportGradient = try gradient.normalized().sorted

			var result = "GIMP Gradient\n"
			result += "Name: \(exportGradient.name ?? "")\n"

			let numberOfLines = exportGradient.stops.count - 1

			result += "\(numberOfLines)\n"

			for index in (0 ..< numberOfLines) {
				let left  = exportGradient.stops[index]
				let right = exportGradient.stops[index + 1]
				let sp = left.position
				let sps = String(format: "%0.5f", sp)
				let ep = right.position
				let eps = String(format: "%0.5f", ep)
				let mp = ((ep - sp) / 2.0) + sp
				let mps = String(format: "%0.5f", mp)

				let lc = try left.color.rgbValues()
				let rc = try right.color.rgbValues()

				// position
				result += "\(sps) \(mps) \(eps) "

				// left color
				let lcrs = String(format: "%0.5f", lc.r)
				let lcgs = String(format: "%0.5f", lc.g)
				let lcbs = String(format: "%0.5f", lc.b)
				let lcas = String(format: "%0.5f", left.color.alpha)
				result += "\(lcrs) \(lcgs) \(lcbs) \(lcas) "

				// right color
				let rcrs = String(format: "%0.5f", rc.r)
				let rcgs = String(format: "%0.5f", rc.g)
				let rcbs = String(format: "%0.5f", rc.b)
				let rcas = String(format: "%0.5f", right.color.alpha)
				result += "\(rcrs) \(rcgs) \(rcbs) \(rcas) "

				// functions
				result += "0 0\n"
			}

			guard let data = result.data(using: .utf8) else {
				ASEPaletteLogger.log(.error, "GGRCoder: invalid utf8 data during write")
				throw GimpGradientError.invalidData
			}

			return data
		}
	}
}
