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

// MARK: Warning wrappers

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

	/// Scan for an integer within the expected range of values
	func _scanInt(in expectedRange: ClosedRange<Int>) -> Int? {
		if let value = self._scanInt(), expectedRange.contains(value) {
			return value
		}
		return nil
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

	/// Scan for a double value within the expected range of values
	func _scanDouble(in expectedRange: ClosedRange<Double>) -> Double? {
		if let value = self._scanDouble(), expectedRange.contains(value) {
			return value
		}
		return nil
	}
}

// MARK: - Tagging and rewinding

internal extension Scanner {

	#if os(macOS)
	typealias LocationType = Int
	#else
	typealias LocationType = String.Index
	#endif

	/// A location within current scanner
	struct Location {
		fileprivate let index: LocationType
		fileprivate init(index: LocationType) {
			self.index = index
		}
	}

	func tagLocation() -> Location {
		#if os(macOS)
		return Location(index: self.scanLocation)
		#else
		return Location(index: self.currentIndex)
		#endif
	}

	func resetLocation(_ loc: Location) {
		#if os(macOS)
		self.scanLocation = loc.index
		#else
		self.currentIndex = loc.index
		#endif
	}
}
