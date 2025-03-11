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

public extension PAL.Gradients.Coder {
	/// A coder for DCG (Binary colorpalettecodable) gradients
	struct DCG: PAL_GradientsCoder {
		/// The coder's file format
		public static let fileExtension = "dcg"
		public init() {}
	}
}

// MARK: - Encoding

private let BOM__: UInt16 = 32157
private let version__: UInt16 = 1
private let gradientsHeader__: UInt16 = 28678
private let gradientIdentifier__: UInt8 = 0xA0

private let stopsHeader__: UInt16 = 8600
private let stopIdentifier__: UInt8 = 0x34

private let transparencyStopsHeader__: UInt16 = 8601
private let transparencyStopIdentifier__: UInt8 = 0xBD

public extension PAL.Gradients.Coder.DCG {
	func encode(_ gradients: PAL.Gradients) throws -> Data {
		let file = DataWriter()

		// Expected BOM
		try file.writeUInt16(BOM__, .little)

		// Version
		try file.writeUInt16(version__, .little)

		// Gradients header
		try file.writeUInt16(gradientsHeader__, .little)

		// The number of gradients
		try file.writeUInt16(UInt16(gradients.gradients.count), .little)

		for gradient in gradients.gradients {
			/// Gradient header
			try file.writeUInt8(gradientIdentifier__)

			/// The gradient name
			try file.writePascalStringUTF16(gradient.name, .little)

			// Stops header
			try file.writeUInt16(stopsHeader__, .little)

			/// The number of gradient stops
			try file.writeUInt16(UInt16(gradient.stops.count), .little)

			for stop in gradient.stops {
				// Stop header
				try file.writeUInt8(stopIdentifier__)

				// The color
				try file.writeColor(stop.color)

				// The position
				try file.writeFloat32(Float32(stop.position), .little)
			}

			// Transparency stops header
			try file.writeUInt16(transparencyStopsHeader__, .little)

			// The gradients transparency stops
			let transparencyStops: [PAL.Gradient.TransparencyStop] = gradient.transparencyStops ?? []

			// The number of transparency stops
			try file.writeUInt16(UInt16(transparencyStops.count), .little)

			for transparencyStop in transparencyStops {
				// Transparency stop identifier
				try file.writeUInt8(transparencyStopIdentifier__)

				// Transparency stop value (0.0 ... 1.0)
				try file.writeFloat32(Float32(transparencyStop.value), .little)

				// Transparency position (0.0 ... 1.0)
				try file.writeFloat32(Float32(transparencyStop.position), .little)

				// Transparency midpoint (0.0 ... 1.0)
				try file.writeFloat32(Float32(transparencyStop.midpoint), .little)
			}
		}

		return file.storage
	}
}

// MARK: - Decode

public extension PAL.Gradients.Coder.DCG {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		let data = inputStream.readAllData()
		let parser = DataParser(data: data)

		var result = PAL.Gradients()

		// Expected BOM
		let bom = try parser.readUInt16(.little)
		guard bom == BOM__ else {
			throw PAL.CommonError.invalidBOM
		}

		// Expect version
		let version = try parser.readUInt16(.little)
		guard version == version__ else {
			throw PAL.CommonError.invalidVersion
		}

		// Gradients header
		guard try parser.readUInt16(.little) == gradientsHeader__ else {
			throw PAL.CommonError.invalidFormat
		}

		// Number of gradients
		let numGradients = try parser.readUInt16(.little)

		// Read the gradients
		result.gradients = try (0 ..< numGradients).map { _ in
			// Gradient header
			guard try parser.readUInt8() == gradientIdentifier__ else {
				throw PAL.CommonError.invalidFormat
			}

			// The gradient name
			let name = try parser.readPascalStringUTF16(.little)

			// stops header
			guard try parser.readUInt16(.little) == stopsHeader__ else {
				throw PAL.CommonError.invalidFormat
			}

			// Number of stops
			let numStops = try parser.readUInt16(.little)

			let stops: [PAL.Gradient.Stop] = try (0 ..< numStops).map { _ in
				// Stop identifier
				guard try parser.readUInt8() == stopIdentifier__ else {
					throw PAL.CommonError.invalidFormat
				}

				// Stop color
				let color = try parser.readColor()

				// Stop position
				let position = try parser.readFloat32(.little)

				// The stop
				return PAL.Gradient.Stop(position: Double(position), color: color)
			}

			// Check we've read the right number
			assert(stops.count == numStops)

			var gradient = PAL.Gradient(stops: stops, name: name)

			// transparency stops header
			guard try parser.readUInt16(.little) == transparencyStopsHeader__ else {
				throw PAL.CommonError.invalidFormat
			}

			// Number of transparency stops
			let numTransparencyStops = try parser.readUInt16(.little)

			let transparencyStops: [PAL.Gradient.TransparencyStop] = try (0 ..< numTransparencyStops).map { _ in
				// Transparency stop identifier
				guard try parser.readUInt8() == transparencyStopIdentifier__ else {
					throw PAL.CommonError.invalidFormat
				}

				// stop value
				let value = try parser.readFloat32(.little).unitClamped
				// stop position
				let position = try parser.readFloat32(.little).unitClamped
				// stop midpoint
				let midpoint = try parser.readFloat32(.little).unitClamped

				return PAL.Gradient.TransparencyStop(
					position: Double(position),
					value: Double(value),
					midpoint: Double(midpoint)
				)
			}

			// Check we've read the right number
			assert(transparencyStops.count == numTransparencyStops)

			if transparencyStops.count > 0 {
				gradient.transparencyStops = transparencyStops
			}

			return gradient
		}

		return result
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let dcg = UTType("public.dagronf.colorpalette.gradients")!
}
#endif
