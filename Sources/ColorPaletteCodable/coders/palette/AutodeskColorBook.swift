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

// https://help.autodesk.com/view/RVT/2024/ENU/?guid=Revit_API_Revit_API_Developers_Guide_Advanced_Topics_Autodesk_Color_Book_html
// https://download.autodesk.com/global/acb/index.html

// NOTES:
// * It appears that each color page can only contain a MAXIMUM of 10 colors.
// * The page color represents one of the colors in the ColorEntries for the page.
//
// * For decoding I'm ignoring the pageColor - its supposed to be equal to one of the colors in
//   the colorEntry fields anyway. The Autodesk online editor only allows you to select one of the 10 color entries
// * For encoding, I'm setting the page color to the first color in the group.

import Foundation

#if canImport(FoundationXML)
// For non-apple platforms it seems that the XML parser has been shifted into its own module
import FoundationXML
#endif

public extension PAL.Coder {
	struct AutodeskColorBook: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .autodeskColorBook
		public let name = "Autodesk Color Book"
		public let fileExtension = ["acb"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.autodesk.colorbook"   // conforms to `public.xml`
	}
}

// MARK: - Decoding

public extension PAL.Coder.AutodeskColorBook {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		try AutodeskColorBookDecoder().parse(from: inputStream)
	}
}

// MARK: - Encoding

public extension PAL.Coder.AutodeskColorBook {
	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation of the palette
	///
	/// Reference: https://help.autodesk.com/view/RVT/2024/ENU/?guid=Revit_API_Revit_API_Developers_Guide_Advanced_Topics_Autodesk_Color_Book_html
	func encode(_ palette: PAL.Palette) throws -> Data {

		var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
		xml += "<colorBook>\n"

//		<bookName>Resene Total Colour System - 2022</bookName>
		let name = (palette.name.count > 0 ? palette.name : "Untitled").xmlEscaped()
		xml += "   <bookName>\(name)</bookName>\n"

		xml += "   <majorVersion>1</majorVersion>\n"
		xml += "   <minorVersion>0</minorVersion>\n"

		for g in palette.allGroups {
			guard g.colors.count > 1 else {
				// Ignore the group
				continue
			}

			// Autodesk color book can only handle a maximum of 10 color entries
			let entries = g.colors.prefix(10)

			xml += "   <colorPage>\n"

			// Assume that the first color is the page color.
			let c = entries[0]
			xml += "      <pageColor>\n"
			xml += try encodeColor(c)
			xml += "      </pageColor>\n"

			try entries.forEach { c in
				xml += "      <colorEntry>\n"

				let name = c.name.count > 0 ? c.name : UUID().uuidString
				xml += "         <colorName>\(name.xmlEscaped())</colorName>\n"
				xml += try encodeColor(c)
				xml += "      </colorEntry>\n"
			}

			xml += "   </colorPage>\n"
		}

		xml += "</colorBook>\n"

		guard let data = xml.data(using: .utf8) else {
			throw PAL.CommonError.unsupportedPaletteType
		}
		return data
	}

	func encodeColor(_ color: PAL.Color) throws -> String {
		let rgb = try color.rgb()
		var xml  = "         <RGB8>\n"
		    xml += "            <red>\(rgb.r255)</red>\n"
		    xml += "            <green>\(rgb.g255)</green>\n"
		    xml += "            <blue>\(rgb.b255)</blue>\n"
		    xml += "         </RGB8>\n"
		return xml
	}
}


// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let autodeskColorBook = UTType(PAL.Coder.AutodeskColorBook.utTypeString)!
}
#endif


// MARK: - Internal

fileprivate class AutodeskColorBookDecoder: NSObject, XMLParserDelegate {
	private var palette = PAL.Palette(format: .autodeskColorBook)

	private var currentGroup: PAL.Group?

	private var colorName: String?
	private var r: UInt8?  // 0 ... 255
	private var g: UInt8?  // 0 ... 255
	private var b: UInt8?  // 0 ... 255

	private var xmlStack: [String] = []

	func parse(from inputStream: InputStream) throws -> PAL.Palette {

		let parser = XMLParser(stream: inputStream)
		parser.delegate = self

		if parser.parse() == false {
			throw PAL.CommonError.invalidFormat
		}

		if palette.totalColorCount == 0 {
			throw PAL.CommonError.invalidFormat
		}
		return palette
	}

	func parser(
		_ parser: XMLParser,
		didStartElement elementName: String,
		namespaceURI: String?,
		qualifiedName qName: String?,
		attributes attributeDict: [String : String] = [:]
	) {
		let elementName = elementName.trimmingCharacters(in: .whitespacesAndNewlines)

		if elementName == "colorPage" {
			if xmlStack.last != "colorBook" {
				parser.abortParsing()
			}
			self.currentGroup = PAL.Group()
		}
		else if elementName == "colorEntry" || elementName == "pageColor" {
			if xmlStack.last != "colorPage" {
				parser.abortParsing()
			}
		}
		else if elementName == "colorName" {
			if xmlStack.last != "colorEntry" {
				parser.abortParsing()
			}
		}
		else if elementName == "red" || elementName == "green" || elementName == "blue" {
			if xmlStack.last != "RGB8" {
				parser.abortParsing()
			}
		}
		xmlStack.append(elementName)
	}

	func parser(_ parser: XMLParser, foundCharacters string: String) {
		let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
		if string.count == 0 { return }
		if xmlStack.last == "bookName" {
			self.palette.name = string
		}
		else if xmlStack.last == "colorName" {
			self.colorName = string
		}
		else if xmlStack.last == "red" {
			let redComponent = UInt8(string)?.clamped(to: 0 ... 255)
			self.r = redComponent
		}
		else if xmlStack.last == "green" {
			let greenComponent = UInt8(string)?.clamped(to: 0 ... 255)
			self.g = greenComponent
		}
		else if xmlStack.last == "blue" {
			let blueComponent = UInt8(string)?.clamped(to: 0 ... 255)
			self.b = blueComponent
		}
	}

	func parser(
		_ parser: XMLParser,
		didEndElement elementName: String,
		namespaceURI: String?,
		qualifiedName qName: String?
	) {
		if elementName == "colorEntry" { // || elementName == "pageColor" {
			if let r, let g, let b {
				var c = PAL.Color(r255: r, g255: g, b255: b)
				if let colorName {
					c.name = colorName
				}
				self.currentGroup?.colors.append(c)

				self.r = nil
				self.g = nil
				self.b = nil
				self.colorName = nil
			}
		}
		else if elementName == "colorPage", var grp = self.currentGroup {
			// The color pages aren't named - just give them a default one
			grp.name = "Color Page \(self.palette.groups.count + 1)"
			self.palette.groups.append(grp)
			self.currentGroup = nil
		}
		self.xmlStack = xmlStack.dropLast()
	}
}

