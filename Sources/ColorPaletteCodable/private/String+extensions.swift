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

extension String {
	/// Split the string into its component lines
	///
	/// Much more reliable than `content.components(separatedBy: .newlines)`
	/// which unfortunately splits `\r\n` into _two_ lines, one being an empty line.
	var lines: [String] {
		var linesArray = [String]()
		// Split the string into lines using any type of newline (CR, LF, or CRLF)
		self.enumerateLines { line, _ in
			linesArray.append(line)
		}
		return linesArray
	}

	/// Trim the whitespace from a string
	@inlinable func trim() -> String { self.trimmingCharacters(in: .whitespaces) }


	/// Simple XML encoding for a string
	func xmlEscaped() -> String {
		self.replacingOccurrences(of: "&", with: "&amp;")
			.replacingOccurrences(of: "<", with: "&lt;")
			.replacingOccurrences(of: ">", with: "&gt;")
			.replacingOccurrences(of: "\"", with: "&quot;")
			.replacingOccurrences(of: "'", with: "&apos;")
	}

	/// Simple XML decoding
	func xmlDecoded() -> String {
		self.replacingOccurrences(of: "&amp;", with: "&")
			.replacingOccurrences(of: "&lt;", with: "<")
			.replacingOccurrences(of: "&gt;", with: ">")
			.replacingOccurrences(of: "&quot;", with: "\"")
			.replacingOccurrences(of: "&apos;", with: "'")
	}

	/// Strip trailing null (\0) characters from a string
	func stripTrailingNulls() -> String {
		if let i = self.firstIndex(of: "\0") {
			return String(self.prefix(upTo: i))
		}
		return self
	}
}
