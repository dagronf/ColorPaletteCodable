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

/// A basic text parsing mechanism
struct TextParser {
	/// The raw text to parse
	let text: String

	/// The current read index
	private(set) var currentIndex: String.Index

	/// Return true if the parser is at the end of the current text
	var isAtEnd: Bool { self.currentIndex == self.text.endIndex }

	/// Create with text
	init(text: String) {
		self.text = text
		self.currentIndex = text.startIndex
	}

	/// Move to the next instance of a string
	/// - Parameter str: The string to search for
	/// - Returns: True if the string was found. The read pointer will shift to the first character AFTER the match
	mutating func moveToNextInstance(of str: String) -> Bool {
		if let r = self.text.range(of: str, range: self.currentIndex ..< self.text.endIndex) {
			self.currentIndex = r.upperBound
			return true
		}
		else {
			return false
		}
	}

	/// Return the current character, and move to the next index
	/// - Returns: A character, or nil if we're at the end of the string
	mutating func next() -> Character? {
		guard self.currentIndex < self.text.endIndex else { return nil }
		defer { self.currentIndex = self.text.index(after: self.currentIndex) }
		return self.text[self.currentIndex]
	}
}
