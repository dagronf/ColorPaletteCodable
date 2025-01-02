//
//  Copyright © 2024 Darren Ford. All rights reserved.
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

public class DataParser {
	/// The data
	let storage: Data

	/// The current read position in the data
	private(set) var readPosition: Int = 0

	/// Data parser errors
	public enum DataParserError: Error {
		case invalidOffset
		case endOfData
		case unableToDecodeString
	}

	/// Seek direction
	public enum Seek {
		/// Seek from start
		case start
		/// Seek backwards from end
		case end
		/// Seek from current read position
		case current
	}

	public init(data: Data) {
		self.storage = data
	}

	public init(bytes: [UInt8]) {
		self.storage = Data(bytes)
	}

	/// The number of bytes in the data
	public var count: Int { self.storage.count }

	/// The bytes available to read from the read position
	public var bytesAvailable: Int { self.storage.count - self.readPosition }
}

public extension DataParser {
	/// Rewind the read position back to the start of the data
	func rewind() {
		self.readPosition = 0
	}

	/// Move the read offset from the start of the data
	/// - Parameter offset: The new read offset
	func seekSet(_ offset: Int) throws {
		guard offset >= 0, offset < self.count else {
			throw DataParserError.invalidOffset
		}
		self.readPosition = offset
	}

	/// Move the read offset from the end of the data
	/// - Parameter offset: The distance from the end of the data
	func seekEnd(_ offset: Int) throws {
		guard offset >= 0, offset < self.count else {
			throw DataParserError.invalidOffset
		}
		self.readPosition = self.count - offset
	}

	/// Seek from the current read location
	/// - Parameter offset: The offset to move the read position
	func seek(_ offset: Int) throws {
		guard (0 ..< self.count).contains(self.readPosition + offset) else {
			throw DataParserError.invalidOffset
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

	func hasMoreData() -> Bool { self.readPosition < self.count }
}

public extension DataParser {
	/// Read a byte
	func readByte() throws -> UInt8 {
		guard self.readPosition < self.count else {
			throw DataParserError.endOfData
		}
		defer { self.readPosition += 1 }
		return self.storage[self.readPosition]
	}
}

public extension DataParser {
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

public extension DataParser {
	/// Read data
	/// - Parameter count: The number of bytes to read
	/// - Returns: Data
	func readData(count: Int) throws -> Data {
		guard self.readPosition + count <= self.count else {
			throw DataParserError.endOfData
		}
		defer { self.readPosition += count }
		return self.storage[self.readPosition ..< self.readPosition + count]
	}

	/// Read the remaining data
	/// - Returns: Data
	func readToEndOfData() throws -> Data {
		let count = self.count - self.readPosition - 1
		defer { self.readPosition = self.count }
		return self.storage[self.readPosition ... self.readPosition + count]
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
	func readBytes(count: Int) throws -> Array<UInt8> {
		try Array(self.readData(count: count))
	}
}

public extension DataParser {
	/// Read an integer value from the storage
	/// - Parameter byteOrder: The expected byte order for the integer
	/// - Returns: The integer value
	func readInteger<T: FixedWidthInteger>(_ byteOrder: Endianness) throws -> T {
		let data = try self.readData(count: MemoryLayout<T>.size)
		
#if swift(>=5.7)
		let value = data.withUnsafeBytes { $0.loadUnaligned(as: T.self) }
#else
		let value = data.reversed().reduce(0) { soFar, byte in
			return soFar << 8 | T(byte)
		}
#endif
		return byteOrder == .big ? value.bigEndian : value.littleEndian
	}

	/// Read integers from the storage
	/// - Parameters:
	///   - byteOrder: The expected byte order for each integer
	///   - count: The expected number of integers to read
	/// - Returns: The read integers
	func readIntegers<T: FixedWidthInteger>(_ byteOrder: Endianness, count: Int) throws -> [T] {
		try (0 ..< count).map { _ in
			try self.readInteger(byteOrder)
		}
	}
}

public extension DataParser {
	/// Read an Int16 value from the storage
	/// - Parameter byteOrder: The expected byte order for the integer
	/// - Returns: The integer value
	@inlinable func readInt16(_ byteOrder: Endianness) throws -> Int16 {
		try readInteger(byteOrder)
	}
	/// Read an Int32 value from the storage
	/// - Parameter byteOrder: The expected byte order for the integer
	/// - Returns: The integer value
	@inlinable func readInt32(_ byteOrder: Endianness) throws -> Int32 {
		try readInteger(byteOrder)
	}
	/// Read an Int64 value from the storage
	/// - Parameter byteOrder: The expected byte order for the integer
	/// - Returns: The integer value
	@inlinable func readInt64(_ byteOrder: Endianness) throws -> Int64 {
		try readInteger(byteOrder)
	}
}

extension DataParser {
	/// Read a UInt16 value from the storage
	/// - Parameter byteOrder: The expected byte order for the integer
	/// - Returns: The integer value
	@inlinable func readUInt16(_ byteOrder: Endianness) throws -> UInt16 {
		try readInteger(byteOrder)
	}
	/// Read a UInt32 value from the storage
	/// - Parameter byteOrder: The expected byte order for the integer
	/// - Returns: The integer value
	@inlinable func readUInt32(_ byteOrder: Endianness) throws -> UInt32 {
		try readInteger(byteOrder)
	}
	/// Read a UInt64 value from the storage
	/// - Parameter byteOrder: The expected byte order for the integer
	/// - Returns: The integer value
	@inlinable func readUInt64(_ byteOrder: Endianness) throws -> UInt64 {
		try readInteger(byteOrder)
	}
}

public extension DataParser {
	/// Read a single byte (ascii) string
	/// - Parameter count: The number of characters to read
	/// - Returns: String
	func readAsciiString(count: Int) throws -> String {
		let data = try self.readData(count: count)
		if let str = String(data: data, encoding: .ascii) {
			return str
		}
		throw DataParserError.unableToDecodeString
	}

	func readSingleByteBasedString(count: Int, encoding: String.Encoding) throws -> String {
		let data = try self.readData(count: count)
		if let str = String(data: data, encoding: encoding) {
			return str
		}
		throw DataParserError.unableToDecodeString
	}

	/// Read a UTF16 string with no terminator
	/// - Parameters:
	///   - byteOrder: The endianness for each character in the string
	///   - count: The number of characters
	/// - Returns: String
	func readUTF16String(_ byteOrder: Endianness, count: Int) throws -> String {
		let data = try self.readData(count: count * 2)
		let endian: String.Encoding = (byteOrder == .big) ? .utf16BigEndian : .utf16LittleEndian
		if let str = String(data: data, encoding: endian) {
			return str
		}
		throw DataParserError.unableToDecodeString
	}

	/// Read a utf16-style pascal string (utf16 length + utf16 string)
	///   - byteOrder: The endianness
	/// - Returns: String
	func readPascalStringUTF16(_ byteOrder: Endianness) throws -> String {
		// First two bytes should be a utf16 character count
		let length = try self.readUInt16(byteOrder)
		// Then the raw string bytes
		let stringData = try self.readData(count: Int(length * 2))

		let stringEncoding: String.Encoding = (byteOrder == .big) ? .utf16BigEndian : .utf16LittleEndian
		if let str = String(data: stringData, encoding: stringEncoding) {
			return str
		}
		throw PAL.CommonError.invalidString
	}

	/// Read a UTF32 string with no terminator
	/// - Parameters:
	///   - byteOrder: The endianness for each character in the string
	///   - count: The number of characters
	/// - Returns: String
	func readUTF32String(_ byteOrder: Endianness, count: Int) throws -> String {
		let data = try self.readData(count: count * 4)
		let endian: String.Encoding = (byteOrder == .big) ? .utf32BigEndian : .utf32LittleEndian
		if let str = String(data: data, encoding: endian) {
			return str
		}
		throw DataParserError.unableToDecodeString
	}
}

public extension DataParser {
	/// Read in an IEEE 754 float32 value
	/// - Parameter byteOrder: The endianness of the input value
	/// - Returns: A Float32 value
	///
	/// [IEEE 754 specification](http://ieeexplore.ieee.org/servlet/opac?punumber=4610933)
	func readFloat32(_ byteOrder: Endianness) throws -> Float32 {
		let value: UInt32 = try readInteger(byteOrder)
		return Float32(bitPattern: value)
	}

	/// Read in an IEEE 754 float64 value
	/// - Parameter byteOrder: The endianness of the input value
	/// - Returns: A Float64 value
	///
	/// [IEEE 754 specification](http://ieeexplore.ieee.org/servlet/opac?punumber=4610933)
	@inlinable func readFloat64(_ byteOrder: Endianness) throws -> Float64 {
		let value: UInt64 = try readInteger(byteOrder)
		return Float64(bitPattern: value)
	}
}
