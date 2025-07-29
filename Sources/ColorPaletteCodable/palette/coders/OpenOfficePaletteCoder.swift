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

/*
<?xml version="1.0" encoding="UTF-8"?>
<ooo:color-table xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svg="http://www.w3.org/2000/svg" xmlns:ooo="http://openoffice.org/2004/office">
<!-- LibreOffice colors -->
<!-- http://wiki.documentfoundation.org/Marketing/Branding#Colors -->
	<!-- Green -->
	<draw:color draw:name="Green 0" draw:color="#106802"/>
	<draw:color draw:name="Green 1 (LibreOffice Main Color)" draw:color="#18a303"/>
	<draw:color draw:name="Green 2" draw:color="#43c330"/>
	<draw:color draw:name="Green 3" draw:color="#92e285"/>
	<draw:color draw:name="Green 4" draw:color="#ccf4c6"/>
</ooo:color-table>
*/

import Foundation

#if canImport(FoundationXML)
// For non-apple platforms it seems that the XML parser has been shifted into its own module
import FoundationXML
#endif

public extension PAL.Coder {
	struct OpenOfficePaletteCoder: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .openOffice
		public let name = "OpenOffice Palette"
		public let fileExtension = ["soc"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.openoffice"   // conforms to `public.xml`
	}
}

// MARK: - Decoding

public extension PAL.Coder.OpenOfficePaletteCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		try OpenOfficePaletteDecoder().parse(from: inputStream)
	}
}

// MARK: - Encoding

public extension PAL.Coder.OpenOfficePaletteCoder {
	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation of the palette
	///
	/// Currently not supported for Adobe Color Book
	func encode(_ palette: PAL.Palette) throws -> Data {

		var xml = """
			<?xml version="1.0" encoding="UTF-8"?>
			<office:color-table xmlns:office="http://openoffice.org/2000/office" xmlns:style="http://openoffice.org/2000/style" xmlns:text="http://openoffice.org/2000/text" xmlns:table="http://openoffice.org/2000/table" xmlns:draw="http://openoffice.org/2000/drawing" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="http://openoffice.org/2000/meta" xmlns:number="http://openoffice.org/2000/datastyle" xmlns:svg="http://www.w3.org/2000/svg" xmlns:chart="http://openoffice.org/2000/chart" xmlns:dr3d="http://openoffice.org/2000/dr3d" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="http://openoffice.org/2000/form" xmlns:script="http://openoffice.org/2000/script">
			"""

		palette.allColors().enumerated().forEach { item in
			do {
				let hex = try item.1.hexString(.rgb, hashmark: true, uppercase: true)
				xml += "<draw:color draw:name=\"\(item.1.name.xmlEscaped())\" draw:color=\"\(hex)\"/>\n"
			}
			catch {
				ColorPaletteLogger.log(.error, "OpenOfficePaletteCoder: Cannot convert colorspace for color %d, skipping...", item.0)
			}
		}

		xml += "</office:color-table>\n"

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
	static let openOfficePalette = UTType(PAL.Coder.OpenOfficePaletteCoder.utTypeString)!
}
#endif

// MARK: - Internal

fileprivate class OpenOfficePaletteDecoder: NSObject, XMLParserDelegate {
	var palette = PAL.Palette(format: .openOffice)

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
		if elementName == "draw:color" {
			let name: String = attributeDict["draw:name"] ?? ""
			if
				let colorString: String = attributeDict["draw:color"],
				let color = try? PAL.Color(rgbHexString: colorString, format: .argb, name: name.xmlDecoded())
			{
				self.palette.colors.append(color)
			}
		}
	}
}
