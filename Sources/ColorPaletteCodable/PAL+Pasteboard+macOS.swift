//
//  PAL+Pasteboard.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
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

#if os(macOS)

import Foundation
import UniformTypeIdentifiers
import AppKit

/// The pasteboard type for the NSColorList
let NSColorListPasteboardTypeName = "NSColorList.bplist"
let NSColorListPasteboardType = NSPasteboard.PasteboardType(NSColorListPasteboardTypeName)

public extension PAL.Palette {
	/// macOS pasteboard type
	static let PasteboardType = NSPasteboard.PasteboardType(PAL.UTI)

	/// Add the content of the palette onto the pasteboard
	func setOnPasteboard(_ pasteboard: NSPasteboard) throws {
		try pasteboard.setPalette(self)
	}

	/// Read a palette from the pasteboard. If no palette is found, returns nil
	static func readFromPasteboard(_ pasteboard: NSPasteboard) -> PAL.Palette? {
		return pasteboard.readPalette()
	}
}

public extension NSPasteboard {
	/// Set the palette on this pasteboard
	func setPalette(_ palette: PAL.Palette) throws {
		let types = [PAL.Palette.PasteboardType, NSColorListPasteboardType]
		self.declareTypes(types, owner: nil)
		let enc = try PAL.Coder.JSON(prettyPrint: true).encode(palette)
		if let encString = String(data: enc, encoding: .utf8) {
			self.setString(encString, forType: PAL.Palette.PasteboardType)
			self.setString(encString, forType: .string)
		}

		// Add in an NSColorList representation
		if let data = try? PAL.Coder.CLR().encode(palette) {
			self.setData(data, forType: NSColorListPasteboardType)
		}
	}

	/// Read a palette from the pasteboard. If no palette is found, returns nil
	func readPalette() -> PAL.Palette? {
		if let strVal = self.string(forType: NSPasteboard.PasteboardType(PAL.UTI)),
			let data = strVal.data(using: .utf8)
		{
			if let palette = try? PAL.Coder.JSON().decode(from: data) {
				return palette
			}
		}

		if let colorListData = self.data(forType: NSColorListPasteboardType) {
			if let palette = try? PAL.Coder.CLR().decode(from: colorListData) {
				return palette
			}
		}
		return nil
	}
}

#endif
