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

extension Sequence where Element: Equatable {
	/// Return the unique elements in the array using Equatable as the predicate
	///
	/// Guaranteed to return the same ordering as per the original sequence
	@inlinable var unique: [Element] {
		return self.reduce(into: []) { uniqueElements, element in
			if !uniqueElements.contains(element) {
				uniqueElements.append(element)
			}
		}
	}
}

internal extension Data {
	// Parse a big-endian value from a block of data
	func parseBigEndian<T: FixedWidthInteger>(type: T.Type) -> T? {
		let typeSize = MemoryLayout<T>.size
		guard self.count >= typeSize else { return nil }
		return self.prefix(typeSize).reduce(0) { $0 << 8 | T($1) }
	}

	// Parse a little-endian value from a block of data
	func parseLittleEndian<T: FixedWidthInteger>(type: T.Type) -> T? {
		let typeSize = MemoryLayout<T>.size
		guard self.count >= typeSize else { return nil }
		return self.prefix(typeSize).reversed().reduce(0) { $0 << 8 | T($1) }
	}
}

extension ExpressibleByIntegerLiteral where Self: Comparable {
	@inlinable func clamped(to range: ClosedRange<Self>) -> Self {
		min(range.upperBound, max(range.lowerBound, self))
	}
	@inlinable func unitClamped() -> Self {
		min(1, max(0, self))
	}
}

extension String {
	func ifEmptyDefault(_ isEmpty: String) -> String {
		self.isEmpty ? isEmpty : self
	}
}

@inlinable func unwrapping<T, R>(_ item: T?, _ block: (T) -> R?) -> R? {
	guard let item = item else { return nil }
	return block(item)
}

@inlinable func unwrapping<T, U, R>(_ item1: T?, _ item2: U?, _ block: (T, U) -> R?) -> R? {
	guard let item1 = item1, let item2 = item2 else { return nil }
	return block(item1, item2)
}

extension Optional {
	@inlinable func unwrapping<R>(_ block: (Wrapped) -> R?) -> R? {
		guard let u = self else { return nil }
		return block(u)
	}
}

func withTemporaryFile<ReturnType>(_ fileExtension: String? = nil, _ block: (URL) throws -> ReturnType) throws -> ReturnType {
	// unique name
	var tempFilename = ProcessInfo.processInfo.globallyUniqueString

	// extension
	if let fileExtension = fileExtension {
		tempFilename += "." + fileExtension
	}

	// create the temporary file url
	let tempURL = try FileManager.default.url(
		for: .itemReplacementDirectory,
		in: .userDomainMask,
		appropriateFor: URL(fileURLWithPath: NSTemporaryDirectory()),
		create: true
	)
	.appendingPathComponent(tempFilename)
	return try block(tempURL)
}

func withDataWrittenToTemporaryFile<T>(_ data: Data, fileExtension: String? = nil, _ block: (URL) throws -> T?) throws -> T? {
	return try withTemporaryFile(fileExtension, { tempURL in
		#if os(Linux) || os(Windows)
		try data.write(to: tempURL)
		#else
		try data.write(to: tempURL, options: .atomicWrite)
		#endif
		defer { try? FileManager.default.removeItem(at: tempURL) }
		return try block(tempURL)
	})
}

extension Data {
	/// Attempt to determine the string encoding contained within the data. Returns nil if encoding cannot be inferred
	var stringEncoding: String.Encoding? {
#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
		var nsString: NSString?
		guard
			case let rawValue = NSString.stringEncoding(
				for: self,
				encodingOptions: nil,
				convertedString: &nsString,
				usedLossyConversion: nil
			),
			rawValue != 0
		else {
			return nil
		}
		return .init(rawValue: rawValue)
#else
		return nil
#endif
	}
}

extension BinaryFloatingPoint {
	/// An equality check with a precision accuracy
	/// - Parameters:
	///   - value: The value to compare
	///   - precision: The precision (accuracy) in decimal places (eg. 8 == 8 decimal places)
	/// - Returns: True if mostly equal, false otherwise
	func isEqual(to value: Self, precision: UInt) -> Bool {
		let s = abs(self - value)
		let p = Self(pow(10, -Double(precision)))
		return s < p
	}
}
