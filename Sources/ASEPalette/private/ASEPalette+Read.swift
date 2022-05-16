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
	mutating func _load(fileURL: URL) throws {
		guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
			ase_log.log(.error, "Unable to load .ase file")
			throw ASE.CommonError.unableToLoadFile
		}
		inputStream.open()
		try self._load(inputStream: inputStream)
	}

	mutating func _load(data: Data) throws {
		let inputStream = InputStream(data: data)
		inputStream.open()
		try self._load(inputStream: inputStream)
	}

	mutating func _load(inputStream: InputStream) throws {
		// NOTE: Assumption here is that `inputStream` is already open
		// If the input stream isn't open, the reading will hang.

		// Remove any existing colors/groups
		global.colors = []
		groups = []

		// Load and validate the header
		let header = try readData(inputStream, size: 4)
		if header != Common.HEADER_DATA {
			ase_log.log(.error, "Invalid .ase header")
			throw ASE.CommonError.invalidASEHeader
		}

		// Read version (currently not being used for anything)
		self.version0 = try readInteger(inputStream)
		self.version1 = try readInteger(inputStream)

		// Read the number of blocks contained within the ase file
		let numberOfBlocks: UInt32 = try readInteger(inputStream)

		// The currently active group. If nil, colors are added to the global group
		var currentGroup: ASE.Group?

		// Read in all the blocks
		for _ in 0 ..< numberOfBlocks {
			// The type of block
			let type: UInt16 = try readInteger(inputStream)

			// currently not validating the block lengths
			let _: UInt32 = try readInteger(inputStream)

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
		let stringLen: UInt16 = try readInteger(inputStream)
		let name = try readZeroTerminatedUTF16String(inputStream)
		assert(stringLen == name.count + 1)
		return ASE.Group(name: name)
	}

	private mutating func readEndGroupBlock(_ inputStream: InputStream, currentGroup: ASE.Group) throws {
		self.groups.append(currentGroup)
	}

	private mutating func readColor(_ inputStream: InputStream, currentGroup: inout ASE.Group?) throws {
		// Read in the name
		let stringLen: UInt16 = try readInteger(inputStream)
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

		let colorTypeValue: UInt16 = try readInteger(inputStream)
		guard let colorType = ASE.ColorType(rawValue: Int(colorTypeValue)) else {
			ase_log.log(.error, "Invalid color type %@", colorTypeValue)
			throw ASE.CommonError.unknownColorType(Int(colorTypeValue))
		}

		let color = try ASE.Color(name: name, model: colorModel, colorComponents: colors, colorType: colorType)
		if let _ = currentGroup {
			currentGroup?.colors.append(color)
		}
		else {
			global.colors.append(color)
		}
	}
}

func readData(_ inputStream: InputStream, size: Int) throws -> Data {
	let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
	var read = 0
	while read != size {
		let newread = inputStream.read(buffer, maxLength: size - read)
		read += newread
	}
	return Data(bytes: buffer, count: read)
}

func readInteger<ValueType: FixedWidthInteger>(_ inputStream: InputStream) throws -> ValueType {
	guard inputStream.hasBytesAvailable else {
		ase_log.log(.error, "Found end of file")
		throw ASE.CommonError.invalidEndOfFile
	}

	let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: MemoryLayout<ValueType>.size)
	inputStream.read(buffer, maxLength: MemoryLayout<ValueType>.size)

	return buffer.withMemoryRebound(to: ValueType.self, capacity: 1) { result in
		let value = result.pointee.bigEndian
		return value
	}
}

// 0-terminated string of length (uint16) double-byte characters
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

// Fixed length of ascii characters
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

func readFloat32(_ inputStream: InputStream) throws -> Float32 {
	guard inputStream.hasBytesAvailable else {
		ase_log.log(.error, "Found end of file")
		throw ASE.CommonError.invalidEndOfFile
	}
	let data = try readData(inputStream, size: 4)
	return Float32(bitPattern: UInt32(bigEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) }))
}
