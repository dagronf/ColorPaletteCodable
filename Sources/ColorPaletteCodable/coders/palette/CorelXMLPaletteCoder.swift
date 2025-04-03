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
	class CorelXMLPalette: NSObject, PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .corelDraw
		public let name = "CorelDraw XML Palette"
		public let fileExtension = ["xml"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.coreldraw.xml"   // conforms to `public.xml`

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

extension PAL.Coder.CorelXMLPalette {
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

		if palette.groups.count == 0 {
			throw PAL.CommonError.invalidFormat
		}

		return palette
	}
}

extension PAL.Coder.CorelXMLPalette: XMLParserDelegate {

	private class Colorspace {
		init(name: String) { self.name = name }
		let name: String
		var colors: [PAL.Color] = []
	}

	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if elementName == "palette" {
			self.palette.name = attributeDict["name"]?.xmlDecoded() ?? ""
		}
		else if elementName == "colorspaces" {
			self.isInColorspaceSection = true
		}
		else if elementName == "cs" {
			let name = attributeDict["name"]?.xmlDecoded() ?? ""
			let cs = Colorspace(name: name.lowercased())
			self.colorspaces.append(cs)
		}
		else if elementName == "colors" {
			self.isInColorsSection = true
		}
		else if elementName == "page" {
			let name = attributeDict["name"]?.xmlDecoded() ?? ""
			self.group = PAL.Group(name: name)
		}
		else if elementName == "color" {
			let cs = attributeDict["cs"]?.lowercased()
			let name = attributeDict["name"]?.xmlDecoded() ?? ""
			let tints = attributeDict["tints"] ?? ""
			let components = tints.components(separatedBy: ",").compactMap { Double(String($0)) }

			let color: PAL.Color? = {
				switch cs {
				case "cmyk":
					return try? PAL.Color(colorSpace: .CMYK, colorComponents: components, name: name)
				case "rgb":
					return try? PAL.Color(colorSpace: .RGB, colorComponents: components, name: name)
				case "lab":
					// convert the components to the CGColorSpace.lab ranges
					let l = (components[0] * 100.0)           // Range 0 -> 100
					let a = (components[1] * 256.0) - 128.0   // Range -128 -> 128
					let b = (components[2] * 256.0) - 128.0   // Range -128 -> 128
					let map = [l, a, b]
					return try? PAL.Color(colorSpace: .LAB, colorComponents: map, name: name)
				case "gray":
					return try? PAL.Color(colorSpace: .Gray, colorComponents: components, name: name)
				default:
					if isInColorsSection {
						if let c = self.colorspaces.first(where: { $0.name == cs }) {
							// TODO: Work out what exactly the `tints` value means for colorspace-defined colors means
							// We are just going to be lazy here and just take the first color in the colorspace collection
							// I'm not sure what the 'tints' attribute is being used for here (the doco says something
							// about setting the channel which I just can't wrap my head around)
							if let color = c.colors.first {
								let m = try? PAL.Color(
									colorSpace: color.colorSpace,
									colorComponents: color.colorComponents,
									alpha: color.alpha,
									name: name,
									colorType: color.colorType
								)
								return m ?? .clear
							}
						}
					}
					return PAL.Color.clear
				}
			}()

			if let color2 = color {
				if self.isInColorspaceSection {
					// It's a color defined as a collection of colors defined for multiple colorspaces

					// <cs name="MySpotColor1" fixedID="1">
					//    <color cs="CMYK" tints="0,0,0.58,0"/>
					//    <color cs="LAB" tints="0.9227,0.480039215686275,0.714196078431373"/>
					//    <color cs="RGB" tints="0.968627450980392,0.92156862745098,0.490196078431373"/>
					// </cs>

					self.colorspaces.last?.colors.append(color2)
				}
				else {
					self.group.colors.append(color2)
				}
			}
		}
	}

	public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "page" {
			self.palette.groups.append(self.group)
			self.group = PAL.Group()
		}
		else if elementName == "colors" {
			self.isInColorsSection = false
		}
		else if elementName == "colorspaces" {
			self.isInColorspaceSection = false
		}
	}
}

extension PAL.Coder.CorelXMLPalette {
	public func encode(_ palette: PAL.Palette) throws -> Data {

		var xml = "<?xml version=\"1.0\"?>\n"
		xml += "<palette guid=\"\(UUID().uuidString)\">"
		if palette.name.count > 0 {
			xml += " name=\"\(palette.name.xmlEscaped())\">"
		}
		xml += "<colors>"

		if palette.colors.count > 0 {
			xml += try pageData(name: "", colors: palette.colors)
		}
		
		try palette.groups.forEach { group in
			let page = try self.pageData(name: group.name, colors: group.colors)
			xml += page
		}

		xml += "</colors>"
		xml += "</palette>"

		guard let data = xml.data(using: .utf8) else {
			throw PAL.CommonError.unsupportedPaletteType
		}
		return data
	}

	func pageData(name: String, colors: [PAL.Color]) throws -> String {
		var result = "<page>"
		try colors.forEach { color in

			result += "<color"

			if color.name.isEmpty == false {
				result += " name=\"\(color.name.xmlEscaped())\""
			}

			// Needs an explicit type for supporting older swift versions
			let colorspaceInfo: (String, [Double]) = try {
				switch color.colorSpace {
				case .CMYK: return ("CMYK", color.colorComponents)
				case .RGB: return ("RGB", color.colorComponents)
				case .Gray: return ("GRAY", color.colorComponents)
				case .LAB:
					// Map from CGColorSpace values to XML specification
					if color.colorComponents.count < 3 { throw PAL.CommonError.invalidColorComponentCountForModelType }
					return ("LAB", [
						color.colorComponents[0] / 100.0,            // 0…100 -> 0.0…1.0
						(color.colorComponents[1] + 128.0) / 256.0,  // -128…128 -> 0.0…1.0
						(color.colorComponents[2] + 128.0) / 256.0   // -128…128 -> 0.0…1.0
					])
				}
			}()

			result += " cs=\"\(colorspaceInfo.0)\""
			let tints = colorspaceInfo.1.map({ _XMLD($0) }).joined(separator: ",")
			if tints.isEmpty == false {
				result += " tints=\"\(tints)\""
			}
			result += "/>"
		}
		result += "</page>"
		return result
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let corelPaletteXML = UTType(PAL.Coder.CorelXMLPalette.utTypeString)!
}
#endif
