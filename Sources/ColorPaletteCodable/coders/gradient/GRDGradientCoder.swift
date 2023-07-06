//
//  File.swift
//  
//
//  Created by Darren Ford on 6/7/2023.
//

import Foundation

public extension PAL.Gradient.Coder {
	/// A coder for GRD palette(s)
	///
	/// References :-
	/// [1](http://www.selapa.net/swatches/gradients/fileformats.php)
	/// [2](https://github.com/Balakov/GrdToAfpalette/blob/master/palette-js/load_grd.js)
	struct GRD: PAL_GradientCoder {
		/// The coder's file format
		public static let fileExtension = "grd"
		public init() {}
	}
}

public extension PAL.Gradient.Coder.GRD {
	func encode(_ gradients: PAL.Gradients) throws -> Data {
		throw PAL.CommonError.notImplemented
	}
}

public extension PAL.Gradient.Coder.GRD {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		let gradients = try GRD().readGradients(inputStream: inputStream)

		if gradients.count == 0 {
			return PAL.Gradients()
		}

		var result = PAL.Gradients()

		try gradients.forEach { gradient in
			var gr = PAL.Gradient(colors: [])
			let cs = try gradient.colorStops.map {
				let co = $0.color
				let color: PAL.Color
				if co.colorspace == "rgb" {
					guard co.components.count == 3 else {
						ASEPaletteLogger.log(.error, "GRD: rgb component count mismatch")
						throw PAL.GradientError.unsupportedColorFormat
					}
					color = try PAL.Color(
						rf: Float32(co.components[0] / 255.0),
						gf: Float32(co.components[1] / 255.0),
						bf: Float32(co.components[2] / 255.0)
					)
				}
				else if co.colorspace == "hsb" {
					guard co.components.count == 3 else {
						ASEPaletteLogger.log(.error, "GRD: hsb component count mismatch")
						throw PAL.GradientError.unsupportedColorFormat
					}
					color = try PAL.Color(
						h: Float32(co.components[0] / 360.0),
						s: Float32(co.components[1] / 100.0),
						b: Float32(co.components[2] / 100.0),
						a: 1
					)
				}
				else if co.colorspace == "cmyk" {
					guard co.components.count == 4 else {
						ASEPaletteLogger.log(.error, "GRD: cmyk component count mismatch")
						throw PAL.GradientError.unsupportedColorFormat
					}
					color = try PAL.Color(
						name: "",
						colorSpace: .CMYK,
						colorComponents: co.components.map { Float32($0 / 100.0) },
						alpha: 1
					)
				}
				else if co.colorspace == "gray" {
					guard co.components.count == 1 else {
						ASEPaletteLogger.log(.error, "GRD: gray component count mismatch")
						throw PAL.GradientError.unsupportedColorFormat
					}
					color = try PAL.Color(
						name: "",
						colorSpace: .Gray,
						colorComponents: co.components.map { Float32($0 / 100.0) },
						alpha: 1
					)
				}
				else if co.colorspace == "lab" {
					guard co.components.count == 3 else {
						ASEPaletteLogger.log(.error, "GRD: lab component count mismatch")
						throw PAL.GradientError.unsupportedColorFormat
					}
					color = try PAL.Color(
						name: "",
						colorSpace: .LAB,
						colorComponents: co.components.map { Float32($0) },
						alpha: 1
					)
				}
				else {
					// unknown?
					ASEPaletteLogger.log(.error, "GRD: unknown color format '%@'", co.colorspace)
					throw PAL.GradientError.unsupportedColorFormat
				}

				return PAL.Gradient.Stop(position: Double($0.location) / 4096.0, color: color)
			}
			gr.stops = cs
			result.gradients.append(gr)
		}
		return result
	}
}


///////////

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
		let value: Double
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
		let bom = try readAsciiString(inputStream, length: 4)
		if bom != "8BGR" {
			throw GRDError.invalidFormat
		}
		let version: UInt16 = try readIntegerBigEndian(inputStream)
		if version != 5 {
			throw GRDError.unsupportedFormat
		}

		// Step over the next 22 bytes (unknown)
		_ = try readData(inputStream, size: 22)

		let gradientCount = try parseGrdL(inputStream)
		var gradients = [Gradient]()
		for _ in 0 ..< gradientCount {
			if let gradient = try parseGradientDefinition(inputStream) {
				gradients.append(gradient)
			}
		}
		return gradients
	}

	func parseGradientDefinition(_ inputStream: InputStream) throws -> Gradient? {
		let objcValue = try parseObjc(inputStream)
		guard "Gradient" == objcValue.0 else {
			throw GRDError.unsupportedFormat
		}

		let bom = try parseGrd5Typename(inputStream)
		guard bom == "Grad" else { throw GRDError.invalidString }

		let innerObjcValue = try parseObjc(inputStream)

		// name
		let parseNm = try parseNm(inputStream)

		let type = try parseEnum(inputStream, "GrdF")

		if type.1 == "CstS" {
			if innerObjcValue.2 != 5 {
				// There should be five components
				ASEPaletteLogger.log(.error, "GRDCoder: Expected five components, got %@", innerObjcValue.2)
				throw GRDError.unsupportedFormat
			}
			return try parseCustomGradient(inputStream, gradientName: parseNm)
		}
		else if type.1 == "ClNs" {
			if innerObjcValue.2 != 9 {
				// Nine components for noise?
				ASEPaletteLogger.log(.error, "GRDCoder: Cannot parse noise gradient, aborting")
				throw GRDError.unsupportedFormat
			}

			// Read the noise gradient components, but just ignore it
			ASEPaletteLogger.log(.info, "GRDCoder: Found noise gradient -- ignoring...")

			try parseNoiseGradient(inputStream)
			return nil
		}
		else {
			ASEPaletteLogger.log(.error, "GRDCoder: Unsupported gradient type (%@)", type.1)
			throw GRDError.unsupportedGradientType(type.1)
		}
	}

	func parseNoiseGradient(_ inputStream: InputStream) throws {

		let shtr = try parseBool(inputStream, expectedType: "ShTr")
		let vctc = try parseBool(inputStream, expectedType: "VctC")

		let clrs = try parseColorspace(inputStream)

		let type1 = try parseGrd5Typename(inputStream)
		guard type1 == "RndS" else {
			ASEPaletteLogger.log(.error, "GRDCoder: Missing RndS")
			throw GRDError.invalidFormat
		}
		let rand = try parseLong(inputStream)

		let type2 = try parseGrd5Typename(inputStream)
		guard type2 == "Smth" else {
			ASEPaletteLogger.log(.error, "GRDCoder: Missing Smth")
			throw GRDError.invalidFormat
		}
		let roughness = try parseLong(inputStream)  // 0 ..< 4096

		do {
			// Mnm
			let mnmType = try parseGrd5Typename(inputStream)
			guard mnmType == "Mnm " else {
				ASEPaletteLogger.log(.error, "GRDCoder: Missing Mnm")
				throw GRDError.invalidFormat
			}

			let vllType = try parseType(inputStream)
			guard vllType == "VlLs" else {
				ASEPaletteLogger.log(.error, "GRDCoder: Missing Mnm VlLs")
				throw GRDError.invalidFormat
			}

			let minsCount: UInt32 = try readIntegerBigEndian(inputStream)
			var mins = [UInt32]()
			for _ in 0 ..< minsCount {
				mins.append(try parseLong(inputStream))
			}
		}

		do {
			// Mxm
			let mxmType = try parseGrd5Typename(inputStream)
			guard mxmType == "Mxm " else {
				ASEPaletteLogger.log(.error, "GRDCoder: Missing Mxm")
				throw GRDError.invalidFormat
			}

			let vllType = try parseType(inputStream)
			guard vllType == "VlLs" else {
				ASEPaletteLogger.log(.error, "GRDCoder: Missing Mxm VlLs")
				throw GRDError.invalidFormat
			}

			let maxsCount: UInt32 = try readIntegerBigEndian(inputStream)
			var maxs = [UInt32]()
			for _ in 0 ..< maxsCount {
				maxs.append(try parseLong(inputStream))
			}
		}
	}

	func parseColorspace(_ inputStream: InputStream) throws -> String {
		let value = try parseEnum(inputStream, "ClrS")
		let colorspace = value.1
		return colorspace
	}

	func parseBool(_ inputStream: InputStream, expectedType: String) throws -> Bool {
		let bom = try parseGrd5Typename(inputStream)
		guard bom == expectedType else {
			ASEPaletteLogger.log(.error, "GRDCoder: Cannot read %@", expectedType)
			throw GRDError.invalidFormat
		}
		let type = try parseType(inputStream)
		guard type == "bool" else {
			ASEPaletteLogger.log(.error, "GRDCoder: Cannot read bool")
			throw GRDError.invalidFormat
		}

		return try readData(inputStream, size: 1).first != 0x00
	}

	func parseNm(_ inputStream: InputStream) throws -> String {
		let nm = try parseGrd5Typename(inputStream)
		guard nm == "Nm  " else {
			ASEPaletteLogger.log(.error, "GRDCoder: Expected name (Nm  )")
			throw GRDError.invalidFormat
		}

		let bom = try parseType(inputStream)
		guard bom == "TEXT" else {
			ASEPaletteLogger.log(.error, "GRDCoder: Expected text (TEXT)")
			throw GRDError.invalidFormat
		}

		return try parseGrd5UCS2(inputStream)
	}

	func parseText(_ inputStream: InputStream) throws -> String {
		let type = try parseGrd5Typename(inputStream)
		guard type == "TEXT" else {
			ASEPaletteLogger.log(.error, "GRDCoder: Expected text (TEXT)")
			throw GRDError.invalidFormat
		}
		return try parseGrd5UCS2(inputStream)
	}

	func parseCustomGradient(_ inputStream: InputStream, gradientName: String) throws -> Gradient {
		let smoothness = try parseIntr(inputStream)
		let numberOfStops = try parseVLLLength(inputStream, expected: "Clrs")

		var stops = [ColorStop]()
		try (0 ..< numberOfStops).forEach { _ in
			stops.append(try parseColorStop(inputStream))
		}

		let numberOfTransparencyStops = try parseVLLLength(inputStream, expected: "Trns")
		var tstops = [TransparencyStop]()
		try (0 ..< numberOfTransparencyStops).forEach { _ in
			tstops.append(try parseTransparencyStop(inputStream))
		}

		return Gradient(name: gradientName, smoothness: smoothness, colorStops: stops, transparencyStops: tstops)
	}

	// Color stop

	func parseColorStop(_ inputStream: InputStream) throws -> ColorStop {
		// This should be an object
		let objc = try parseObjc(inputStream)

		let numberOfComponents = objc.2

		let color: Color
		if numberOfComponents == 4 {
			// is a user color
			color = try parseUserColor(inputStream)
		}
		else if numberOfComponents == 3 {
			// Is a book color (predefined).  Just put in black
			color = Color(colorspace: "rgb", components: [0, 0, 0])
		}
		else {
			fatalError()
		}

		let ct: ColorStop.ColorType
		let colorType = try parseClry(inputStream)
		switch colorType {
		case "FrgC": ct = .foreground
		case "BckC": ct = .background
		case "UsrS": ct = .userStop
		default:
			ASEPaletteLogger.log(.error, "GRDCoder: Unsupported color type (%@)", colorType)
			throw GRDError.invalidFormat
		}
		let location = try parseLctn(inputStream)
		let midpoint = try parseMdpn(inputStream)

		return ColorStop(
			colorType: ct,
			color: color,
			location: location,
			midpoint: midpoint
		)
	}

	// Transparency
	func parseTransparencyStop(_ inputStream: InputStream) throws -> TransparencyStop {
		//
		let type = try parseObjc(inputStream)
		guard type.1 == "TrnS" else { throw GRDError.invalidString }
		guard type.2 == 3 else { throw GRDError.invalidString }

		let ttype = try parseGrd5Typename(inputStream)
		guard ttype == "Opct" else { throw GRDError.invalidString }
		let value = try parseUnitFloat(inputStream)

		let location = try parseLctn(inputStream)
		let midpoint = try parseMdpn(inputStream)
		return TransparencyStop(value: value, location: location, midpoint: midpoint)
	}

	func parseUnitFloat(_ inputStream: InputStream) throws -> Double {
		let valueType = try parseType(inputStream)
		guard valueType == "UntF" else  { throw GRDError.invalidString }
		let subtype = try parseType(inputStream)
		guard subtype == "#Prc" else  { throw GRDError.invalidString }
		let percent = Double(bitPattern: try readIntegerBigEndian(inputStream))
		return percent
	}


	// location
	func parseLctn(_ inputStream: InputStream) throws -> UInt32 {
		let type = try parseGrd5Typename(inputStream)
		guard type == "Lctn" else { throw GRDError.invalidString }
		return try parseLong(inputStream)
	}

	// midpoint
	func parseMdpn(_ inputStream: InputStream) throws -> UInt32 {
		let type = try parseGrd5Typename(inputStream)
		guard type == "Mdpn" else { throw GRDError.invalidString }
		return try parseLong(inputStream)
	}

	func parseLong(_ inputStream: InputStream) throws -> UInt32 {
		let type = try parseType(inputStream)
		guard type == "long" else { throw GRDError.invalidString }
		return try readIntegerBigEndian(inputStream)
	}

	func parseUserColor(_ inputStream: InputStream) throws -> Color {
		let type = try parseGrd5Typename(inputStream)
		guard type == "Clr " else { throw GRDError.invalidString }

		let objc = try parseObjc(inputStream)
		let colorType = objc.1
		let numberOfComponents = objc.2

		let color: Color
		switch colorType {
		case "RGBC":
			color = try parseUserRGB(inputStream)
		case "HSBC":
			color = try parseUserHSB(inputStream)
		case "CMYC":
			color = try parseUserCMYK(inputStream)
		case "Grsc":
			color = try parseUserGray(inputStream)
		case "LbCl":
			color = try parseUserLAB(inputStream)
		case "BkCl":
			ASEPaletteLogger.log(.error, "GRDCoder: Book colors are not supported")
			throw GRDError.unsupportedFormat
		default:
			ASEPaletteLogger.log(.error, "GRDCoder: Unsupported color type %@", colorType)
			throw GRDError.unsupportedFormat
		}

		return color
	}
	func parseUserGray(_ inputStream: InputStream) throws -> Color {
		let g = try parseDouble(inputStream, expected: "Gry ")
		return Color(colorspace: "gray", components: [g])
	}

	func parseUserLAB(_ inputStream: InputStream) throws -> Color {
		let l = try parseDouble(inputStream, expected: "Lmnc")
		let a = try parseDouble(inputStream, expected: "A   ")
		let b = try parseDouble(inputStream, expected: "B   ")
		return Color(colorspace: "lab", components: [l, a, b])
	}

	func parseUserRGB(_ inputStream: InputStream) throws -> Color {
		let r = try parseDouble(inputStream, expected: "Rd  ")
		let g = try parseDouble(inputStream, expected: "Grn ")
		let b = try parseDouble(inputStream, expected: "Bl  ")
		return Color(colorspace: "rgb", components: [r, g, b])
	}

	func parseUserCMYK(_ inputStream: InputStream) throws -> Color {
		let c = try parseDouble(inputStream, expected: "Cyn ")
		let m = try parseDouble(inputStream, expected: "Mgnt")
		let y = try parseDouble(inputStream, expected: "Ylw ")
		let k = try parseDouble(inputStream, expected: "Blck")
		return Color(colorspace: "cmyk", components: [c, m, y, k])
	}

	func parseUserHSB(_ inputStream: InputStream) throws -> Color {
		let bom = try parseGrd5Typename(inputStream)
		guard bom == "H   " else { throw GRDError.invalidString }

		let type = try parseType(inputStream)
		guard type == "UntF" else  { throw GRDError.invalidString }
		let subtype = try parseType(inputStream)
		guard subtype == "#Ang" else  { throw GRDError.invalidString }
		let angle = Double(bitPattern: try readIntegerBigEndian(inputStream))

		let s = try parseDouble(inputStream, expected: "Strt")
		let b = try parseDouble(inputStream, expected: "Brgh")
		return Color(colorspace: "hsb", components: [angle, s, b])
	}

	func parseClry(_ inputStream: InputStream) throws -> String {
		let names = try parseEnum(inputStream, "Type")
		guard names.0 == "Clry" else { throw GRDError.invalidString }
		return names.1
	}


	func parseIntr(_ inputStream: InputStream) throws -> Double {
		try parseDouble(inputStream, expected: "Intr")
	}

	func parseDouble(_ inputStream: InputStream, expected: String) throws -> Double {
		let type = try parseGrd5Typename(inputStream)
		guard type == expected else { throw GRDError.invalidString }
		let t = try readAsciiString(inputStream, length: 4)
		guard "doub" == t else {
			throw GRDError.invalidString
		}

		// Double is 8 bytes
		return Double(bitPattern: try readIntegerBigEndian(inputStream))
	}

	func parseEnum(_ inputStream: InputStream, _ expected: String) throws -> (String, String) {
		let type = try parseGrd5Typename(inputStream)
		guard type == expected else { throw GRDError.invalidString }
		let subtype = try parseType(inputStream)
		guard subtype == "enum" else { throw GRDError.invalidString }
		let name = try parseGrd5Typename(inputStream)
		let subname = try parseGrd5Typename(inputStream)
		return (name, subname)
	}

	func parseTextHeader(_ inputStream: InputStream) throws {
		let bom = try parseType(inputStream)
		guard bom == "TEXT" else { throw GRDError.invalidString }
	}


	func parseObjc(_ inputStream: InputStream) throws -> (String, String, Int32) {
		let type = try parseType(inputStream)
		guard type == "Objc" else { throw GRDError.invalidString }
		let name = try parseGrd5UCS2(inputStream)
		let typeName = try parseGrd5Typename(inputStream)
		let value: Int32 = try readIntegerBigEndian(inputStream)
		return (name, typeName, value)
	}

	// Returns the number of ...
	func parseGrdL(_ inputStream: InputStream) throws -> Int32 {
		try parseVLLLength(inputStream, expected: "GrdL")
	}

	func parseVLLLength(_ inputStream: InputStream, expected: String) throws -> Int32 {
		let namedType = try parseGrd5Typename(inputStream)
		guard namedType == expected else { throw GRDError.invalidString }

		let typeName = try readAsciiString(inputStream, length: 4)
		guard typeName == "VlLs" else { throw GRDError.invalidString }

		return try readIntegerBigEndian(inputStream)
	}

	func parseType(_ inputStream: InputStream) throws -> String {
		return try readAsciiString(inputStream, length: 4)
	}

	func parseGrd5Typename(_ inputStream: InputStream) throws -> String {
		var length: UInt32 = try readIntegerBigEndian(inputStream)
		if length == 0 { length = 4 }
		let strData = try readData(inputStream, size: Int(length))
		guard let str = String(data: strData, encoding: .utf8) else {
			throw GRDError.invalidString
		}
		return str
	}

	func parseGrd5UCS2(_ inputStream: InputStream) throws -> String {
		let length: UInt32 = try readIntegerBigEndian(inputStream) * 2
		let strData = try readData(inputStream, size: Int(length))
		guard let str = String(data: strData, encoding: .utf16BigEndian) else {
			throw GRDError.invalidString
		}
		if str.last == "\0" {
			return String(str.dropLast())
		}
		return str
	}
}
