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

import Foundation
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
public let NSColorListPasteboardTypeName = "NSColorList.bplist"
public let NSColorListPasteboardType = NSPasteboard.PasteboardType(NSColorListPasteboardTypeName)
#else
import UIKit
public typealias PALPasteboard = UIPasteboard
#endif

public extension PAL {
	static let UTI = "public.dagronf.colorpalette"
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension UTType {
	/// RGBA UTI - conforms to public.json
	static var colorPalette: UTType {
		UTType(importedAs: PAL.UTI, conformingTo: .json)
	}
}


#if os(macOS)
extension PAL.Palette {
	public static let PasteboardType = NSPasteboard.PasteboardType(PAL.UTI)

	/// Put the content of the palette onto the pasteboard
	public func setOnPasteboard(_ pasteboard: NSPasteboard) throws {
		let types = [PAL.Palette.PasteboardType, NSColorListPasteboardType]
		pasteboard.declareTypes(types, owner: nil)
		let enc = try PAL.Coder.JSON().data(for: self)
		if let encString = String(data: enc, encoding: .utf8) {
			pasteboard.setString(encString, forType: PAL.Palette.PasteboardType)
			pasteboard.setString(encString, forType: .string)
		}

		if let data = try? PAL.Coder.CLR().data(for: self) {
			pasteboard.setData(data, forType: NSColorListPasteboardType)
		}
	}

	/// Attempt to create a palette from the contents of the pasteboard
	public static func Create(from pasteboard: NSPasteboard) -> PAL.Palette? {
		if
			let strVal = pasteboard.string(forType: NSPasteboard.PasteboardType(PAL.UTI)),
			let data = strVal.data(using: .utf8)
		{
			if let palette = try? PAL.Coder.JSON().load(data: data) {
				return palette
			}
		}

		if let colorListData = pasteboard.data(forType: NSColorListPasteboardType) {
			if let palette = try? PAL.Coder.CLR().load(data: colorListData) {
				return palette
			}
		}
		return nil
	}

}
#else
extension PAL.Palette {
	/// Put the content of the colorlist onto the pasteboard using the color coder
	public func setOnPasteboard(_ pasteboard: UIPasteboard) throws {
		let enc = try PAL.Coder.JSON().data(for: self)
		if let encString = String(data: enc, encoding: .utf8) {
			pasteboard.setValue(encString, forPasteboardType: PAL.UTI)
		}
	}

	/// Attempt to create a palette from the contents of the pasteboard
	public static func Create(from pasteboard: UIPasteboard) -> PAL.Palette? {
		if
			pasteboard.contains(pasteboardTypes: [PAL.UTI]),
			let data = pasteboard.value(forPasteboardType: PAL.UTI) as? Data,
			let palette = try? PAL.Coder.JSON().load(data: data)
		{
			return palette
		}
		return nil
	}
}
#endif
