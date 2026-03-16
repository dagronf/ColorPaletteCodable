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

// https://www.selapa.net/swatches/colors/fileformats.php#adobe_acbl

// <?xml version="1.0" encoding="UTF-8"?>
// <AdobeSwatchbook Version="1" BookID="3002">
//    <PrefixPostfixPairs>
//       <PrefixPostfixPair Prefix="PANTONE " Postfix=" C"/>
//       <PrefixPostfixPair ID="LegacyCVC" Prefix="PANTONE " Postfix=" CVC"/>
//    </PrefixPostfixPairs>
//    <Formats>
//       <Format ColorSpace="CMYK" Encoding="Float" Channels="4" ID="0"/>
//    </Formats>
//    <Swatches>
//       <Sp N="Yellow"><C>0 0.01 1 0</C></Sp>
//       <Sp N="Yellow 012"><C>0 0.04 1 0</C></Sp>
//       <Sp N="Orange 021"><C>0 0.53 1 0</C></Sp>
//       <Sp N="Warm Red"><C>0 0.75 0.9 0</C></Sp>
//       <Sp N="Red 032"><C>0 0.9 0.86 0</C></Sp>
//       <Sp N="Rubine Red"><C>0 1 0.15 0.04</C></Sp>
//       <Sp N="Rhodamine Red"><C>0.03 0.89 0 0</C></Sp>
//       ...
//       <Sp N="8100"><C>0.1 0.15 0.05 0.2</C></Sp>
//       <Sp N="8201"><C>0.25 0 0 0.25</C></Sp>
//       <Sp N="8281"><C>0.35 0 0.2 0.25</C></Sp>
//       <Sp N="8321"><C>0.2 0 0.3 0.25</C></Sp>
//    </Swatches>
// </AdobeSwatchbook>

public extension PAL.Coder {

	/// A _very_ basic importer for Adobe Illustrator CS3 ACBL legacy files.
	class ACBL: NSObject, PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .acbl
		public let name = "Adobe Color Book (Legacy)"
		public let fileExtension = ["acbl"]
		public static let utTypeString = "com.adobe.acbl"  // conforms to `public.xml`

		/// Create
		public override init() {
			super.init()
		}

		// Private

		private var palette = PAL.Palette(format: .acbl)
		private var isValidFormat = false

		private struct ACBLColor {
			var name: String = ""
			var components: [Double] = []
		}
		private var currentColor = ACBLColor()

		private var channelCount: Int = 0
		private var colorspace: PAL.ColorSpace?

		private var isInColorComponents = false
	}
}

// MARK: - Encode

extension PAL.Coder.ACBL {
	public func encode(_ palette: PAL.Palette) throws -> Data {
		throw PAL.CommonError.unsupportedPaletteType
	}
}

// MARK: - Decode

extension PAL.Coder.ACBL: XMLParserDelegate {

	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {
		self.palette = PAL.Palette(format: .acbl)
		let xmlParser = XMLParser(stream: inputStream)
		xmlParser.delegate = self

		if xmlParser.parse() == false {
			throw PAL.CommonError.invalidFormat
		}

		if palette.colors.count == 0 {
			throw PAL.CommonError.invalidFormat
		}

		return palette
	}
}

extension PAL.Coder.ACBL {
	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if elementName == "AdobeSwatchbook" {
			if let ch = attributeDict["Version"],
				Int(ch) == 1
			{
				self.isValidFormat = true
			}
			else {
				parser.abortParsing()
			}
		}
		else if elementName == "Format" {
			if let ch = attributeDict["Channels"],
				let chc = Int(ch)
			{
				self.channelCount = chc
			}
			if let cs = attributeDict["ColorSpace"],
				let cst = PAL.ColorSpace(rawValue: cs)
			{
				self.colorspace = cst
			}
			else {
				parser.abortParsing()
			}
		}
		else if elementName == "Sp" {
			self.currentColor = ACBLColor()
			if let name = attributeDict["N"] {
				self.currentColor.name = name
			}
		}
		else if elementName == "C" {
			self.isInColorComponents = true
		}
	}

	public func parser(_ parser: XMLParser, foundCharacters string: String) {
		if self.isInColorComponents {
			// Should be a string containing an array of float values
			let components = string.split(separator: " ")
				.compactMap { Double($0)?.unitClamped }
			if components.count == self.channelCount {
				self.currentColor.components = components
			}
		}
	}

	public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "Sp" {
			if let cs = self.colorspace {
				if let c = try? PAL.Color(colorSpace: cs, colorComponents: self.currentColor.components, name: self.currentColor.name) {
					self.palette.add(c)
				}
			}
		}
		else if elementName == "C" {
			self.isInColorComponents = false
		}
	}
}
