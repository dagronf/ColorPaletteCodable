//
//  PAL+Pasteboard+iOS.swift
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

#if os(iOS)

import UIKit
public typealias PALPasteboard = UIPasteboard

public extension PAL.Palette {
	/// Put the content of the colorlist onto the pasteboard using the color coder
	func setOnPasteboard(_ pasteboard: UIPasteboard) throws {
		try pasteboard.setPalette(self)
	}

	/// Read a palette from the pasteboard. If no palette is found, returns nil
	static func readFromPasteboard(_ pasteboard: UIPasteboard) -> PAL.Palette? {
		return pasteboard.readPalette()
	}
}

public extension UIPasteboard {
	/// Set the palette on this pasteboard
	func setPalette(_ palette: PAL.Palette) throws {
		let enc = try PAL.Coder.JSON(prettyPrint: true).encode(palette)
		if let encString = String(data: enc, encoding: .utf8) {
			self.setValue(encString, forPasteboardType: PAL.UTI)
		}
	}

	/// Read a palette from the pasteboard. If no palette is found, returns nil
	func readPalette() -> PAL.Palette? {
		if
			self.contains(pasteboardTypes: [PAL.UTI]),
			let data = self.value(forPasteboardType: PAL.UTI) as? Data,
			let palette = try? PAL.Coder.JSON().decode(from: data)
		{
			return palette
		}
		return nil
	}
}

#endif
