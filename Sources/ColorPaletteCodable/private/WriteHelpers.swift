//
//  WriteHelpers.swift
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

// Write a big-endian uint16 to data
internal func writeUInt16BigEndian(_ value: UInt16) throws -> Data {
	return withUnsafeBytes(of: value.bigEndian) { Data($0) }
}

// Write a big-endian uint32 to data
internal func writeUInt32BigEndian(_ value: UInt32) throws -> Data {
	return withUnsafeBytes(of: value.bigEndian) { Data($0) }
}

// Write ascii characters (byte chars) to data
internal func writeASCII(_ string: String) throws -> Data {
	return string.data(using: .ascii)!
}

// Write a float32 value to data using the IEEE 754 specification
internal func writeFloat32(_ value: Float32) throws -> Data {
	return try writeUInt32BigEndian(value.bitPattern)
}

internal func writePascalStyleUnicodeString(_ string: String) throws -> Data {
	// https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#UnicodeStringDefine
	// A 4-byte length field, representing the number of UTF-16 code units in the string (not bytes).
	// The string of Unicode values, two bytes per character and a two byte null for the end of the string.

	var outputData = Data(capacity: 1024)
	let colorName = string.data(using: .utf16BigEndian)!

	// +1 for the terminator
	outputData.append(try writeUInt32BigEndian(UInt32(string.count + 1)))
	outputData.append(colorName)
	outputData.append(Common.DataTwoZeros)

	return outputData
}
