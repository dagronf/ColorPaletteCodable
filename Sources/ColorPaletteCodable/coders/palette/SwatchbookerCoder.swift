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

// https://www.selapa.net/swatchbooker/

import Foundation

#if canImport(Darwin)
import ZIPFoundation
#endif

#if canImport(FoundationXML)
// For non-apple platforms it seems that the XML parser has been shifted into its own module
import FoundationXML
#endif

public extension PAL.Coder {
	/// A Swatchbooker (.sbz) file encoder/decoder
	struct SwatchbookerCoder: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .swatchbooker
		public let name = "Swatchbooker"

		public let fileExtension = ["sbz"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.swatchbooker"
	}
}

#if canImport(Darwin)

public extension PAL.Coder.SwatchbookerCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let data = inputStream.readAllData()

		let archive = try Archive(data: data, accessMode: .read)
		guard let entry = archive["swatchbook.xml"] else {
			throw PAL.CommonError.invalidFormat
		}

		var xmlData = Data()
		let _ = try archive.extract(entry) { data in
			xmlData.append(data)
		}

		return try SwatchBookerDecoder().parse(xmlData: xmlData)
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		throw PAL.CommonError.notImplemented
	}
}

#else
public extension PAL.Coder.SwatchbookerCoder {
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
	static let swatchbooker = UTType(PAL.Coder.SwatchbookerCoder.utTypeString)!
}
#endif

// MARK: - Internal

#if canImport(Darwin)

fileprivate class NodeStack {
	class Node {
		let name: String
		let attrs: [String: String]
		var content: String
		init(name: String, attrs: [String : String]) {
			self.name = name
			self.attrs = attrs
			self.content = ""
		}
	}

	var stack: [Node] = [] {
		didSet {
			self.path = self.stack.map { $0.name }.joined(separator: ".")
		}
	}
	private(set) var path: String = ""

	func push(_ string: String, attributes: [String: String]) { self.stack.append(Node(name: string, attrs: attributes)) }
	func pop() { _ = self.stack.popLast() }
	func last() -> Node? { self.stack.last }

	func matches(_ path: String) -> Bool {
		self.path == path
	}
}

fileprivate class SwatchBookerDecoder: NSObject, XMLParserDelegate {

	var palette = PAL.Palette(format: .swatchbooker)
	var nodeStack = NodeStack()

	var colorTitle: String?
	var colorID: String?
	var colorMode: String?
	var colorUsage: String?
	var colorComponents = [Double]()

	func parse(xmlData: Data) throws -> PAL.Palette {
		let parser = XMLParser(data: xmlData)
		parser.delegate = self
		guard parser.parse() else {
			throw PAL.CommonError.invalidFormat
		}

		guard palette.totalColorCount > 0 else {
			throw PAL.CommonError.tooFewColors
		}
		return palette
	}

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

		let elementName = elementName.trimmingCharacters(in: .whitespacesAndNewlines)
		if elementName.count == 0 { return }

		if elementName == "color" && nodeStack.matches("SwatchBook.materials") {
			self.colorTitle = nil
			self.colorID = nil
			self.colorMode = nil
			self.colorUsage = attributeDict["usage"]
			self.colorComponents = []
		}
		else if elementName == "values",
			nodeStack.matches("SwatchBook.materials.color"),
			let colorMode = attributeDict["model"]
		{
			self.colorMode = colorMode
			self.colorComponents = []
		}

		self.nodeStack.push(elementName, attributes: attributeDict)
	}

	public func parser(_ parser: XMLParser, foundCharacters string: String) {
		let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
		if string.count == 0 { return }

		self.nodeStack.last()?.content += string
	}

	public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

		defer { self.nodeStack.pop() }

		let elementName = elementName.trimmingCharacters(in: .whitespacesAndNewlines)
		if elementName.count == 0 { return }
		guard let current = self.nodeStack.last() else {
			return
		}
		assert(current.name == elementName)

		if nodeStack.matches("SwatchBook.metadata.dc:title"), current.attrs["xml:lang"] == nil {
			self.palette.name = current.content
		}
		else if nodeStack.matches("SwatchBook.materials.color.metadata.dc:title") {
			self.colorTitle = current.content
		}
		else if nodeStack.matches("SwatchBook.materials.color.metadata.dc:identifier") {
			self.colorID = current.content
		}
		else if nodeStack.matches("SwatchBook.materials.color.values") {
			self.colorComponents = current.content.components(separatedBy: " ").compactMap { Double($0) }
		}

		if elementName == "color",
			nodeStack.matches("SwatchBook.materials.color"),
			let colorMode = self.colorMode
		{
			// We should have a formed color by now
			let name = self.colorTitle ?? self.colorID ?? ""

			if colorMode == "RGB" && self.colorComponents.count == 3 {
				if let t = try? PAL.Color(colorSpace: .RGB, colorComponents: self.colorComponents, name: name) {
					self.palette.colors.append(t)
				}
			}
			else if colorMode == "Lab" && self.colorComponents.count == 3 {
				if let t = try? PAL.Color(colorSpace: .LAB, colorComponents: self.colorComponents, name: name) {
					self.palette.colors.append(t)
				}
			}
			else if colorMode == "GRAY" && self.colorComponents.count == 1 {
				if let t = try? PAL.Color(colorSpace: .Gray, colorComponents: self.colorComponents, name: name) {
					self.palette.colors.append(t)
				}
			}
			else if colorMode == "CMYK" && self.colorComponents.count == 4 {
				if let t = try? PAL.Color(colorSpace: .CMYK, colorComponents: self.colorComponents, name: name) {
					self.palette.colors.append(t)
				}
			}
			else if colorMode == "HSV" && self.colorComponents.count == 3 {
				let c = PAL.Color(
					hf: self.colorComponents[0],
					sf: self.colorComponents[1],
					bf: self.colorComponents[2],
					name: name
				)
				self.palette.colors.append(c)
			}
			else if colorMode == "HSL" && self.colorComponents.count == 3 {
				let c = PAL.Color(
					hf: self.colorComponents[0],
					sf: self.colorComponents[1],
					lf: self.colorComponents[2],
					name: name
				)
				self.palette.colors.append(c)
			}
		}
	}
}

#endif
