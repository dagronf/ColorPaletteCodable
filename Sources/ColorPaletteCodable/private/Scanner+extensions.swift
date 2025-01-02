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

// Scanner extensions and utilities

import Foundation

extension Scanner {
	/// Scan characters in a character set
	func _scanCharacters(in cs: CharacterSet) -> String? {
#if os(Linux)
		return self.scanCharacters(from: cs)
#else
		if #available(macOS 10.15, *) {
			return self.scanCharacters(from: cs)
		}
		else {
			var ns: NSString? = nil
			self.scanCharacters(from: cs, into: &ns)
			return ns as? String
		}
#endif
	}

	func _scanFloat() -> Float? {
#if os(Linux)
		return self.scanFloat()
#else
		if #available(macOS 10.15, *) {
			return self.scanFloat()
		}
		else {
			var value: Float = 0
			if self.scanFloat(&value) {
				return value
			}
			return nil
		}
#endif
	}


	/// Scan an integer
	func _scanInt() -> Int? {
		#if os(Linux)
		return self.scanInt()
		#else
		if #available(macOS 10.15, *) {
			return self.scanInt()
		}
		else {
			var value: Int = 0
			if self.scanInt(&value) {
				return value
			}
			return nil
		}
		#endif
	}

	/// Scan a double value
	func _scanDouble() -> Double? {
		#if os(Linux)
		return self.scanDouble()
		#else
		if #available(macOS 10.15, *) {
			return self.scanDouble()
		}
		else {
			var value: Double = 0
			if self.scanDouble(&value) {
				return value
			}
			return nil
		}
		#endif
	}
}
