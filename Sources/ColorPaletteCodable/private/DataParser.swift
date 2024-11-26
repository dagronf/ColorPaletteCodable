//
//  Copyright © 2024 Darren Ford. All rights reserved.
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

enum Endianness {
	case big
	case little
}

enum DataParserError: Error {
	case tooFewBytesAvailableInParser
	case cannotReadString
}

class DataParser {
	let data: Data
	private(set) var readPosition: Int = 0

	/// Seek direction
	enum Seek {
		/// Seek from start
		case start
		/// Seek backwards from end
		case end
		/// Seek from current read position
		case current
	}

	init(data: Data) {
		self.data = data
	}

	/// The number of bytes in the data
	var count: Int { self.data.count }

	/// The bytes available to read from the read position
	var bytesAvailable: Int { self.data.count - self.readPosition }
}

extension DataParser {
	/// Move the read offset from the start of the data
	/// - Parameter offset: The new read offset
	func seekSet(_ offset: Int) throws {
		guard offset >= 0, offset < self.data.count else {
			throw DataParserError.tooFewBytesAvailableInParser
		}
		self.readPosition = offset
	}

	/// Move the read offset from the end of the data
	/// - Parameter offset: The distance from the end of the data
	func seekEnd(_ offset: Int) throws {
		guard offset >= 0, offset < self.data.count else {
			throw DataParserError.tooFewBytesAvailableInParser
		}
		self.readPosition = self.data.count - offset
	}

	/// Seek from the current read location
	/// - Parameter offset: The offset to move the read position
	func seek(_ offset: Int) throws {
		guard (0 ..< self.data.count).contains(self.readPosition + offset) else {
			throw DataParserError.tooFewBytesAvailableInParser
		}
		self.readPosition += offset
	}

	func seek(_ offset: Int, _ direction: Seek) throws {
		switch direction {
		case .start:
			try self.seekSet(offset)
		case .end:
			try self.seekEnd(offset)
		case .current:
			try self.seek(offset)
		}
	}

	func hasMoreData() -> Bool { self.readPosition < self.data.count }
}

extension DataParser {
	/// Read a byte
	func readByte() throws -> UInt8 {
		guard self.readPosition < self.data.count else {
			throw DataParserError.tooFewBytesAvailableInParser
		}
		defer { self.readPosition += 1 }
		return self.data[self.readPosition]
	}
}

extension DataParser {
	/// Read a UInt8 value
	@inlinable func readUInt8() throws -> UInt8 {
		try self.readByte()
	}

	/// Read an Int8 value
	@inlinable func readInt8() throws -> Int8 {
		// Remap the UInt8 value to an Int8 value
		Int8(bitPattern: try self.readByte())
	}

	/// Read a 'bool' value byte from the stream
	///
	/// `0x00` -> `false`, anything else -> `true`
	@inlinable func readBool() throws -> Bool {
		try self.readByte() != 0x00
	}
}

extension DataParser {
	/// Read data
	/// - Parameter count: The number of bytes to read
	/// - Returns: Data
	func readData(count: Int) throws -> Data {
		guard self.readPosition + count <= self.data.count else {
			throw DataParserError.tooFewBytesAvailableInParser
		}
		defer { self.readPosition += count }
		return self.data[self.readPosition ..< self.readPosition + count]
	}

	/// Read the remaining data
	/// - Returns: Data
	func readToEndOfData() throws -> Data {
		let count = self.data.count - self.readPosition - 1
		defer { self.readPosition = self.data.count }
		return data[self.readPosition ... self.readPosition + count]
	}

	/// Read up to (not including) the next instance of a byte value
	/// - Parameter byte: The byte to check for
	/// - Returns: Data
	func readData(upToNextInstanceOf byte: UInt8) throws -> Data {
		var data = Data()
		while self.hasMoreData() {
			let read = try self.readByte()
			if read == byte {
				return data
			}
			data.append(read)
		}
		return data
	}

	/// Read an array of bytes from the data
	/// - Parameter count: The number of bytes to read
	/// - Returns: An array of bytes
	@inlinable
	func readArray(count: Int) throws -> Array<UInt8> {
		try Array(self.readData(count: count))
	}
}

extension DataParser {
	func readInteger<T: FixedWidthInteger>(_ endianness: Endianness) throws -> T {
		let data = try self.readData(count: MemoryLayout<T>.size)
		let value = data.withUnsafeBytes { $0.loadUnaligned(as: T.self) }
		return endianness == .big ? value.bigEndian : value.littleEndian
	}
}

extension Data {
	func appending(_ content: UInt8) -> Data {
		var d = self
		d.append(content)
		return d
	}

	func appending(_ content: [UInt8]) -> Data {
		var d = self
		d.append(contentsOf: content)
		return d
	}

	func appending(_ content: Data) -> Data {
		var d = self
		d.append(content)
		return d
	}
}

extension DataParser {
	/// Read a single byte (ascii) string
	/// - Parameter count: The number of characters to read
	/// - Returns: String
	func readAsciiString(count: Int) throws -> String {
		let data = try self.readData(count: count)
		if let str = String(data: data, encoding: .ascii) {
			return str
		}
		throw DataParserError.cannotReadString
	}

	/// Read a UTF16 string with no terminator
	/// - Parameters:
	///   - endianness: The endianness for each character in the string
	///   - count: The expected number of characters
	/// - Returns: String
	func readUTF16String(_ endianness: Endianness, count: Int) throws -> String {
		let data = try self.readData(count: count * 2)
		let endian: String.Encoding = (endianness == .big) ? .utf16BigEndian : .utf16LittleEndian
		if let str = String(data: data, encoding: endian) {
			return str
		}
		throw DataParserError.cannotReadString
	}

	/// Read a UTF32 string with no terminator
	/// - Parameters:
	///   - endianness: The endianness for each character in the string
	///   - count: The expected number of characters
	/// - Returns: String
	func readUTF32String(_ endianness: Endianness, count: Int) throws -> String {
		let data = try self.readData(count: count * 4)
		let endian: String.Encoding = (endianness == .big) ? .utf32BigEndian : .utf32LittleEndian
		if let str = String(data: data, encoding: endian) {
			return str
		}
		throw DataParserError.cannotReadString
	}
}

extension DataParser {
	/// Read in an IEEE 754 float32 value
	/// - Parameter byteOrder: The endianness of the input value
	/// - Returns: A Float32 value
	///
	/// [IEEE 754 specification](http://ieeexplore.ieee.org/servlet/opac?punumber=4610933)
	func readFloat32(_ endianness: Endianness) throws -> Float32 {
		let value: UInt32 = try readInteger(endianness)
		return Float32(bitPattern: value)
	}

	/// Read in an IEEE 754 float64 value
	/// - Parameter byteOrder: The endianness of the input value
	/// - Returns: A Float64 value
	///
	/// [IEEE 754 specification](http://ieeexplore.ieee.org/servlet/opac?punumber=4610933)
	@inlinable func readFloat64(_ endianness: Endianness) throws -> Float64 {
		let value: UInt64 = try readInteger(endianness)
		return Float64(bitPattern: value)
	}
}
