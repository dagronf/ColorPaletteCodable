//
//  PAL+NSColorList.swift
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

// NSColorList related functions

#if os(macOS)

import AppKit

public extension PAL.Palette {
	/// Load a palette from an `NSColorList` (macOS only)
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

	/// Returns a flattened `NSColorList` from the contents of the palette
	///
	/// Note that a palette may have duplicate color names, so a unique index will be added to each
	/// `NSColorList` color name to ensure that all colors are exported.
	@inlinable func colorListFromAllColors() -> NSColorList {
		return Self.colorList(from: self.allColors())
	}

	/// Returns an `NSColorList` from just the 'global' colors
	///
	/// Note that a palette may have duplicate color names, so a unique index will be added to each
	/// `NSColorList` color name to ensure that all colors are exported.
	@inlinable func colorListFromGlobalColors() -> NSColorList {
		return Self.colorList(from: self.colors)
	}

	/// Returns an `NSColorList` from an array of colors
	///
	/// Note that the colors may have duplicate color names, so a unique index will be added to each additional duplicate
	/// `NSColorList` color name to ensure that all colors are exported.
	static func colorList(from colors: [PAL.Color]) -> NSColorList {
		var foundNames: [String] = []
		let result = NSColorList()
		colors.enumerated().forEach { iter in
			if let ci = iter.element.nsColor {
				let existingName = iter.element.name
				let newName = foundNames.contains(existingName) ? "\(iter.element.name)_\(iter.offset)" : existingName
				result.setColor(ci, forKey: newName)
				foundNames.append(existingName)
			}
		}
		return result
	}
}

public extension PAL.Group {
	/// Returns an `NSColorList` from the colors in the group
	///
	/// Note that a group can have duplicate color names, so a unique index will be added to each
	/// `NSColorList` color name to ensure that all colors are exported.
	@inlinable var nsColorList: NSColorList {
		return PAL.Palette.colorList(from: self.colors)
	}
}

#endif
