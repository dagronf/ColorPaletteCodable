//
//  SwiftGenGradientCoder.swift
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

// Coder for generating SwiftUI and Swift code

import Foundation

// MARK: - Swift CoreGraphics generator

public extension PAL.Gradients.Coder {
	/// A Swift code generator for gradients
	struct SwiftGen: PAL_GradientsCoder {
		/// The coder's file format. We cannot load or save for this type
		public static let fileExtension = ""
		public init() {}
	}
}

public extension PAL.Gradients.Coder.SwiftGen {
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		// No decoding!
		throw PAL.CommonError.notImplemented
	}
}

private let floatFormatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.maximumFractionDigits = 4
	formatter.minimumFractionDigits = 4
	formatter.decimalSeparator = "."
	return formatter
}()

public extension PAL.Gradients.Coder.SwiftGen {
	func encode(_ gradients: PAL.Gradients) throws -> Data {
		var result = ""
		try gradients.gradients.enumerated().forEach { item in
			let gradient = item.element
			// Make sure stops are arranged 0 ... 1, and sorted from 0 ... 1
			let comps: [([Double], Double)] = try gradient.normalized().sorted.stops.map {
				let components = try $0.color.rgbaComponents()
				let position = $0.position
				return ([components.0, components.1, components.2, components.3], position)
			}

			result += "// Gradient stops definition"
			if let name = gradient.name {
				result += " (\(name))"
			}
			result += "\n"

			result += "let gradient\(item.offset + 1): CGGradient = {\n"
			result += "   let cs = CGColorSpace(name: CGColorSpace.sRGB)!\n"
			result += "   let stops: [(CGFloat, CGColor)] = [\n"
			result += comps.map { comp in
				let compss = comp.0.map { floatFormatter.string(for: $0)! }.joined(separator: ", ")
				let loc = floatFormatter.string(for: comp.1)!
				return "      (\(loc), CGColor(colorSpace: cs, components: [\(compss)])!)"
			}.joined(separator: ",\n")
			result += "\n"
			result += "   ]\n"

			result += "   let colors: [CGColor] = stops.map { $0.1 }\n"
			result += "   let locations: [CGFloat] = stops.map { $0.0 }\n"

			result += "   return CGGradient(colorsSpace: cs, colors: colors as CFArray, locations: locations)!\n"
			result += "}()\n"
		}

		return result.data(using: .utf8)!
	}
}

// MARK: - SwiftUI generator

public extension PAL.Gradients.Coder {
	/// A coder for PSP gradients
	struct SwiftUIGen: PAL_GradientsCoder {
		/// The coder's file format. We cannot load or save for this type
		public static let fileExtension = ""
		public init() {}
	}
}

public extension PAL.Gradients.Coder.SwiftUIGen {
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		throw PAL.CommonError.notImplemented
	}
}

public extension PAL.Gradients.Coder.SwiftUIGen {
	func encode(_ gradients: PAL.Gradients) throws -> Data {
		var result = ""
		try gradients.gradients.enumerated().forEach { item in
			let gradient = item.element
			// Make sure stops are arranged 0 ... 1, and sorted from 0 ... 1
			let normalized = try gradient.normalized().sorted.stops

			result += "// Gradient stops definition"
			if let name = gradient.name {
				result += " (\(name))"
			}
			result += "\n"

			result += "let gradientStops\(item.offset + 1): [Gradient.Stop] = [\n"

			let stopsStrings: [String] = try normalized.map { stop in
				let color = stop.color

				// SwiftUI colors are easier in RGB
				let rgba: (Double, Double, Double, Double) = try color.rgbaComponents()

				let rs  = floatFormatter.string(for: rgba.0)!
				let gs  = floatFormatter.string(for: rgba.1)!
				let bs  = floatFormatter.string(for: rgba.2)!
				let aas = floatFormatter.string(for: rgba.3)!
				let locs = floatFormatter.string(for: stop.position)!

				let colorString = "Color(red: \(rs), green: \(gs), blue: \(bs), opacity: \(aas))"

				return "   Gradient.Stop(color: \(colorString), location: \(locs))"
			}

			result += stopsStrings.joined(separator: ",\n")
			result += "\n"
			result += "]\n"
		}

		return result.data(using: .utf8)!
	}
}

