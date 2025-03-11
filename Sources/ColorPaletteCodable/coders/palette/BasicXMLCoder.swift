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

//  A parser for basic XML definitions of a palette
//  See: https://coolors.co

/*
 <palette>
	<color name="Ultra Violet" hex="6c698d" r="108" g="105" b="141" />
	<color name="Timberwolf" hex="d4d2d5" r="212" g="210" b="213" />
	<color name="Silver" hex="bfafa6" r="191" g="175" b="166" />
	<color name="Beaver" hex="aa968a" r="170" g="150" b="138" />
	<color name="Dim gray" hex="6e6a6f" r="110" g="106" b="111" />
 </palette>
 */

import Foundation

#if canImport(FoundationXML)
// For non-apple platforms it seems that the XML parser has been shifted into its own module
import FoundationXML
#endif

public extension PAL.Coder {
	class BasicXML: NSObject, PAL_PaletteCoder {
		public let name = "Basic XML Palette"
		public let fileExtension = ["xml"]
		public override init() {
			super.init()
		}

		var palette = PAL.Palette()
	}
}

extension PAL.Coder.BasicXML {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {
		self.palette = PAL.Palette()

		let parser = XMLParser(stream: inputStream)
		parser.delegate = self

		if parser.parse() == false {
			throw PAL.CommonError.invalidFormat
		}

		if palette.colors.count == 0 {
			throw PAL.CommonError.invalidFormat
		}

		return palette
	}
}

extension PAL.Coder.BasicXML: XMLParserDelegate {

	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if elementName == "palette" {
			self.palette.name = attributeDict["name"]?.xmlDecoded() ?? ""
		}
		else if elementName == "color" {
			let name = attributeDict["name"]?.xmlDecoded() ?? ""
			if let rgbHexString = attributeDict["hex"],
				let color = try? PAL.Color.RGB(rgbHexString, format: .rgba)
			{
				let c = PAL.Color(color: color, name: name)
				self.palette.colors.append(c)
			}
			else if
				let rs = attributeDict["r"], let r = UInt8(rs),
				let gs = attributeDict["g"], let g = UInt8(gs),
				let bs = attributeDict["b"], let b = UInt8(bs)
			{
				let a: UInt8 = {
					if let aas = attributeDict["a"],
						let a = UInt8(aas)
					{
						return a
					}
					return 255
				}()

				let cc = PAL.Color(r255: r, g255: g, b255: b, a255: a, name: name)
				self.palette.colors.append(cc)
			}
		}
	}
}

extension PAL.Coder.BasicXML {
	public func encode(_ palette: PAL.Palette) throws -> Data {

		var xml = "<?xml version=\"1.0\"?>\n"
		xml += "<palette"
		if palette.name.count > 0 {
			xml += " name=\"\(palette.name.xmlEscaped())\""
		}
		xml += ">\n"

		try palette.allColors().forEach { c in
			xml += "<color"
			if c.name.count > 0 {
				xml += " name=\"\(c.name.xmlEscaped())\""
			}

			let rgb = try c.rgb()
			let hex = rgb.hexString(format: .rgba, hashmark: false, uppercase: false)

			xml += " hex=\"\(hex)\""
			xml += " r=\"\(rgb.r255)\" g=\"\(rgb.g255)\" b=\"\(rgb.b255)\" a=\"\(rgb.a255)\""
			xml += " />\n"
		}

		xml += "</palette>\n"

		guard let data = xml.data(using: .utf8) else {
			throw PAL.CommonError.unsupportedPaletteType
		}
		return data
	}

}
