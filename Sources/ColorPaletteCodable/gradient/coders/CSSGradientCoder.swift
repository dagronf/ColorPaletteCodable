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

			if parser.isAtEnd {
				stillChecking = false
				complete = true
			}
		}

		//let endPosition = parser.currentIndex

		// Each component is a function argument for linear-gradient
		var stops: [__GradientStop] = []
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

		// If we found no stops, move on to the next
		if stops.isEmpty {
			continue
		}

		// Map the colors to a gradient
		if stops.countWhere({ $0.position != nil }) == 0 {
			// Special case. All elements of the stops are missing positioning information - therefore
			// spread them evenly out over the entirety of the gradient (ie. 0.0 ... 1.0)
			let gradient = PAL.Gradient(colors: stops.map { $0.color })
			gradients.gradients.append(gradient)
		}
		else if stops.countWhere({ $0.position == nil }) == 0 {
			// All stops have a position
			let allStops = stops.compactMap { PAL.Gradient.Stop(position: $0.position ?? 0.0, color: $0.color) }
			if let g = try? PAL.Gradient(stops: allStops).extendingUnitStopsToEdges() {
				gradients.gradients.append(g)
			}
		}
		else {
			// Handle some special cases
			if stops.first?.position == nil {
				// First is missing a position -- assume 0
				stops.first?.position = 0
			}

			if stops.last?.position == nil {
				// Last is missing a position -- assume 1
				stops.last?.position = 1
			}

			let allStops: [PAL.Gradient.Stop] = stops.compactMap {
				if let position = $0.position {
					return PAL.Gradient.Stop(position: position, color: $0.color)
				}
				// If the stop doesn't have a position we'll ignore it for now
				return nil
			}

			if allStops.count > 1,
				let rawGradient = try? PAL.Gradient(stops: allStops).extendingUnitStopsToEdges(),
				let gradient = try? rawGradient.normalized() {
				gradients.gradients.append(gradient)
			}
		}
	}

	return gradients
}

// MARK: - Parsing

/// Gradient stop from the CSS
private class __GradientStop {
	let color: PAL.Color
	var position: Double?

	init(color: PAL.Color, position: Double?) {
		self.color = color
		self.position = position
	}
}

// MARK: Color name definition

private let __colorNamePattern = try! DSFRegex(#"\b(\w+)\b(?:\s*([\d\.]+)(deg|%)?)?"#)
private func parseCSSColorName(_ component: String) -> __GradientStop? {
	let searchResult = __colorNamePattern.matches(for: component)
	guard
		let match = searchResult.matches.first,
		match.captures.count == 3
	else {
		return nil
	}

	// Capture 1  -> Standard X11 color name
	// Capture 2  -> Position Value (optional)
	// Capture 3  -> Position Type (optional)

	let colorName = component[match.captures[0]]
	let positionValue = component[match.captures[1]]
	let positionType = component[match.captures[2]]

	let position = parsePosition(positionValue, positionType)

	// Should be a standard X11 color name
	guard let color = PAL.Palette.X11ColorPalette.color(named: String(colorName)) else {
		return nil
	}

	return __GradientStop(color: color, position: position)
}

// MARK: Parse Hex definition

private let __hexPattern = try! DSFRegex(#"#([0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{4}|[0-9a-fA-F]{3})(?:\s*([\d\.]+)(deg|%)?)?"#)
private func parseCSSHex(_ component: String) -> __GradientStop? {
	let searchResult = __hexPattern.matches(for: component)

	guard
		let match = searchResult.matches.first,
		match.captures.count == 3
	else {
		return nil
	}

	// Capture 1  -> Hex component
	// Capture 2  -> Position Value (optional)
	// Capture 3  -> Position Type (optional)

	let hexValue = component[match.captures[0]]
	let positionValue = component[match.captures[1]]
	let positionType = component[match.captures[2]]

	guard let color = try? PAL.Color(rgbHexString: String(hexValue), format: .rgba) else {
		return nil
	}

	let position = parsePosition(positionValue, positionType)

	return __GradientStop(color: color, position: position)
}

// MARK: Parse RGB[A] definition

private let __rgbaPattern = try! DSFRegex(#"(?i)rgba?\(\s*([\d\.]*)(%)?[\s,]+(\b[\d\.]+\b)(%)?[\s,]+(\b[\d\.]+\b)(%)?(?:[\s,]+([\d\.]*)(deg|%)?)?\)(?:\s*([\d\.]+)(deg|%)?)?"#)
private func parseCSSRGBA(_ component: String) -> __GradientStop? {
	let searchResult = __rgbaPattern.matches(for: component)

	guard
		let match = searchResult.matches.first,
		match.captures.count == 10
	else {
		return nil
	}

	// Capture 1  -> red value
	// Capture 2  -> red type (eg. % (0 ... 100) or nil (0 ... 255)
	// Capture 3  -> green value
	// Capture 4  -> green type (eg. % (0 ... 100) or nil (0 ... 255)
	// Capture 5  -> blue value
	// Capture 6  -> blue type (eg. % (0 ... 100) or nil (0 ... 255)
	// Capture 7  -> Alpha value. [Optional]
	// Capture 8  -> Alpha type eg. % (0 ... 100) or nil (0.0 ... 1.0) [Optional]
	// Capture 9  -> Position value [Optional]
	// Capture 10 -> Position type (deg, %, float) [Optional]

	let rValue = component[match.captures[0]]
	let rType  = component[match.captures[1]]
	let gValue = component[match.captures[2]]
	let gType  = component[match.captures[3]]
	let bValue = component[match.captures[4]]
	let bType  = component[match.captures[5]]

	let alpValue = component[match.captures[6]]
	let alpType  = component[match.captures[7]]

	let posValue = component[match.captures[8]]
	let posType  = component[match.captures[9]]

	guard
		let r = parseRGBValue(rValue, rType),
		let g = parseRGBValue(gValue, gType),
		let b = parseRGBValue(bValue, bType)
	else {
		return nil
	}

	let alpha = parseAlpha(alpValue, alpType)
	let position = parsePosition(posValue, posType)
	let color = PAL.Color(rf: r, gf: g, bf: b, af: alpha)

	return __GradientStop(color: color, position: position?.unitClamped)
}

// MARK: HSL

private let __hslPattern = try! DSFRegex(#"(?i)hsla?\(\s*([\d\.]*)(deg)?[\s,]+(\b[\d\.]+\b)%?[\s,]+(\b[\d\.]+\b)%?(?:[\s,]+([\d\.]*)(deg|%)?)?\)(?:\s(\b[\d\.]+\b)(%)?)?"#)
private func parseCSSHSLA(_ component: String) -> __GradientStop? {
	let searchResult = __hslPattern.matches(for: component)

	guard
		let match = searchResult.matches.first,
		match.captures.count == 8
	else {
		return nil
	}

	// Capture 1 -> Hue value (angle)
	// Capture 2 -> Hue type (eg. degrees or not specified) [Optional]
	// Capture 3 -> Saturation value (always percent)
	// Capture 4 -> Lightness value (always percent)
	// Capture 5 -> Alpha value. [Optional]
	// Capture 6 -> Alpha type (percent or float) [Optional]
	// Capture 7 -> Position value [Optional]
	// Capture 8 -> Position type (deg, %, float) [Optional]

	let hueValue = component[match.captures[0]]   // h component (0 ... 360)
	//let hueType  = component[match.captures[1]]   // h metric (eg. deg or nil - always a degrees value tho)
	let satValue = component[match.captures[2]]   // s component (0 ... 100)
	let litValue = component[match.captures[3]]   // l component (0 ... 100)

	let alpValue = component[match.captures[4]]   // alpha value
	let alpType  = component[match.captures[5]]   // alpha type

	let posValue = component[match.captures[6]]   // The position value
	let posType  = component[match.captures[7]]   // The position type (could be %, degrees, float or nil)

	guard
		let h = Double(hueValue),
		let s = Double(satValue),
		let l = Double(litValue)
	else {
		return nil
	}

	let alpha = parseAlpha(alpValue, alpType)

	let position = parsePosition(posValue, posType)
	let color = PAL.Color(h360: h, s100: s, l100: l, af: alpha)
	return __GradientStop(color: color, position: position)
}

// MARK: - Parsing helpers

/// Always returns a value 0 ... 1 or nil
private func parseRGBValue(_ value: Substring, _ type: Substring) -> Double? {
	guard let value = Double(value) else { return nil }
	switch type.lowercased() {
	case "%": return value / 100.0		// A percentage value
	case "deg": return value / 360.0		// A degrees value (for conic-style gradients)
	default: return value / 255.0			// A simple 0 ... 255 value
	}
}

/// Always returns a value 0 ... 1 or nil
private func parsePosition(_ value: Substring, _ type: Substring) -> Double? {
	if value.isEmpty { return nil }
	let type = type.lowercased()
	var position: Double?
	if let value = Double(value) {
		switch type {
		case "deg": position = value / 360.0		// degrees
		case "%": position = value / 100.0			// percentage
		default:
			// Assume a float value
			position = value								// fraction?
		}
	}
	return position
}

/// Always returns a value 0 ... 1 or nil
private func parseAlpha(_ value: Substring, _ type: Substring) -> Double {
	var alpha: Double = 1.0
	if value.isNotEmpty {
		let type = type.lowercased()
		if let alpValue = Double(value) {
			switch type {
			case "%": alpha = alpValue / 100
			default:
				// Assume float (?)
				alpha = alpValue
			}
		}
	}
	return alpha
}
