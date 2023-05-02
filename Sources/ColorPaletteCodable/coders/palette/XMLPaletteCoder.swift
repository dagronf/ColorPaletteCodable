//
//  XMLPaletteCoder.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

public extension PAL.Coder {
	/// .sketchpalette Sketch palette file
	class XMLPalette: NSObject, PAL_PaletteCoder {
		public let fileExtension = ["xml"]
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

extension PAL.Coder.XMLPalette {
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

		if palette.groups.count == 0 {
			throw PAL.CommonError.invalidFormat
		}

		return palette
	}
}



extension PAL.Coder.XMLPalette: XMLParserDelegate {

	private class Colorspace {
		init(name: String) { self.name = name }
		let name: String
		var colors: [PAL.Color] = []
	}

	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if elementName == "palette" {
			self.palette.name = attributeDict["name"] ?? ""
		}
		else if elementName == "colorspaces" {
			self.isInColorspaceSection = true
		}
		else if elementName == "cs" {
			let name = attributeDict["name"] ?? ""
			let cs = Colorspace(name: name.lowercased())
			self.colorspaces.append(cs)
		}
		else if elementName == "colors" {
			self.isInColorsSection = true
		}
		else if elementName == "page" {
			let name = attributeDict["name"] ?? ""
			self.group = PAL.Group(name: name)
		}
		else if elementName == "color" {
			//guard self.isInColorsSection == true else { return }
			let cs = attributeDict["cs"]?.lowercased()
			let name = attributeDict["name"] ?? ""
			let tints = attributeDict["tints"] ?? ""
			let components = tints.components(separatedBy: ",").compactMap { Float32(String($0)) }

			let color: PAL.Color? = {
				switch cs {
				case "cmyk":
					return try? PAL.Color(name: name, colorSpace: .CMYK, colorComponents: components)
				case "rgb":
					return try? PAL.Color(name: name, colorSpace: .RGB, colorComponents: components)
				default:
					if isInColorsSection {
						if let c = self.colorspaces.first(where: { $0.name == cs }),
							components.count == 1
						{
							let offsetf = components[0]
							let offset = Int(offsetf) - 1
							if offset < c.colors.count {
								let color = c.colors[offset]
								let m = try? PAL.Color(
									name: name,
									colorSpace: color.colorSpace,
									colorComponents: color.colorComponents,
									colorType: color.colorType,
									alpha: color.alpha
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

extension PAL.Coder.XMLPalette {
	public func encode(_ palette: PAL.Palette) throws -> Data {

		var xml = "<?xml version=\"1.0\"?>\n"
		xml += "<palette guid=\"\(UUID().uuidString)\""
		if palette.name.count > 0 {
			xml += " name=\"\(palette.name)\">"
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

				let csMap: String = try {
					switch color.colorSpace {
					case .CMYK: return "CMYK"
					case .RGB: return "RGB"
					default: throw PAL.CommonError.unsupportedColorspace(color.colorSpace)
					}
				}()

				result += " cs=\"\(csMap)\""
				result += " name=\"\(color.name)\""
				let tint = color.colorComponents.map { "\($0)" }
					.joined(separator: ",")
				if tint.isEmpty == false {
					result += " tints=\"\(tint)\""
				}
			}
			result += "/>"
		}
		result += "</page>"
		return result
	}
}
