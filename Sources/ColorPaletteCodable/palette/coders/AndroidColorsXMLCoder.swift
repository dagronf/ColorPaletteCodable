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

//  A parser for the Android colors.xml file format

//  https://developer.android.com/guide/topics/resources/more-resources#Color

/*
 <?xml version="1.0" encoding="utf-8"?>
 <resources>
  <color name="white">#FFFFFF</color>
  <color name="yellow">#FFFF00</color>
  <color name="fuchsia">#FF00FF</color>
  <color name="red">#FF0000</color>
  <color name="silver">#C0C0C0</color>
  <color name="gray">#808080</color>
  <color name="olive">#808000</color>
  <color name="purple">#800080</color>
  <color name="maroon">#800000</color>
  <color name="aqua">#00FFFF</color>
  <color name="lime">#00FF00</color>
  <color name="teal">#008080</color>
  <color name="green">#008000</color>
  <color name="blue">#0000FF</color>
  <color name="navy">#000080</color>
  <color name="black">#000000</color>
 </resources>
 */

import Foundation

#if canImport(FoundationXML)
// For non-apple platforms it seems that the XML parser has been shifted into its own module
import FoundationXML
#endif

public extension PAL.Coder {
	struct AndroidColorsXML: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .androidXML
		public let name = "Android Colors XML"
		public let fileExtension = ["xml"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.android.xml"   // conforms to `public.xml`

		/// Create an Android `colors.xml` coder
		/// - Parameters:
		///   - includeAlphaDuringExport: If true, includes alpha values during export
		public init(includeAlphaDuringExport: Bool = true) {
			self.includeAlphaDuringExport = includeAlphaDuringExport
		}

		/// Export alpha when exporting?
		public var includeAlphaDuringExport: Bool
	}
}

extension PAL.Coder.AndroidColorsXML {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {
		try AndroidColorsXMLDecoder().parse(from: inputStream)
	}
}

extension PAL.Coder.AndroidColorsXML {
	/// Encode an Android `colors.xml` style palette file
	/// - Parameter palette: The palette to encode
	/// - Returns: Raw xml data
	///
	/// Note that an Android colors.xml file does not specify a palette name, thus it is dropped during export
	public func encode(_ palette: PAL.Palette) throws -> Data {
		var xml = #"<?xml version="1.0" encoding="utf-8"?>"#
		xml += "\n<resources>\n"
		try palette.allColors().enumerated().forEach { c in
			let offset = c.0
			let color = c.1

			xml += "   <color"

			// Create a unique name if one isn't supplied
			var name = color.name.count > 0 ? color.name : "color_\(offset)"
			name = name.replacingOccurrences(of: " ", with: "_")
			name = name.xmlEscaped()

			xml += " name=\"\(name)\">"

			let format: PAL.ColorByteFormat = self.includeAlphaDuringExport ? .argb : .rgb
			let hex = try color.hexString(format, hashmark: true, uppercase: true)
			xml += hex
			xml += "</color>\n"
		}

		xml += "</resources>\n"

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
	static let androidXML = UTType(PAL.Coder.AndroidColorsXML.utTypeString)!
}
#endif

// MARK: - Internal

fileprivate class AndroidColorsXMLDecoder: NSObject, XMLParserDelegate {

	private var palette = PAL.Palette()
	private var currentElement = ""
	private var currentName: String?
	private var isInsideResourcesBlock: Bool = false

	func parse(from inputStream: InputStream) throws -> PAL.Palette {
		self.palette = PAL.Palette(format: .androidXML)

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

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if elementName == "resources" {
			self.isInsideResourcesBlock = true
		}
		else {
			self.currentElement = elementName
			if elementName == "color" {
				self.currentName = attributeDict["name"]?.xmlDecoded()
			}
		}
	}

	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "resources" {
			self.isInsideResourcesBlock = false
		}
	}

	func parser(_ parser: XMLParser, foundCharacters string: String) {
		if self.isInsideResourcesBlock, self.currentElement == "color" {
			let colorString = string.trimmingCharacters(in: .whitespacesAndNewlines)
			let colorName = self.currentName ?? "color_\(self.palette.colors.count)"
			if let color = try? PAL.Color(rgbHexString: colorString, format: .argb, name: colorName) {
				self.palette.colors.append(color)
			}
		}
	}
}
