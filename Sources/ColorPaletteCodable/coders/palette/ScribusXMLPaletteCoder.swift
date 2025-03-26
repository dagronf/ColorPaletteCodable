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

#if canImport(FoundationXML)
// For non-apple platforms it seems that the XML parser has been shifted into its own module
import FoundationXML
#endif

public extension PAL.Coder {
	/// XML palette file for CorelDraw/Adobe Illustrator(?)
	///
	/// https://community.coreldraw.com/sdk/w/articles/177/creating-color-palettes
	class ScribusXMLPaletteCoder: NSObject, PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .scribusXML
		public let name = "Scribus XML Palette"
		public let fileExtension = ["xml"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.scribus.xml"   // conforms to `public.xml`

		public override init() {
			super.init()
		}

		var palette = PAL.Palette()
		var group = PAL.Group()
		var isInColorsSection = false

		var isInColorspaceSection = false
		private var colorspaces: [Colorspace] = []
	}
}

extension PAL.Coder.ScribusXMLPaletteCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {

		self.palette = PAL.Palette(format: self.format)

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

extension PAL.Coder.ScribusXMLPaletteCoder: XMLParserDelegate {

	private class Colorspace {
		init(name: String) { self.name = name }
		let name: String
		var colors: [PAL.Color] = []
	}

	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		let en = elementName.lowercased()

		var lowercasedAtts: [String: String] = [:]
		attributeDict.forEach { lowercasedAtts[$0.key.lowercased()] = $0.value }

		if en == "scribuscolors" {
			self.palette.name = lowercasedAtts["Name"]?.xmlDecoded() ?? ""
		}
		else if en == "color" {
			let name = lowercasedAtts["name"]?.xmlDecoded() ?? ""
			if let rgbHexFormat = lowercasedAtts["rgb"] {
				if let color = try? PAL.Color(hexString: rgbHexFormat, format: .rgb, name: name) {
					self.palette.colors.append(color)
				}
			}
			else if let cmykHexFormat = lowercasedAtts["cmyk"] {
				if let color = try? PAL.Color(hexString: cmykHexFormat, format: .rgb, name: name) {
					self.palette.colors.append(color)
				}
			}
			else {
				ColorPaletteLogger.log(.error, "ScribusXMLPaletteCoder: Unsupported color type, ignoring")
			}
		}
	}
}

extension PAL.Coder.ScribusXMLPaletteCoder {
	public func encode(_ palette: PAL.Palette) throws -> Data {

		var xml = "<?xml version=\"1.0\"?>\n"
		xml += "<SCRIBUSCOLORS"
		if palette.name.count > 0 {
			xml += " Name=\"\(palette.name.xmlEscaped())\""
		}
		xml += " >"

		let colors = palette.allColors()
		try colors.forEach { color in
			if color.colorSpace == .CMYK {
				let c = try color.cmyk()
				xml += "<COLOR CMYK=\"" + c.hexString(hashmark: true, uppercase: false) + "\""
			}
			else {
				// 	<COLOR RGB="#19aeff" NAME="Blue1" />
				let rgb = try color.rgb()
				xml += "<COLOR RGB=\"" + rgb.hexString(format: .rgb, hashmark: true, uppercase: false) + "\""
			}

			if color.name.isEmpty == false {
				xml += " NAME=\"\(color.name.xmlEscaped())\""
			}

			xml += " />"
		}

		xml += "</SCRIBUSCOLORS>"

		guard let data = xml.data(using: .utf8) else {
			throw PAL.CommonError.unsupportedPaletteType
		}
		return data
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let scribusPaletteXML = UTType(PAL.Coder.ScribusXMLPaletteCoder.utTypeString)!
}
#endif
