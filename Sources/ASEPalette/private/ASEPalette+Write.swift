//
//  ASEPalette+Write.swift
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

extension ASE.Palette {
	/// Return a Data representation of the ASEPalette in .ase format
	///
	/// http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase
	func _data() throws -> Data {
		var outputData = Data(capacity: 1024)

		// Write header
		outputData.append(Common.HEADER_DATA)

		outputData.append(try writeUInt16BigEndian(self.version0))
		outputData.append(try writeUInt16BigEndian(self.version1))

		var blocksData = Data(capacity: 1024)
		do {
			var totalBlocks = self.global.colors.count + (self.groups.count * 2) // group-start + group-end
			self.groups.forEach { totalBlocks += $0.colors.count }

			// The total number of blocks (group start/group end/color)
			blocksData.append(try writeUInt32BigEndian(UInt32(totalBlocks)))

			// Write the 'global' colors
			for color in global.colors {
				blocksData.append(try self.writeColorData(color))
			}

			// Write the groups
			for group in groups {
				// group header
				blocksData.append(try writeUInt16BigEndian(Common.GROUP_START))

				var groupData = Data(capacity: 1024)
				do {
					// Write the name
					let groupName = group.name.data(using: .utf16BigEndian)!
					let groupNameLen = UInt16(group.name.count + 1)
					// Length of the name + zero terminator
					groupData.append(try writeUInt16BigEndian(groupNameLen))
					groupData.append(groupName)
					groupData.append(Common.DataTwoZeros)
				}

				// Write the group data length (the number of bytes between this block tag and the next
				blocksData.append(try writeUInt32BigEndian(UInt32(groupData.count)))
				// And the group data
				blocksData.append(groupData)

				for color in group.colors {
					blocksData.append(try self.writeColorData(color))
				}

				// group footer
				blocksData.append(try writeUInt16BigEndian(Common.GROUP_END))
				blocksData.append(try writeUInt32BigEndian(0))
			}
		}

		outputData.append(blocksData)
		return outputData
	}
}

internal extension ASE.Palette {
	func writeColorData(_ color: ASE.Color) throws -> Data {
		var outputData = Data(capacity: 1024)

		// Write the color block header
		outputData.append(try writeUInt16BigEndian(Common.BLOCK_COLOR))

		// Generate the color data
		var colorData = Data(capacity: 1024)
		do {
			// Write the name
			let colorName = color.name.data(using: .utf16BigEndian)!
			let colorNameLen = UInt16(color.name.count + 1)
			// Length of the name + zero terminator
			colorData.append(try writeUInt16BigEndian(colorNameLen))
			colorData.append(colorName)
			colorData.append(Common.DataTwoZeros)

			/// Write the model
			colorData.append(try writeASCII(color.model.rawValue))

			switch color.model {
			case .CMYK:
				colorData.append(try writeFloat32(color.colorComponents[0]))
				colorData.append(try writeFloat32(color.colorComponents[1]))
				colorData.append(try writeFloat32(color.colorComponents[2]))
				colorData.append(try writeFloat32(color.colorComponents[3]))
			case .RGB, .LAB:
				colorData.append(try writeFloat32(color.colorComponents[0]))
				colorData.append(try writeFloat32(color.colorComponents[1]))
				colorData.append(try writeFloat32(color.colorComponents[2]))
			case .Gray:
				colorData.append(try writeFloat32(color.colorComponents[0]))
			}

			// Write the color type
			let colorType = UInt16(color.colorType.rawValue)
			colorData.append(try writeUInt16BigEndian(colorType))
		}

		// Write the block length
		outputData.append(try writeUInt32BigEndian(UInt32(colorData.count)))
		// Write the color block data
		outputData.append(colorData)

		return outputData
	}
}

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
