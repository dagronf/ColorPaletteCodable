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

public class DataWriter {

	/// Data writer errors
	public enum DataWriterError: Error {
		case unableToEncodeString
	}

	/// The written data
	public private(set) var storage = Data()

	/// The number of bytes written to the storage
	public var count: Int { self.storage.count }

	/// The current write position
	public var writePosition: Int { self.storage.count }
}

public extension DataWriter {
	/// Write a byte to the storage
	/// - Parameter byte: The data to write
	/// - Returns: The number of bytes written
	@discardableResult
	func writeByte(_ byte: UInt8) throws -> Int {
		self.storage.append(byte)
		return 1
	}

	/// Write data
	/// - Parameter data: Data to write
	/// - Returns: The number of bytes written
	@discardableResult
	func writeData(_ data: Data) throws -> Int {
		self.storage.append(data)
		return data.count
	}

	/// Write bytes
	/// - Parameter data: Data to write
	/// - Returns: The number of bytes written
	@discardableResult
	func writeBytes(_ bytes: [UInt8]) throws -> Int {
		self.storage.append(contentsOf: bytes)
		return bytes.count
	}

	/// Write the contents of a raw buffer pointer to the destination
	@discardableResult
	func writeBuffer(_ buffer: UnsafeRawBufferPointer, byteCount: Int) throws -> Int {
		guard byteCount > 0, let buffer = buffer.baseAddress else {
			return 0
		}

		let ptr = buffer.assumingMemoryBound(to: UInt8.self)
		self.storage.append(ptr, count: byteCount)
		return byteCount
	}
}

public extension DataWriter {
	/// Write an integer to the data
	/// - Parameters:
	///   - value: The integer value to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@discardableResult
	func writeInteger<T: FixedWidthInteger>(_ value: T, _ byteOrder: Endianness) throws -> Int {
		// Map the value to the correct endianness...
		let mapped = (byteOrder == .big) ? value.bigEndian : value.littleEndian

		// ... then write out the raw bytes
		return try withUnsafeBytes(of: mapped) { pointer in
			try self.writeBuffer(pointer, byteCount: MemoryLayout<T>.size)
		}
	}

	/// Write an array of integers to the data
	/// - Parameters:
	///   - values: The integer values to write
	///   - byteOrder: The byte order to use when writing out each integer
	/// - Returns: The total number of bytes written
	@discardableResult
	func writeIntegers<T: FixedWidthInteger>(_ values: [T], _ byteOrder: Endianness) throws -> Int {
		try values.reduce(0) { partialResult, value in
			return try partialResult + self.writeInteger(value, byteOrder)
		}
	}
}

public extension DataWriter {
	/// Write an Int8 value
	/// - Parameter value: The value to write
	/// - Returns: The number of bytes written
	@discardableResult
	@inlinable func writeInt8(_ value: Int8) throws -> Int {
		try self.writeInteger(value, .big)
	}

	/// Write an Int16 value
	/// - Parameters:
	///   - value: The value to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@discardableResult
	@inlinable func writeInt16(_ value: Int16, _ byteOrder: Endianness) throws -> Int {
		try self.writeInteger(value, byteOrder)
	}

	/// Write an Int32 value
	/// - Parameters:
	///   - value: The value to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@discardableResult
	@inlinable func writeInt32(_ value: Int32, _ byteOrder: Endianness) throws -> Int {
		try self.writeInteger(value, byteOrder)
	}

	/// Write an Int64 value
	/// - Parameters:
	///   - value: The value to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@discardableResult
	@inlinable func writeInt64(_ value: Int64, _ byteOrder: Endianness) throws -> Int {
		try self.writeInteger(value, byteOrder)
	}
}

public extension DataWriter {
	/// Write an Int8 value
	/// - Parameter value: The value to write
	/// - Returns: The number of bytes written
	@discardableResult
	@inlinable func writeUInt8(_ value: UInt8) throws -> Int {
		try self.writeInteger(value, .big)
	}

	/// Write an Int16 value
	/// - Parameters:
	///   - value: The value to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@discardableResult
	@inlinable func writeUInt16(_ value: UInt16, _ byteOrder: Endianness) throws -> Int {
		try self.writeInteger(value, byteOrder)
	}

	/// Write an Int32 value
	/// - Parameters:
	///   - value: The value to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@discardableResult
	@inlinable func writeUInt32(_ value: UInt32, _ byteOrder: Endianness) throws -> Int {
		try self.writeInteger(value, byteOrder)
	}

	/// Write an Int64 value
	/// - Parameters:
	///   - value: The value to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@discardableResult
	@inlinable func writeUInt64(_ value: UInt64, _ byteOrder: Endianness) throws -> Int {
		try self.writeInteger(value, byteOrder)
	}
}

public extension DataWriter {
	/// Write a float32 value to the storage using the IEEE 754 specification
	/// - Parameters:
	///   - value: The value to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@discardableResult
	@inlinable func writeFloat32(_ value: Float32, _ byteOrder: Endianness) throws -> Int {
		try self.writeInteger(value.bitPattern, byteOrder)
	}

	/// Write a float64 (Double) value to the storage using the IEEE 754 specification
	/// - Parameters:
	///   - value: The value to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@discardableResult
	@inlinable func writeFloat64(_ value: Float64, _ byteOrder: Endianness) throws -> Int {
		return try self.writeInteger(value.bitPattern, byteOrder)
	}
}

public extension DataWriter {
	/// Write a string (not including a terminator) to the storage
	/// - Parameters:
	///   - string: The string
	///   - encoding: The string encoding
	/// - Returns: The number of bytes written to the storage
	@discardableResult
	func writeString(_ string: String, encoding: String.Encoding) throws -> Int {
		guard let data = string.data(using: encoding) else {
			throw DataWriterError.unableToEncodeString
		}
		return try self.writeData(data)
	}

	/// Write a UTF16 string (not including a terminator)
	/// - Parameters:
	///   - string: The string to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@inlinable @discardableResult
	func writeStringUTF16(_ string: String, _ byteOrder: Endianness) throws -> Int {
		try self.writeString(string, encoding: (byteOrder == .big) ? .utf16BigEndian : .utf16LittleEndian)
	}

	/// Write a pascal-style UTF16 string (uint16 length + utf16 characters)
	/// - Parameters:
	///   - string: The string to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@discardableResult
	func writePascalStringUTF16(_ string: String?, _ byteOrder: Endianness) throws -> Int {
		// If the string is empty, write length = 0
		guard let string = string else {
			return try self.writeUInt16(0, byteOrder)
		}

		guard let utf16NameBytes = string.data(using: .utf16LittleEndian) else {
			throw PAL.CommonError.invalidUnicodeFormatString
		}
		// Write the length in characters
		try self.writeUInt16(UInt16(utf16NameBytes.count / 2), byteOrder)

		// string content
		if utf16NameBytes.count > 0 {
			try self.writeData(utf16NameBytes)
		}

		return 2 + utf16NameBytes.count
	}

	/// Write a UTF32 string (not including a terminator)
	/// - Parameters:
	///   - string: The string to write
	///   - byteOrder: The byte order to apply when writing
	/// - Returns: The number of bytes written
	@inlinable @discardableResult
	func writeStringUTF32(_ string: String, _ byteOrder: Endianness) throws -> Int {
		try self.writeString(string, encoding: (byteOrder == .big) ? .utf32BigEndian : .utf32LittleEndian)
	}
}

public extension DataWriter {
	/// Pad the storage to an N byte boundary
	/// - Parameters:
	///   - byteBoundary: The boundary size to use when adding padding bytes
	///   - byte: The padding byte to use, or null if not specified
	/// - Returns: The number of bytes added to pad to the boundary
	@discardableResult
	func padToNByteBoundary(byteBoundary: Int, using byte: UInt8 = 0x00) throws -> Int {
		let amount = self.count % byteBoundary
		if amount == 0 { return 0 }
		let paddingByteCount = byteBoundary - amount
		let data = Array<UInt8>(repeating: byte, count: paddingByteCount)
		return try self.writeBytes(data)
	}

	/// Pad the storage to an four byte boundary
	/// - Parameter byte: The padding byte to use, or null if not specified
	/// - Returns: The number of bytes added to pad to the boundary
	@discardableResult @inlinable
	func padToFourByteBoundary(using byte: UInt8 = 0x00) throws -> Int {
		try self.padToNByteBoundary(byteBoundary: 4, using: byte)
	}

	/// Pad the output to an eight byte boundary
	/// - Parameter byte: The padding byte to use, or null if not specified
	/// - Returns: The number of bytes added to pad to the boundary
	@discardableResult @inlinable
	func padToEightByteBoundary(using byte: UInt8 = 0x00) throws -> Int {
		try self.padToNByteBoundary(byteBoundary: 8, using: byte)
	}
}
