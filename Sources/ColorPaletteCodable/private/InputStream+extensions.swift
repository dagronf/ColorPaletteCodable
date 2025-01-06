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

extension InputStream {
	/// Read all of the remaining data from the stream
	///
	/// NOTE: This stream must have already been opened
	func readAllData() -> Data {
		assert(self.streamStatus == .open)
		var allData = Data(capacity: 1024)
		do {
			let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
			defer { buffer.deallocate() }
			var readCount = -1
			while readCount != 0 {
				readCount = self.read(buffer, maxLength: 1024)
				if readCount > 0 {
					allData += Data(bytes: buffer, count: readCount)
				}
				if self.hasBytesAvailable == false {
					readCount = 0
				}
			}
		}
		return allData
	}
}

/// Create and open an input stream from Data
/// - Parameters:
///   - data: The data
///   - block: The block to call with the opened InputStream
func usingStreamData<T>(_ data: Data, _ block: (InputStream) throws -> T) rethrows -> T {
	let s = InputStream(data: data)
	s.open()
	defer { s.close() }
	return try block(s)
}
