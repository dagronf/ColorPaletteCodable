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
import BytesParser

public extension PAL.Gradients.Coder {
	/// A coder for GRD (Photoshop) gradients
	///
	/// References :-
	/// [1](http://www.selapa.net/swatches/gradients/fileformats.php)
	/// [2](https://github.com/Balakov/GrdToAfpalette/blob/master/palette-js/load_grd.js)
	/// [3](https://github.com/abought/grd_to_cmap/blob/master/grd_reader.py)
	/// [4](https://github.com/tonton-pixel/json-photoshop-scripting/tree/master/Documentation/Photoshop-Gradients-File-Format#descriptor)
	struct AdobeGradientsCoder: PAL_GradientsCoder {
		/// The gradients format
		public static var format: PAL.GradientsFormat { .adobeGRD }
		/// The coder's file format
		public static let fileExtension = "grd"
		/// The uniform type string for the gradient type
		public static let utTypeString = "com.adobe.grd"

		public init() {}
	}
}

public extension PAL.Gradients.Coder.AdobeGradientsCoder {
	/// Encode a GRD v3 gradient
	/// - Parameter gradients: The gradients to write
	/// - Returns: encoded data
	func encode(_ gradients: PAL.Gradients) throws -> Data {
		try GRD().writeV3(gradients)
	}
}

public extension PAL.Gradients.Coder.AdobeGradientsCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		let gradients = try GRD().readGradients(inputStream: inputStream)

		if gradients.count == 0 {
			return PAL.Gradients()
		}

		var result = PAL.Gradients(format: .adobeGRD)

		try gradients.forEach { gradient in
			var gr = PAL.Gradient(colors: [])
			gr.name = gradient.name
			let cs: [PAL.Gradient.Stop] = try gradient.colorStops.map {
				let co = $0.color
				let color: PAL.Color
				if co.colorspace == "rgb" {
					guard co.components.count >= 3 else {
						ColorPaletteLogger.log(.error, "GRD: rgb component count mismatch")
						throw PAL.GradientError.unsupportedColorFormat
					}
					color = rgbf(
						Double(co.components[0]),   // normalized 0 -> 1
						Double(co.components[1]),   // normalized 0 -> 1
						Double(co.components[2])    // normalized 0 -> 1
					)
				}
				else if co.colorspace == "hsb" {
					guard co.components.count >= 3 else {
						ColorPaletteLogger.log(.error, "GRD: hsb component count mismatch")
						throw PAL.GradientError.unsupportedColorFormat
					}
					color = PAL.Color(
						hf: Double(co.components[0] / 360.0),
						sf: Double(co.components[1] / 100.0),
						bf: Double(co.components[2] / 100.0)
					)
				}
				else if co.colorspace == "cmyk" {
					guard co.components.count >= 4 else {
						ColorPaletteLogger.log(.error, "GRD: cmyk component count mismatch")
						throw PAL.GradientError.unsupportedColorFormat
					}
					color = try PAL.Color(
						colorSpace: .CMYK,
						colorComponents: co.components.map { Double($0 / 100.0) },
						alpha: 1
					)
				}
				else if co.colorspace == "gray" {
					guard co.components.count >= 1 else {
						ColorPaletteLogger.log(.error, "GRD: gray component count mismatch")
						throw PAL.GradientError.unsupportedColorFormat
					}
					color = try PAL.Color(
						colorSpace: .Gray,
						colorComponents: [co.components[0]], //.map { Double($0 / 100.0) },
						alpha: 1
					)
				}
				else if co.colorspace == "lab" {
					guard co.components.count >= 3 else {
						ColorPaletteLogger.log(.error, "GRD: lab component count mismatch")
						throw PAL.GradientError.unsupportedColorFormat
					}
					color = try PAL.Color(
						colorSpace: .LAB,
						colorComponents: co.components.map { Double($0) },
						alpha: 1
					)
				}
				else {
					// unknown?
					ColorPaletteLogger.log(.error, "GRD: unknown color format '%@'", co.colorspace)
					throw PAL.GradientError.unsupportedColorFormat
				}

				return PAL.Gradient.Stop(position: Double($0.location) / 4096.0, color: color)
			}
			gr.stops = cs

			let trs = gradient.transparencyStops.map { stop in
				PAL.Gradient.TransparencyStop(
					position: Double(stop.location) / 4096.0,  // 0 ... 4096
					value: stop.value,                         // 0 ... 1.0
					midpoint: Double(stop.midpoint) / 100.0    // 0 ... 100
				)
			}
			if trs.count > 0 {
				gr.transparencyStops = trs
			}

			result.gradients.append(gr)
		}
		return result
	}
}


// MARK: - Gradient reading support

private class GRD {

	struct Gradient {
		let name: String
		let smoothness: Double    // 0 ..< 4096
		let colorStops: [ColorStop]
		let transparencyStops: [TransparencyStop]
	}

	struct ColorStop {
		enum ColorType {
			case userStop
			case foreground
			case background
		}
		let colorType: ColorType
		let color: Color
		let location: UInt32       // 0 ..< 4096
		let midpoint: UInt32       // percentage?
	}

	struct TransparencyStop {
		let value: Double          // 0.0 ... 1.0
		let location: UInt32       // 0 ..< 4096
		let midpoint: UInt32       // 0 ... 100
	}

	struct Color {
		let colorspace: String
		let components: [Double]
	}

	enum GRDError: Error {
		case invalidString
		case invalidFormat
		case unsupportedFormat
		case unsupportedGradientType(String)
	}

	func readGradients(inputStream: InputStream) throws -> [Gradient] {
		let reader = BytesReader(inputStream: inputStream)

		let bom = try reader.readStringASCII(length: 4)
		if bom != "8BGR" {
			throw GRDError.invalidFormat
		}
		let version: UInt16 = try reader.readUInt16(.big)
		if version == 3 {
			//throw GRDError.unsupportedFormat
			return try parseVersion3(reader)
		}
		else if version != 5 {
			throw GRDError.unsupportedFormat
		}

		// Step over the next 22 bytes (unknown)
		_ = try reader.readBytes(count: 22)

		let gradientCount = try parseGrdL(reader)
		var gradients = [Gradient]()
		for _ in 0 ..< gradientCount {
			if let gradient = try parseGradientDefinition(reader) {
				gradients.append(gradient)
			}
		}
		return gradients
	}

	func parseGradientDefinition(_ reader: BytesReader) throws -> Gradient? {
		let objcValue = try parseObjc(reader)
		guard "Gradient" == objcValue.0 else {
			throw GRDError.unsupportedFormat
		}

		let bom = try parseGrd5Typename(reader)
		guard bom == "Grad" else { throw GRDError.invalidString }

		let innerObjcValue = try parseObjc(reader)

		// name
		let parseNm = try parseNm(reader)

		let type = try parseEnum(reader, "GrdF")

		if type.1 == "CstS" {
			if innerObjcValue.2 != 5 {
				// There should be five components
				ColorPaletteLogger.log(.error, "GRDCoder: Expected five components, got %d", innerObjcValue.2)
				throw GRDError.unsupportedFormat
			}
			return try parseCustomGradient(reader, gradientName: parseNm)
		}
		else if type.1 == "ClNs" {
			if innerObjcValue.2 != 9 {
				// Nine components for noise?
				ColorPaletteLogger.log(.error, "GRDCoder: Cannot parse noise gradient, aborting")
				throw GRDError.unsupportedFormat
			}

			// Read the noise gradient components, but just ignore it
			ColorPaletteLogger.log(.info, "GRDCoder: Found noise gradient -- ignoring...")

			try parseNoiseGradient(reader)
			return nil
		}
		else {
			ColorPaletteLogger.log(.error, "GRDCoder: Unsupported gradient type (%@)", type.1)
			throw GRDError.unsupportedGradientType(type.1)
		}
	}

	/// <typenamelength uint32><typename><uint32>
	func parseTypedLong(_ reader: BytesReader, expectedTag: String) throws -> UInt32 {
		let type1 = try parseGrd5Typename(reader)
		guard type1 == expectedTag else {
			ColorPaletteLogger.log(.error, "GRDCoder: Expected %@ when trying to read long value", expectedTag)
			throw GRDError.invalidFormat
		}
		return try parseLong(reader)
	}

	func parseNoiseGradient(_ reader: BytesReader) throws {

		// Currently, we read the noise gradient data but ignore it, so we can continue to the next gradient

		let /*shtr*/ _ = try parseBool(reader, expectedType: "ShTr")
		let /*vctc*/ _ = try parseBool(reader, expectedType: "VctC")

		let /*clrs*/ _ = try parseColorspace(reader)

		let /*rand*/ _ = try parseTypedLong(reader, expectedTag: "RndS")       // 0 ..< 4096
		let /*smoothness*/ _ = try parseTypedLong(reader, expectedTag: "Smth") // 0 ..< 4096

		// Mnm
		let minsCount = try parseVLLLength(reader, expected: "Mnm ")
		var mins = [UInt32]()
		for _ in 0 ..< minsCount {
			mins.append(try parseLong(reader))
		}

		// Mxm
		let maxsCount = try parseVLLLength(reader, expected: "Mxm ")
		var maxs = [UInt32]()
		for _ in 0 ..< maxsCount {
			maxs.append(try parseLong(reader))
		}
	}

	func parseColorspace(_ reader: BytesReader) throws -> String {
		let value = try parseEnum(reader, "ClrS")
		let colorspace = value.1
		return colorspace
	}

	func parseBool(_ reader: BytesReader, expectedType: String) throws -> Bool {
		let bom = try parseGrd5Typename(reader)
		guard bom == expectedType else {
			ColorPaletteLogger.log(.error, "GRDCoder: Cannot read %@", expectedType)
			throw GRDError.invalidFormat
		}
		let type = try parseType(reader)
		guard type == "bool" else {
			ColorPaletteLogger.log(.error, "GRDCoder: Cannot read bool")
			throw GRDError.invalidFormat
		}

		return try reader.readByte() != 0x00 //readData(inputStream, size: 1).first != 0x00
	}

	func parseNm(_ reader: BytesReader) throws -> String {
		let nm = try parseGrd5Typename(reader)
		guard nm == "Nm  " else {
			ColorPaletteLogger.log(.error, "GRDCoder: Expected name (Nm  )")
			throw GRDError.invalidFormat
		}

		let bom = try parseType(reader)
		guard bom == "TEXT" else {
			ColorPaletteLogger.log(.error, "GRDCoder: Expected text (TEXT)")
			throw GRDError.invalidFormat
		}

		return try parseGrd5UCS2(reader)
	}

	func parseText(_ reader: BytesReader) throws -> String {
		let type = try parseGrd5Typename(reader)
		guard type == "TEXT" else {
			ColorPaletteLogger.log(.error, "GRDCoder: Expected text (TEXT)")
			throw GRDError.invalidFormat
		}
		return try parseGrd5UCS2(reader)
	}

	func parseCustomGradient(_ reader: BytesReader, gradientName: String) throws -> Gradient {
		let smoothness = try parseIntr(reader)
		let numberOfStops = try parseVLLLength(reader, expected: "Clrs")

		var stops = [ColorStop]()
		try (0 ..< numberOfStops).forEach { _ in
			stops.append(try parseColorStop(reader))
		}

		let numberOfTransparencyStops = try parseVLLLength(reader, expected: "Trns")
		var tstops = [TransparencyStop]()
		try (0 ..< numberOfTransparencyStops).forEach { _ in
			tstops.append(try parseTransparencyStop(reader))
		}

		if tstops.count > 0 {
			// Map transparency into the color table
			
		}

		return Gradient(name: gradientName, smoothness: smoothness, colorStops: stops, transparencyStops: tstops)
	}

	// Color stop

	func parseColorStop(_ reader: BytesReader) throws -> ColorStop {
		// This should be an object
		let objc = try parseObjc(reader)

		let numberOfComponents = objc.2

		let color: Color
		if numberOfComponents == 4 {
			// is a user color
			color = try parseUserColor(reader)
		}
		else if numberOfComponents == 3 {
			// Is a book color (predefined).  Just put in black
			color = Color(colorspace: "rgb", components: [0, 0, 0])
		}
		else {
			fatalError()
		}

		let ct: ColorStop.ColorType
		let colorType = try parseClry(reader)
		switch colorType {
		case "FrgC": ct = .foreground
		case "BckC": ct = .background
		case "UsrS": ct = .userStop
		default:
			ColorPaletteLogger.log(.error, "GRDCoder: Unsupported color type (%@)", colorType)
			throw GRDError.invalidFormat
		}
		let location = try parseLctn(reader)
		let midpoint = try parseMdpn(reader)

		return ColorStop(
			colorType: ct,
			color: color,
			location: location,
			midpoint: midpoint
		)
	}

	// Transparency
	func parseTransparencyStop(_ reader: BytesReader) throws -> TransparencyStop {
		//
		let type = try parseObjc(reader)
		guard type.1 == "TrnS" else { throw GRDError.invalidString }
		guard type.2 == 3 else { throw GRDError.invalidString }

		let ttype = try parseGrd5Typename(reader)
		guard ttype == "Opct" else { throw GRDError.invalidString }
		let value = try parseUnitFloat(reader)

		let location = try parseLctn(reader)
		let midpoint = try parseMdpn(reader)
		return TransparencyStop(value: value / 100.0, location: location, midpoint: midpoint)
	}

	func parseUnitFloat(_ reader: BytesReader) throws -> Double {
		let valueType = try parseType(reader)
		guard valueType == "UntF" else  { throw GRDError.invalidString }
		let subtype = try parseType(reader)
		guard subtype == "#Prc" else  { throw GRDError.invalidString }
		let percent = Double(bitPattern: try reader.readUInt64(.big))
		return percent
	}


	// location
	func parseLctn(_ reader: BytesReader) throws -> UInt32 {
		let type = try parseGrd5Typename(reader)
		guard type == "Lctn" else { throw GRDError.invalidString }
		return try parseLong(reader)
	}

	// midpoint
	func parseMdpn(_ reader: BytesReader) throws -> UInt32 {
		let type = try parseGrd5Typename(reader)
		guard type == "Mdpn" else { throw GRDError.invalidString }
		return try parseLong(reader)
	}

	func parseLong(_ reader: BytesReader) throws -> UInt32 {
		let type = try parseType(reader)
		guard type == "long" else { throw GRDError.invalidString }
		return try reader.readUInt32(.big)
	}

	func parseUserColor(_ reader: BytesReader) throws -> Color {
		let type = try parseGrd5Typename(reader)
		guard type == "Clr " else { throw GRDError.invalidString }

		let objc = try parseObjc(reader)
		let colorType = objc.1
		let /*numberOfComponents*/ _ = objc.2

		let color: Color
		switch colorType {
		case "RGBC":
			color = try parseUserRGB(reader)
		case "HSBC":
			color = try parseUserHSB(reader)
		case "CMYC":
			color = try parseUserCMYK(reader)
		case "Grsc":
			color = try parseUserGray(reader)
		case "LbCl":
			color = try parseUserLAB(reader)
		case "BkCl":
			ColorPaletteLogger.log(.error, "GRDCoder: Book colors are not supported")
			throw GRDError.unsupportedFormat
		default:
			ColorPaletteLogger.log(.error, "GRDCoder: Unsupported color type %@", colorType)
			throw GRDError.unsupportedFormat
		}

		return color
	}

	func parseUserGray(_ reader: BytesReader) throws -> Color {
		let g = try parseDouble(reader, expected: "Gry ")
		return Color(colorspace: "gray", components: [g])
	}

	func parseUserLAB(_ reader: BytesReader) throws -> Color {
		let l = try parseDouble(reader, expected: "Lmnc")
		let a = try parseDouble(reader, expected: "A   ")
		let b = try parseDouble(reader, expected: "B   ")
		return Color(colorspace: "lab", components: [l, a, b])
	}

	func parseUserRGB(_ reader: BytesReader) throws -> Color {
		let r = try parseDouble(reader, expected: "Rd  ")
		let g = try parseDouble(reader, expected: "Grn ")
		let b = try parseDouble(reader, expected: "Bl  ")
		return Color(colorspace: "rgb", components: [r / 255.0, g / 255.0, b / 255.0])
	}

	func parseUserCMYK(_ reader: BytesReader) throws -> Color {
		let c = try parseDouble(reader, expected: "Cyn ")
		let m = try parseDouble(reader, expected: "Mgnt")
		let y = try parseDouble(reader, expected: "Ylw ")
		let k = try parseDouble(reader, expected: "Blck")
		return Color(colorspace: "cmyk", components: [c, m, y, k])
	}

	func parseUserHSB(_ reader: BytesReader) throws -> Color {
		let bom = try parseGrd5Typename(reader)
		guard bom == "H   " else { throw GRDError.invalidString }

		let type = try parseType(reader)
		guard type == "UntF" else  { throw GRDError.invalidString }
		let subtype = try parseType(reader)
		guard subtype == "#Ang" else  { throw GRDError.invalidString }
		let angle = Double(bitPattern: try reader.readUInt64(.big))

		let s = try parseDouble(reader, expected: "Strt")
		let b = try parseDouble(reader, expected: "Brgh")
		return Color(colorspace: "hsb", components: [angle, s, b])
	}

	func parseClry(_ reader: BytesReader) throws -> String {
		let names = try parseEnum(reader, "Type")
		guard names.0 == "Clry" else { throw GRDError.invalidString }
		return names.1
	}


	func parseIntr(_ reader: BytesReader) throws -> Double {
		try parseDouble(reader, expected: "Intr")
	}

	func parseDouble(_ reader: BytesReader, expected: String) throws -> Double {
		let type = try parseGrd5Typename(reader)
		guard type == expected else { throw GRDError.invalidString }
		let t = try reader.readStringASCII(length: 4)
		guard "doub" == t else {
			throw GRDError.invalidString
		}

		// Double is 8 bytes
		return Double(bitPattern: try reader.readUInt64(.big))
	}

	func parseEnum(_ reader: BytesReader, _ expected: String) throws -> (String, String) {
		let type = try parseGrd5Typename(reader)
		guard type == expected else { throw GRDError.invalidString }
		let subtype = try parseType(reader)
		guard subtype == "enum" else { throw GRDError.invalidString }
		let name = try parseGrd5Typename(reader)
		let subname = try parseGrd5Typename(reader)
		return (name, subname)
	}

	func parseTextHeader(_ reader: BytesReader) throws {
		let bom = try parseType(reader)
		guard bom == "TEXT" else { throw GRDError.invalidString }
	}


	func parseObjc(_ reader: BytesReader) throws -> (String, String, Int32) {
		let type = try parseType(reader)
		guard type == "Objc" else { throw GRDError.invalidString }
		let name = try parseGrd5UCS2(reader)
		let typeName = try parseGrd5Typename(reader)
		let value: Int32 = try reader.readInt32(.big)
		return (name, typeName, value)
	}

	// Returns the number of ...
	func parseGrdL(_ reader: BytesReader) throws -> Int32 {
		try parseVLLLength(reader, expected: "GrdL")
	}

	func parseVLLLength(_ reader: BytesReader, expected: String) throws -> Int32 {
		let namedType = try parseGrd5Typename(reader)
		guard namedType == expected else { throw GRDError.invalidString }

		let typeName = try reader.readStringASCII(length: 4)
		guard typeName == "VlLs" else { throw GRDError.invalidString }

		return try reader.readInt32(.big)
	}

	func parseType(_ reader: BytesReader) throws -> String {
		return try reader.readStringASCII(length: 4)
	}

	func parseGrd5Typename(_ reader: BytesReader) throws -> String {
		var length: UInt32 = try reader.readUInt32(.big)
		if length == 0 { length = 4 }
		let strData = try reader.readData(count: Int(length))
		guard let str = String(data: strData, encoding: .utf8) else {
			throw GRDError.invalidString
		}
		return str
	}

	func parseGrd5UCS2(_ reader: BytesReader) throws -> String {
		let length: UInt32 = try reader.readUInt32(.big) * 2
		let strData = try reader.readData(count: Int(length))
		guard let str = String(data: strData, encoding: .utf16BigEndian) else {
			throw GRDError.invalidString
		}
		if str.last == "\0" {
			return String(str.dropLast())
		}
		return str
	}
}

/////

extension GRD {
	func parseVersion3(_ reader: BytesReader) throws -> [Gradient] {
		let numGradients: UInt16 = try reader.readUInt16(.big)
		var result = [Gradient]()
		for _ in 0 ..< numGradients {
			result.append(try parseV3Gradient(reader))
		}
		return result
	}

	func parseV3Gradient(_ reader: BytesReader) throws -> Gradient {

		// Gradient name string of length (int8) characters ("Pascal string")
		let titleLength: Int8 = try reader.readInt8()
		let title = try reader.readStringASCII(length: Int(titleLength))

		let numberOfStops: Int16 = try reader.readInt16(.big)
		var stops: [ColorStop] = []
		for _ in 0 ..< numberOfStops {
			let location: UInt32 = try reader.readUInt32(.big)  // 0 ... 4096
			let midPoint: UInt32 = try reader.readUInt32(.big)  // percent
			let colorModel: Int16 = try reader.readInt16(.big)
			let colorspace: String = try {
				switch colorModel {
				case 0: return "rgb"
				case 1: return "hsb"
				case 2: return "cmyk"
				case 7: return "lab"
				case 8: return "gray"
				default:
					ColorPaletteLogger.log(.error, "GRDCoder: Unsupported v3 color model (%d)", colorModel)
					throw PAL.GradientError.unsupportedColorFormat
				}
			}()

			let c0: UInt16 = try reader.readUInt16(.big)
			let c1: UInt16 = try reader.readUInt16(.big)
			let c2: UInt16 = try reader.readUInt16(.big)
			let c3: UInt16 = try reader.readUInt16(.big)
			let color = Color(
				colorspace: colorspace,
				components: [
					Double(c0) / 65535.0,
					Double(c1) / 65535.0,
					Double(c2) / 65535.0,
					Double(c3) / 65535.0
				]
			)

			// 0 ⇒ User color, 1 ⇒ Foreground, 2 ⇒ Background)
			let colorType: Int16 = try reader.readInt16(.big)
			let ct: ColorStop.ColorType = try {
				switch colorType {
				case 0: return ColorStop.ColorType.userStop
				case 1: return ColorStop.ColorType.foreground
				case 2: return ColorStop.ColorType.background
				default:
					ColorPaletteLogger.log(.error, "GRDCoder: Unsupported v3 color type (%d)", colorType)
					throw GRDError.invalidFormat
				}
			}()

			let cs = ColorStop(colorType: ct, color: color, location: location, midpoint: midPoint)
			stops.append(cs)
		}

		let numberOfTransparencyStops: Int16 = try reader.readInt16(.big)
		var tstops = [TransparencyStop]()
		for _ in 0 ..< numberOfTransparencyStops {
			let stopOffset: UInt32 = try reader.readUInt32(.big)  // 0 ... 4096
			let midPoint: UInt32 = try reader.readUInt32(.big)    // percent
			let opacity: Int16 = try reader.readInt16(.big)       // 0 ... 255
			let stop = TransparencyStop(
				value: Double(opacity) / 255.0,
				location: UInt32(stopOffset),
				midpoint: UInt32(midPoint)
			)
			tstops.append(stop)
		}

		// Unused bytes?
		_ = try reader.readBytes(count: 6)

		return Gradient(name: title, smoothness: 0, colorStops: stops, transparencyStops: tstops)
	}
}

// MARK: - Gradient writing support



extension GRD {
	func writeV3(_ gradients: PAL.Gradients) throws -> Data {
		// Write a v3 gradient. Because it's easier
		let writer = try BytesWriter()

		// BOM
		try writer.writeStringASCII("8BGR")
		// Version
		try writer.writeUInt16(3, .big)

		// Number of gradients
		try writer.writeUInt16(UInt16(gradients.gradients.count), .big)

		try gradients.gradients.forEach { gradient in

			// Adobe gradients use transparency maps to represent transparency
			let gradient = try gradient.normalized().gradientTransparencyAsTransparencyMap()

			do { // Write the name
				let name: Data = {
					let text = gradient.name?.prefix(256)
					return text?.data(using: .ascii) ?? Data()
				}()

				try writer.writeUInt8(UInt8(name.count))
				try writer.writeData(name)
			}

			try writer.writeUInt16(UInt16(gradient.stops.count), .big)

			try gradient.stops.forEach { stop in
				// location
				try writer.writeUInt32(UInt32(stop.position * 4096), .big)
				// midpoint (percentage value)
				try writer.writeUInt32(50, .big)

				let c0: UInt16
				let c1: UInt16
				let c2: UInt16
				let c3: UInt16
				switch stop.color.colorSpace {
				case .CMYK:
					try writer.writeUInt16(2, .big)
					c0 = UInt16(stop.color.colorComponents[0] * 65535.0)
					c1 = UInt16(stop.color.colorComponents[1] * 65535.0)
					c2 = UInt16(stop.color.colorComponents[2] * 65535.0)
					c3 = UInt16(stop.color.colorComponents[3] * 65535.0)
				case .RGB:
					try writer.writeUInt16(0, .big)
					c0 = UInt16(stop.color.colorComponents[0] * 65535.0)
					c1 = UInt16(stop.color.colorComponents[1] * 65535.0)
					c2 = UInt16(stop.color.colorComponents[2] * 65535.0)
					c3 = UInt16(0)
				case .LAB:
					try writer.writeUInt16(7, .big)
					c0 = UInt16(stop.color.colorComponents[0] * 65535.0)
					c1 = UInt16(stop.color.colorComponents[1] * 65535.0)
					c2 = UInt16(stop.color.colorComponents[2] * 65535.0)
					c3 = UInt16(0)
				case .Gray:
					try writer.writeUInt16(8, .big)
					c0 = UInt16(stop.color.colorComponents[0] * 65535.0)
					c1 = UInt16(0)
					c2 = UInt16(0)
					c3 = UInt16(0)
				}

				try writer.writeUInt16(c0, .big)
				try writer.writeUInt16(c1, .big)
				try writer.writeUInt16(c2, .big)
				try writer.writeUInt16(c3, .big)

				// stop type (we're always a user stop)
				try writer.writeUInt16(0, .big)
			}

			// transparency stops
			let tstopCount = gradient.transparencyStops?.count ?? 0
			try writer.writeUInt16(UInt16(tstopCount), .big)
			try gradient.transparencyStops?.forEach { tstop in
				// Stop offset
				try writer.writeUInt32(UInt32(tstop.position * 4096.0), .big)
				// Midpoint (%)
				try writer.writeUInt32(50, .big)
				// Opacity (0 ... 255)
				try writer.writeUInt16(UInt16(tstop.value * 255.0), .big)
			}

			// 6 empty bytes
			try writer.writeBytes([0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
		}
		writer.complete()
		return try writer.data()
	}
}


// MARK: - UTType

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let grd = UTType(PAL.Gradients.Coder.AdobeGradientsCoder.utTypeString)!
}
#endif
