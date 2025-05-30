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
	struct CSSGradientCoder: PAL_GradientsCoder {
		/// The gradients format
		public static var format: PAL.GradientsFormat { .css }
		/// The coder's file format
		public static let fileExtension = "css"
		/// The uniform type string for the gradient type
		public static let utTypeString = "public.css"

		/// Create
		public init() {}

		/// Attempt to parse gradient definitions from CSS text
		/// - Parameter text: The text to parse
		/// - Returns: A list of gradients
		public static func parse(_ text: String) -> PAL.Gradients {
			return __parseLinearGradients(text)
		}
	}
}

/// A formatter for generating a percentage value for css export
///
/// Note that CSS always expects a '.' as the decimal separator
private let percentFormatter__ = NumberFormatter {
	$0.minimumFractionDigits = 0
	$0.maximumFractionDigits = 3
	$0.decimalSeparator = "."
	$0.numberStyle = .percent
}

public extension PAL.Gradients.Coder.CSSGradientCoder {
	/// Decode gradient(s) from the content of a CSS file
	/// - Parameter inputStream: The input stream containing the data
	/// - Returns: a gradient
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		// Load a string from the input stream
		guard let decoded = String.decode(from: inputStream) else {
			ColorPaletteLogger.log(.error, "CSSGradientCoder: Unexpected text encoding")
			throw PAL.CommonError.invalidString
		}
		return __parseLinearGradients(decoded.text)
	}

	/// Encode the gradient using GGR format (GIMP Gradient)
	/// - Parameter gradients: The gradients to encode
	/// - Returns: encoded data
	func encode(_ gradients: PAL.Gradients) throws -> Data {

		var result = ""

		try gradients.gradients.forEach { gradient in

			// "linear-gradient(to right, rgb(110, 231, 183, 0.1), rgb(59, 130, 246, 0.7), rgb(147, 51, 234))"

			result += "background-image: linear-gradient("

			let g = try gradient.normalized().mergeTransparencyStops()
			var calls: [String] = []
			try g.stops.forEach { stop in
				var text = try stop.color.css(includeAlpha: stop.color.alpha < 1.0)
				let position: Double = stop.position
				guard let ps = percentFormatter__.string(for: position) else {
					ColorPaletteLogger.log(.error, "CSSGradientCoder: Unable to generate percent string")
					throw PAL.CommonError.invalidString
				}
				text += " \(ps)"
				calls.append(text)
			}
			result += calls.joined(separator: ", ")

			result += ");\n"
		}
		guard let data = result.data(using: .utf8) else {
			ColorPaletteLogger.log(.error, "CSSGradientCoder: invalid utf8 data during write")
			throw PAL.CommonError.invalidString
		}

		return data
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let cssGradients = UTType(PAL.Gradients.Coder.CSSGradientCoder.utTypeString)!
}
#endif

// MARK: - Parsing internals

private func __parseLinearGradients(_ text: String) -> PAL.Gradients {

	var parser = TextParser(text: text)

	var gradients = PAL.Gradients()

	while parser.moveToNextInstance(of: "-gradient(") {
		var complete = false
		var components: [String] = []

		//let startPosition = parser.currentIndex

		while !complete {
			var stillChecking = true
			var content = ""
			var insideFunc = false
			// We want to read to the next ',' instance, but ONLY if we're not inside a function
			while stillChecking && !parser.isAtEnd {
				guard let ch = parser.next() else {
					stillChecking = false
					complete = true
					continue
				}

				if ch == "(" {
					content.append(ch)
					insideFunc = true
				}
				else if ch == ")" {
					if insideFunc {
						content.append(ch)
						insideFunc = false
					}
					else {
						// Function complete
						stillChecking = false
						complete = true
					}
				}
				else if ch == "," && !insideFunc {
					stillChecking = false
				}
				else {
					content.append(ch)
				}
			}
			components.append(content)
		}

		//let endPosition = parser.currentIndex

		// Each component is a function argument for linear-gradient
		var stops: [GStop] = []
		for component in components {
			let c = component.trim()

			// First, lets see if its an rgb[a] definition
			if let gstop = parseCSSRGBA(c) {
				stops.append(gstop)
			}
			else if let gstop = parseCSSHex(c) {
				stops.append(gstop)
			}
			else if let gstop = parseCSSColorName(c) {
				stops.append(gstop)
			}
			else if let gstop = parseCSSHSLA(c) {
				stops.append(gstop)
			}
		}

		if stops.isNotEmpty {
			// Map the colors to a gradient
			if stops.filter({ $0.stop != nil }).count == 0 {
				// Special case. All elements of the stops are missing positioning information - therefore
				// spread them evenly out over the entirety of the gradient (ie. 0.0 ... 1.0)
				let gradient = PAL.Gradient(colors: stops.map { $0.color })
				gradients.gradients.append(gradient)
			}
			else if stops.filter({ $0.stop == nil }).count == 0 {
				// All stops have a position
				let allStops = stops.compactMap { PAL.Gradient.Stop(position: $0.stop ?? 0.0, color: $0.color) }
				if let g = try? PAL.Gradient(stops: allStops).extendingUnitStopsToEdges() {
					gradients.gradients.append(g)
				}
			}
			else if stops.first?.stop == nil && stops.last?.stop == nil {
				// First stop and last stop are both missing info -- therefore they are 0 and 1
				stops.first?.stop = 0
				stops.last?.stop = 1
				let allStops = stops.compactMap { PAL.Gradient.Stop(position: $0.stop ?? 0.0, color: $0.color) }
				let gradient = PAL.Gradient(stops: allStops)
				if let g = try? gradient.normalized() {
					gradients.gradients.append(g)
				}
			}
			else {
				// A mix of specified and non-specified.  Deal with this later
			}
		}
	}

	return gradients
}


// MARK: - Parsing

private class GStop {
	let color: PAL.Color
	var stop: Double?
	init(color: PAL.Color, stop: Double?) {
		self.color = color
		self.stop = stop
	}
}

// MARK: Color name definition

private let colorNamePattern = try! DSFRegex(#"\b(\w*)\b(?:\s*([\d\.]+)%)?"#)
private func parseCSSColorName(_ component: String) -> GStop? {
	let searchResult = colorNamePattern.matches(for: component)
	guard let match = searchResult.matches.first else { return nil }
	let colorName = component[match.captures[0]]
	let p1str = component[match.captures[1]]

	// Should be a astandard X11 color name
	guard let color = PAL.Palette.X11ColorPalette.color(named: String(colorName)) else {
		return nil
	}

	let position: Double?
	if let p = Double(p1str) {
		position = p.clamped(to: 0.0 ... 100.0) / 100.0
	}
	else {
		position = nil
	}

	return GStop(color: color, stop: position)
}

// MARK: Parse Hex definition

private let hexPattern = try! DSFRegex(#"#([0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{4}|[0-9a-fA-F]{3})(?:\s*([\d\.]+)%)?"#)
private func parseCSSHex(_ component: String) -> GStop? {
	let searchResult = hexPattern.matches(for: component)
	guard searchResult.matches.count == 1 else { return nil }
	let match = searchResult.matches[0]
	if match.captures.count == 0 { return nil }
	let hexValue = component[match.captures[0]]
	let p1str = component[match.captures[1]]

	guard let color = try? PAL.Color(rgbHexString: String(hexValue), format: .rgba) else {
		return nil
	}

	let position: Double?
	if let p = Double(p1str) {
		position = p.clamped(to: 0.0 ... 100.0) / 100.0
	}
	else {
		position = nil
	}

	return GStop(color: color, stop: position)
}

// MARK: Parse RGB[A] definition

private let rgbaPattern = try! DSFRegex(#"rgba?\(\s*(\b\d{1,3}\b)\s*,\s*(\b\d{1,3}\b)\s*,\s*(\b\d{1,3}\b)(?:\s*,\s*(\d*\.?\d+))?\)\s*(?:([\d\.]+)%?)?"#)
private func parseCSSRGBA(_ component: String) -> GStop? {
	let searchResult = rgbaPattern.matches(for: component)
	guard searchResult.matches.count == 1 else { return nil }
	let match = searchResult.matches[0]

	let rstr = component[match.captures[0]]		// r component
	let gstr = component[match.captures[1]]		// g component
	let bstr = component[match.captures[2]]		// b component
	let astr = component[match.captures[3]]		// a percent
	let p1str = component[match.captures[4]]		// first percentage

	guard
		let r = UInt8(rstr),
		let g = UInt8(gstr),
		let b = UInt8(bstr)
	else {
		return nil
	}

	let a: Double? = Double(astr)

	let alpha: Double
	if astr.count > 0 {
		guard let a = a else {
			// User specified an alpha, but we couldn't convert it
			return nil
		}
		if (0.0 ... 1.0).contains(a) == false {
			// User specified an alpha, but we couldn't convert it
			return nil
		}
		alpha = a
	}
	else {
		alpha = 1.0
	}

	let color = PAL.Color(r255: r, g255: g, b255: b, a255: _f2p(alpha))

	let position: Double?
	if let p = Double(p1str) {
		position = p.clamped(to: 0.0 ... 100.0) / 100.0
	}
	else {
		position = nil
	}

	return GStop(color: color, stop: position)
}


// MARK: HSL

let hslPattern = try! DSFRegex(#"hsla?\(\s*(\b[\d\.]+\b)\s*,\s*(\b[\d\.]+\b)%\s*,\s*(\b[\d\.]+\b)%\s*(?:\s*,\s*(\d*\.?\d+))?\)\s*(?:([\d\.]+)%?)?"#)
private func parseCSSHSLA(_ component: String) -> GStop? {
	let searchResult = hslPattern.matches(for: component)
	guard searchResult.matches.count == 1 else { return nil }
	let match = searchResult.matches[0]

	let rstr = component[match.captures[0]]		// h component (0 ... 360)
	let gstr = component[match.captures[1]]		// s component (0 ... 100)
	let bstr = component[match.captures[2]]		// l component (0 ... 100)
	let astr = component[match.captures[3]]		// a percent
	let p1str = component[match.captures[4]]		// first percentage

	guard
		let h = Int(rstr),
		(0 ... 360).contains(h),
		let s = Int(gstr),
		(0 ... 100).contains(s),
		let l = Int(bstr),
		(0 ... 100).contains(l)
	else {
		return nil
	}

	let a: Double? = Double(astr)

	let alpha: Double
	if astr.count > 0 {
		guard let a = a else {
			// User specified an alpha, but we couldn't convert it
			return nil
		}
		if (0.0 ... 1.0).contains(a) == false {
			// User specified an alpha, but we couldn't convert it
			return nil
		}
		alpha = a
	}
	else {
		alpha = 1.0
	}

	let color = PAL.Color(h360: Double(h), s100: Double(s), l100: Double(l), af: alpha)

	let position: Double?
	if let p = Double(p1str) {
		position = p.clamped(to: 0.0 ... 100.0) / 100.0
	}
	else {
		position = nil
	}

	return GStop(color: color, stop: position)
}
