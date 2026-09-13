//
//  Copyright © 2026 Darren Ford. All rights reserved.
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

// https://docs.krita.org/en/untranslatable_pages/kpl_defintion.html#the-krita-palette-format-kpl

#if canImport(Darwin)
import ZIPFoundation
#endif

public extension PAL.Coder {
	/// A Krita palette encoder/decoder
	struct KritaPaletteCoder: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .krita
		public let name = "Krita Palette"

		public let fileExtension = ["kpl"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.krita"
	}
}

#if canImport(Darwin)

public extension PAL.Coder.KritaPaletteCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let data = inputStream.readAllData()

		let archive = try Archive(data: data, accessMode: .read)
		guard let entry = archive["colorset.xml"] else {
			throw PAL.CommonError.invalidFormat
		}

		var result: PAL.Palette?

		if entry.uncompressedSize > Int.max {
			throw PAL.CommonError.invalidFormat
		}

		let _ = try archive.extract(entry, bufferSize: Int(entry.uncompressedSize)) { data in
			let decoder = KritaXMLPaletteDecoder()
			result = try decoder.decode(from: InputStream(data: data))
		}

		guard let result, result.totalColorCount > 0 else {
			throw PAL.CommonError.invalidFormat
		}

		return result
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		throw PAL.CommonError.notImplemented
	}
}

#else
public extension PAL.Coder.KritaPaletteCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		throw PAL.CommonError.notImplemented
	}
	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		throw PAL.CommonError.notImplemented
	}
}
#endif

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let kritaPalette = UTType(PAL.Coder.KritaPaletteCoder.utTypeString)!
}
#endif


// MARK: - Internal

fileprivate class KritaXMLPaletteDecoder: NSObject, XMLParserDelegate {
	var palette = PAL.Palette()
	var isInColorSet = false
	var isInColorSetEntry = false

	var colorName: String = ""
	var colorIsSpot: Bool = false

	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		self.palette = PAL.Palette(format: .krita)

		let parser = XMLParser(stream: inputStream)
		parser.delegate = self

		if parser.parse() == false {
			throw PAL.CommonError.invalidFormat
		}

		if palette.totalColorCount == 0 {
			throw PAL.CommonError.invalidFormat
		}
		return self.palette
	}

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		let en = elementName.lowercased()

		var lowercasedAtts: [String: String] = [:]
		attributeDict.forEach { lowercasedAtts[$0.key.lowercased()] = $0.value }

		if en == "colorset" {
			self.palette.name = lowercasedAtts["name"]?.xmlDecoded() ?? ""
			self.isInColorSet = true
		}
		else if en == "colorsetentry" {
			guard self.isInColorSet == true else {
				ColorPaletteLogger.log(.error, "KPL parsing: invalid xml format")
				parser.abortParsing()
				return
			}
			self.isInColorSet = true

			let colorName = attributeDict["name"]?.xmlDecoded() ?? ""
			let groupName = attributeDict["id"]?.xmlDecoded() ?? ""

			self.colorName = colorName
			if groupName.isNotEmpty {
				self.colorName += "-\(groupName)"
			}

			self.colorIsSpot = attributeDict["spot"] == "false" ? false : true
		}
		else if en == "rgb" || en == "srgb" {
			//   <RGB r="0.61176472902298" g="0.811764717102051" b="0.847058832645416" space="sRGB-elle-V2-srgbtrc.icc"/>
			if
				let rs = attributeDict["r"],
				let r = Double(rs),
				let gs = attributeDict["g"],
				let g = Double(gs),
				let bs = attributeDict["b"],
				let b = Double(bs)
			{
				let color = rgbf(r.unitClamped, g.unitClamped, b.unitClamped, name: self.colorName)
				self.palette.colors.append(color)
			}
			else {
				ColorPaletteLogger.log(.error, "KPL parsing: invalid rgb attributes for '%@', ignoring...", self.colorName)
			}
		}
		else if en == "cmyk" {
			// <CMYK space="2ndFloorCMYK" c="0.8703" m="0.6172" y="0" k="0"/>
			if
				let cs = attributeDict["c"],
				let c = Double(cs),
				let ms = attributeDict["m"],
				let m = Double(ms),
				let ys = attributeDict["y"],
				let y = Double(ys),
				let ks = attributeDict["k"],
				let k = Double(ks)
			{
				let color = cmykf(c, m, y, k, name: self.colorName)
				self.palette.colors.append(color)
			}
			else {
				ColorPaletteLogger.log(.error, "KPL parsing: invalid cmyk attributes for '%@', ignoring...", self.colorName)
			}
		}
		else if en == "gray" {
			// <Gray space="prof06" g="0.2515"/>
			if
				let gs = attributeDict["g"],
				let g = Double(gs)
			{
				let color = grayf(g.unitClamped, name: self.colorName)
				self.palette.colors.append(color)
			}
			else {
				ColorPaletteLogger.log(.error, "KPL parsing: invalid gray attributes for '%@', ignoring...", self.colorName)
			}
		}
	}

	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		let en = elementName.lowercased()
		if en == "colorset" {
			self.isInColorSet = false
		}
		else if en == "colorsetentry" {
			self.isInColorSetEntry = false
			self.colorName = ""
			self.colorIsSpot = false
		}
	}

	func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
		ColorPaletteLogger.log(.error, "KPL parsing: invalid xml found in colorset.xml")
		ColorPaletteLogger.log(.error, "KPL parsing: error was %@", "\(parseError)")
	}
}

