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
import BytesParser



extension BytesReader {
	/// Read a wide pascal-style string (length + stringdata). Does NOT include NULL terminators
	/// - Parameter byteOrder: The expected byte ordering
	/// - Returns: The string
	func readPascalStringUTF16(_ byteOrder: BytesParser.Endianness) throws -> String {
		// First two bytes should be a utf16 character count
		let length = try self.readUInt16(byteOrder)
		guard length > 0 else { return "" }

		// Then the raw string bytes
		let stringData = try self.readData(count: Int(length * 2))

		let stringEncoding: String.Encoding = (byteOrder == .big) ? .utf16BigEndian : .utf16LittleEndian
		if let str = String(data: stringData, encoding: stringEncoding) {
			return str
		}
		throw PAL.CommonError.invalidString
	}
}

extension BytesWriter {
	/// Write a pascal style string to the writer. Does NOT include NULL terminators
	/// - Parameters:
	///   - string: The string to write
	///   - byteOrder: The byte ordering
	/// - Returns: The number of bytes written
	@discardableResult
	func writePascalStringUTF16(_ string: String?, _ byteOrder: BytesParser.Endianness) throws -> Int {
		// If the string is empty, write length = 0
		guard let string = string else {
			return try self.writeUInt16(0, byteOrder)
		}
		guard let utf16NameBytes = string.data(
			using: (byteOrder == .big) ? .utf16BigEndian : .utf16LittleEndian,
			allowLossyConversion: false
		) else {
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
}

// MARK: - Adobe helpers

extension BytesReader {
	/// Read an Adobe-style pascal string from the data
	/// - Returns: The string
	///
	/// See: [Adobe String Format](https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#UnicodeStringDefine)
	///
	/// * A 4-byte length field, representing the number of UTF-16 code units in the string (not bytes).
	/// * The string of Unicode values, two bytes per character
	/// * A two byte null for the end of the string.
	internal func readAdobePascalStyleString() throws -> String {
		let length: UInt32 = try self.readUInt32(.big)
		var data = Data()
		try (0 ..< length).forEach { index in
			let ch: Data = try self.readData(count: 2)
			data.append(ch)
		}

		if data.last == 0x00 {
			data = data.dropLast()
		}
		return String(data: data, encoding: .utf16BigEndian) ?? ""
	}
}

extension BytesWriter {
	/// Write a string to the output, using Adobe's pascal-style formatting
	/// - Parameter string: The string to write
	///
	/// See: [Adobe String Format](https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#UnicodeStringDefine)
	///
	/// * A 4-byte length field, representing the number of UTF-16 code units in the string (not bytes).
	/// * The string of Unicode values, two bytes per character
	/// * A two byte null for the end of the string.
	func writeAdobePascalStyleString(_ string: String) throws {
		guard let stringData = string.data(using: .utf16BigEndian) else {
			throw PAL.CommonError.invalidString
		}

		// +1 for the terminator
		try self.writeUInt32(UInt32(string.count + 1), .big)
		if stringData.count > 0 {
			try self.writeData(stringData)
		}
		try self.writeData(Common.DataTwoZeros)
	}
}
