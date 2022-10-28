//
//  ReadHelpers.swift
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

import Foundation

// MARK: - Read utilities

// Read raw UInt8 bytes from the input stream
internal func readData(_ inputStream: InputStream, size: Int) throws -> Data {
	if inputStream.hasBytesAvailable == false {
		ASEPaletteLogger.log(.error, "Found end of file")
		throw PAL.CommonError.invalidEndOfFile
	}

	// Create a temporary buffer in which to store read bytes
	let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
	defer { buffer.deallocate() }

	var result = Data()

	// Loop until we've read all the required data
	var read = 0
	while read != size {
		let readCount = inputStream.read(buffer, maxLength: size - read)
		if readCount == 0, !inputStream.hasBytesAvailable {
			// If we haven't read anything and there's no more data to read,
			// then we're at the end of file
			throw PAL.CommonError.invalidEndOfFile
		}

		if readCount > 0 {
			// Add the read data to the result
			result += Data(bytes: buffer, count: readCount)

			// Move the read header forward
			read += readCount
		}
	}
	return result
}

// Read a big-endian integer value from the input stream
internal func readIntegerBigEndian<ValueType: FixedWidthInteger>(_ inputStream: InputStream) throws -> ValueType {
	let rawData = try readData(inputStream, size: MemoryLayout<ValueType>.size)
	guard let result = rawData.parseBigEndian(type: ValueType.self) else {
		throw PAL.CommonError.invalidIntegerValue
	}
	return result
}

// Read a 0-terminated string of uint16 double-byte characters
internal func readZeroTerminatedUTF16String(_ inputStream: InputStream) throws -> String {
	guard inputStream.hasBytesAvailable else {
		ASEPaletteLogger.log(.error, "Found end of file")
		throw PAL.CommonError.invalidEndOfFile
	}

	var stillReading = true
	var data = Data()
	while stillReading {
		let ch: Data = try readData(inputStream, size: 2)
		if ch == Common.DataTwoZeros {
			// found the end of the string
			stillReading = false
		}
		else {
			data.append(contentsOf: ch)
		}
	}
	return String(data: data, encoding: .utf16BigEndian) ?? ""
}

internal func readPascalStyleUnicodeString(_ inputStream: InputStream) throws -> String {
	// https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#UnicodeStringDefine
	// A 4-byte length field, representing the number of UTF-16 code units in the string (not bytes).
	// The string of Unicode values, two bytes per character and a two byte null for the end of the string.
	let length: UInt32 = try readIntegerBigEndian(inputStream)

	var data = Data()
	try (0 ..< length).forEach { index in
		let ch: Data = try readData(inputStream, size: 2)

		if index == length - 1, ch != Common.DataTwoZeros {
			throw PAL.CommonError.invalidUnicodeFormatString
		}
		data.append(ch)
	}
	return String(data: data.dropLast(), encoding: .utf16BigEndian) ?? ""
}

// Fixed length of ascii (single byte) characters
internal func readAsciiString(_ inputStream: InputStream, length: Int) throws -> String {
	guard inputStream.hasBytesAvailable else {
		ASEPaletteLogger.log(.error, "Found end of file")
		throw PAL.CommonError.invalidEndOfFile
	}

	let strData = try readData(inputStream, size: length)
	if strData.count != length {
		fatalError()
	}
	return String(data: strData, encoding: .ascii) ?? ""
}

// Read in a float32 value (IEEE 754 specification)
internal func readFloat32(_ inputStream: InputStream) throws -> Float32 {
	let rawValue: UInt32 = try readIntegerBigEndian(inputStream)
	return Float32(bitPattern: rawValue)
}
