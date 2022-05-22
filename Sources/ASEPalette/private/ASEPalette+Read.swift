//
//  ASEPalette+Read.swift
//
//  Created by Darren Ford on 16/5/2022.
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

internal extension ASE.Palette {
	/// Load a palette from a .ase palette file
	///
	/// Implementation based on the breakdown from [here](http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase)
	mutating func _load(fileURL: URL) throws {
		guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
			ase_log.log(.error, "Unable to load .ase file")
			throw ASE.CommonError.unableToLoadFile
		}
		inputStream.open()
		try self._load(inputStream: inputStream)
	}

	/// Load from data
	///
	/// Implementation based on the breakdown from [here](http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase)
	mutating func _load(data: Data) throws {
		let inputStream = InputStream(data: data)
		inputStream.open()
		try self._load(inputStream: inputStream)
	}

	/// Load from an InputStream
	///
	/// Implementation based on the breakdown from [here](http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase)
	mutating func _load(inputStream: InputStream) throws {
		// NOTE: Assumption here is that `inputStream` is already open
		// If the input stream isn't open, the reading will hang.

		// Remove any existing colors/groups
		self.colors = []
		self.groups = []

		// Load and validate the header
		let header = try readData(inputStream, size: 4)
		if header != Common.HEADER_DATA {
			ase_log.log(.error, "Invalid .ase header")
			throw ASE.CommonError.invalidASEHeader
		}

		// Read version (currently not being used for anything)
		self.version0 = try readIntegerBigEndian(inputStream)
		self.version1 = try readIntegerBigEndian(inputStream)

		// Read the number of blocks contained within the ase file
		let numberOfBlocks: UInt32 = try readIntegerBigEndian(inputStream)

		// The currently active group. If nil, colors are added to the global group
		var currentGroup: ASE.Group?

		// Read in all the blocks
		for _ in 0 ..< numberOfBlocks {
			// The type of block
			let type: UInt16 = try readIntegerBigEndian(inputStream)

			// currently not validating the block lengths
			let _: UInt32 = try readIntegerBigEndian(inputStream)

			switch type {
			case Common.GROUP_START:
				guard currentGroup == nil else {
					ase_log.log(.error, "Attempting to open group with a group already open")
					throw ASE.CommonError.groupAlreadyOpen
				}
				currentGroup = try self.readStartGroupBlock(inputStream)
			case Common.GROUP_END:
				guard let c = currentGroup else {
					ase_log.log(.error, "Attempting to close group without an open group")
					throw ASE.CommonError.groupNotOpen
				}
				try self.readEndGroupBlock(inputStream, currentGroup: c)
				currentGroup = nil
			case Common.BLOCK_COLOR:
				// Pass group in by reference so we can add to it
				try self.readColor(inputStream, currentGroup: &currentGroup)
			default:
				ase_log.log(.error, "Unknown ase block type")
				throw ASE.CommonError.unknownBlockType
			}
		}
	}

	private mutating func readStartGroupBlock(_ inputStream: InputStream) throws -> ASE.Group {
		// Read in the name
		let stringLen: UInt16 = try readIntegerBigEndian(inputStream)
		let name = try readZeroTerminatedUTF16String(inputStream)
		assert(stringLen == name.count + 1)
		return ASE.Group(name: name)
	}

	private mutating func readEndGroupBlock(_ inputStream: InputStream, currentGroup: ASE.Group) throws {
		self.groups.append(currentGroup)
	}

	private mutating func readColor(_ inputStream: InputStream, currentGroup: inout ASE.Group?) throws {
		// Read in the name
		let stringLen: UInt16 = try readIntegerBigEndian(inputStream)
		let name = try readZeroTerminatedUTF16String(inputStream)
		guard stringLen == name.count + 1 else {
			ase_log.log(.error, "Invalid color name")
			throw ASE.CommonError.invalidString
		}

		let mode = try readAsciiString(inputStream, length: 4)
		guard let colorModel = ASE.ColorModel(rawValue: mode) else {
			ase_log.log(.error, "Invalid .ase color model %@", mode)
			throw ASE.CommonError.unknownColorMode(mode)
		}

		var colors: [Float32] = []

		switch colorModel {
		case .CMYK:
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
		case .RGB, .LAB:
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
		case .Gray:
			colors.append(try readFloat32(inputStream))
		}

		let colorTypeValue: UInt16 = try readIntegerBigEndian(inputStream)
		guard let colorType = ASE.ColorType(rawValue: Int(colorTypeValue)) else {
			ase_log.log(.error, "Invalid color type %@", colorTypeValue)
			throw ASE.CommonError.unknownColorType(Int(colorTypeValue))
		}

		let color = try ASE.Color(name: name, model: colorModel, colorComponents: colors, colorType: colorType)
		if let _ = currentGroup {
			currentGroup?.colors.append(color)
		}
		else {
			self.colors.append(color)
		}
	}
}

// MARK: - Read utilities

// Read raw UInt8 bytes from the input stream
internal func readData(_ inputStream: InputStream, size: Int) throws -> Data {
	if inputStream.hasBytesAvailable == false {
		ase_log.log(.error, "Found end of file")
		throw ASE.CommonError.invalidEndOfFile
	}

	// Create a temporary buffer in which to store read bytes
	let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
	defer { buffer.deallocate() }

	var result = Data()

	// Loop until we've read all the required data
	var read = 0
	while read != size {
		let readCount = inputStream.read(buffer, maxLength: size - read)
		if readCount == 0 && !inputStream.hasBytesAvailable {
			// If we haven't read anything and there's no more data to read,
			// then we're at the end of file
			throw ASE.CommonError.invalidEndOfFile
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
func readIntegerBigEndian<ValueType: FixedWidthInteger>(_ inputStream: InputStream) throws -> ValueType {
	let rawData = try readData(inputStream, size: MemoryLayout<ValueType>.size)
	guard let result = rawData.parseBigEndian(type: ValueType.self) else {
		throw ASE.CommonError.invalidIntegerValue
	}
	return result
}

// Read a 0-terminated string of uint16 double-byte characters
func readZeroTerminatedUTF16String(_ inputStream: InputStream) throws -> String {
	guard inputStream.hasBytesAvailable else {
		ase_log.log(.error, "Found end of file")
		throw ASE.CommonError.invalidEndOfFile
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

func readPascalStyleUnicodeString(_ inputStream: InputStream) throws -> String {
	// https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#UnicodeStringDefine
	// A 4-byte length field, representing the number of UTF-16 code units in the string (not bytes).
	// The string of Unicode values, two bytes per character and a two byte null for the end of the string.
	let length: UInt32 = try readIntegerBigEndian(inputStream)

	var data = Data()
	try (0 ..< length).forEach { index in
		let ch: Data = try readData(inputStream, size: 2)

		if index == length - 1 && ch != Common.DataTwoZeros {
			throw ASE.CommonError.invalidUnicodeFormatString
		}
		data.append(ch)
	}
	return String(data: data.dropLast(), encoding: .utf16BigEndian) ?? ""
}

// Fixed length of ascii (single byte) characters
func readAsciiString(_ inputStream: InputStream, length: Int) throws -> String {
	guard inputStream.hasBytesAvailable else {
		ase_log.log(.error, "Found end of file")
		throw ASE.CommonError.invalidEndOfFile
	}

	let strData = try readData(inputStream, size: length)
	if strData.count != length {
		fatalError()
	}
	return String(data: strData, encoding: .ascii) ?? ""
}

// Read in a float32 value (IEEE 754 specification)
func readFloat32(_ inputStream: InputStream) throws -> Float32 {
	let rawValue: UInt32 = try readIntegerBigEndian(inputStream)
	return Float32(bitPattern: rawValue)
}
