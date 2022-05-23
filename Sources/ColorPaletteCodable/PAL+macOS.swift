//
//  PAL+macOS.swift
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

import AppKit

public extension PAL.Palette {
	/// Load a palette from an NSColorList (macOS only)
	init(_ colorList: NSColorList) throws {
		let names = colorList.allKeys
		
		var colors: [PAL.Color] = []
		try names.forEach { name in
			if let color = colorList.color(withKey: name) {
				colors.append(try PAL.Color(cgColor: color.cgColor, name: name))
			}
		}
		self.colors = colors
	}
	
	/// Returns a flattened nscolorlist from the palette
	func flattenedColorList() -> NSColorList {
		let result = NSColorList()
		self.allGroups.enumerated().forEach { giter in
			giter.1.colors.enumerated().forEach { citer in
				if let ci = citer.1.nsColor {
					result.setColor(ci, forKey: "\(giter.offset):\(giter.element.name):\(citer.offset):\(citer.element.name)")
				}
			}
		}
		return result
	}

	/// Returns a a colorlist from just the 'global' colors
	///
	/// if a color isn't named, it automatically generates an name for the color before storing
	func globalColorList() -> NSColorList {
		let result = NSColorList()
		self.colors.enumerated().forEach { iter in
			if let ci = iter.1.nsColor {
				let name: String = {
					if iter.element.name.count > 0 { return iter.element.name }
					else if let hex = ci.cgColor.hexRGB { return hex }
					return UUID().uuidString
				}()
				result.setColor(ci, forKey: name)
			}
		}
		return result
	}
}

public extension PAL.Color {
	/// Create a color from an NSColor instance
	init(color: NSColor, name: String = "", colorType: PAL.ColorType = .global) throws {
		try self.init(cgColor: color.cgColor, name: name, colorType: colorType)
	}

	/// Returns an NSColor representation of this color
	var nsColor: NSColor? {
		return self.cgColor.unwrapping { NSColor(cgColor: $0) }
	}
}

#endif
