//
//  ASEPaletteCoder.swift
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

/// An ASE file reader, based on [the format defined here](http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase)
public extension PAL.Coder {
	struct ASE: PAL_PaletteCoder {
		public let fileExtension = "ase"
		public init() {}
	}
}

// MARK: - Internal definitions

// ASE file header
private let ASE_HEADER_DATA = Data([65, 83, 69, 70])
// ASE group start tag
private let ASE_GROUP_START: UInt16 = 0xC001
// ASE group end tag
private let ASE_GROUP_END: UInt16 = 0xC002
// ASE color start tag
private let ASE_BLOCK_COLOR: UInt16 = 0x0001

private enum ASEColorType: Int, Codable {
	case global = 0
	case spot = 1
	case normal = 2
	static func from(_ type: PAL.ColorType) -> ASEColorType {
		switch type {
		case .global: return .global
		case .spot: return .spot
		case .normal: return .normal
		}
	}
	
	func asColorType() -> PAL.ColorType {
		switch self {
		case .global: return .global
		case .spot: return .spot
		case .normal: return .normal
		}
	}
}

/// ASE color model representation
private enum ASEColorModel: String {
	case CMYK
	case RGB = "RGB "
	case LAB = "LAB "
	case Gray
	
	internal static func from(_ colorspace: PAL.ColorSpace) -> ASEColorModel {
		switch colorspace {
		case .RGB: return ASEColorModel.RGB
		case .CMYK: return ASEColorModel.CMYK
		case .LAB: return ASEColorModel.LAB
		case .Gray: return ASEColorModel.Gray
		}
	}
}

// MARK: - Load/Save

extension PAL.Coder.ASE {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {
		// NOTE: Assumption here is that `inputStream` is already open
		// If the input stream isn't open, the reading will hang.
		
		var result = PAL.Palette()
		
		// Load and validate the header
		let header = try readData(inputStream, size: 4)
		if header != ASE_HEADER_DATA {
			ASEPaletteLogger.log(.error, "Invalid .ase header")
			throw PAL.CommonError.invalidASEHeader
		}
		
		// Read version (currently not being used for anything)
		let version0: UInt16 = try readIntegerBigEndian(inputStream)
		let version1: UInt16 = try readIntegerBigEndian(inputStream)
		if version0 != 1 || version1 != 0 {
			// Unknown version?
			throw PAL.CommonError.invalidVersion
		}
		
		// Read the number of blocks contained within the ase file
		let numberOfBlocks: UInt32 = try readIntegerBigEndian(inputStream)
		
		// The currently active group. If nil, colors are added to the global group
		var currentGroup: PAL.Group?
		
		// Read in all the blocks
		for _ in 0 ..< numberOfBlocks {
			// The type of block
			let type: UInt16 = try readIntegerBigEndian(inputStream)
			
			// currently not validating the block lengths
			let _: UInt32 = try readIntegerBigEndian(inputStream)
			
			switch type {
			case ASE_GROUP_START:
				guard currentGroup == nil else {
					ASEPaletteLogger.log(.error, "Attempting to open group with a group already open")
					throw PAL.CommonError.groupAlreadyOpen
				}
				currentGroup = try self.readStartGroupBlock(inputStream)
			case ASE_GROUP_END:
				guard let c = currentGroup else {
					ASEPaletteLogger.log(.error, "Attempting to close group without an open group")
					throw PAL.CommonError.groupNotOpen
				}
				try self.readEndGroupBlock(inputStream, currentGroup: c, palette: &result)
				currentGroup = nil
			case ASE_BLOCK_COLOR:
				// Pass group in by reference so we can add to it
				try self.readColor(inputStream, currentGroup: &currentGroup, palette: &result)
			default:
				ASEPaletteLogger.log(.error, "Unknown ase block type")
				throw PAL.CommonError.unknownBlockType
			}
		}
		return result
	}
	
	private func readStartGroupBlock(_ inputStream: InputStream) throws -> PAL.Group {
		// Read in the name
		let stringLen: UInt16 = try readIntegerBigEndian(inputStream)
		let name = try readZeroTerminatedUTF16String(inputStream)
		assert(stringLen == name.count + 1)
		return PAL.Group(name: name)
	}
	
	private func readEndGroupBlock(_ inputStream: InputStream, currentGroup: PAL.Group, palette: inout PAL.Palette) throws {
		palette.groups.append(currentGroup)
	}
	
	private func readColor(_ inputStream: InputStream, currentGroup: inout PAL.Group?, palette: inout PAL.Palette) throws {
		// Read in the name
		let stringLen: UInt16 = try readIntegerBigEndian(inputStream)
		let name = try readZeroTerminatedUTF16String(inputStream)
		guard stringLen == name.count + 1 else {
			ASEPaletteLogger.log(.error, "Invalid color name")
			throw PAL.CommonError.invalidString
		}
		
		let mode = try readAsciiString(inputStream, length: 4)
		guard let colorModel = ASEColorModel(rawValue: mode) else {
			ASEPaletteLogger.log(.error, "Invalid .ase color model %@", mode)
			throw PAL.CommonError.unknownColorMode(mode)
		}
		
		var colors: [Float32] = []
		
		let colorspace: PAL.ColorSpace
		
		switch colorModel {
		case .CMYK:
			colorspace = .CMYK
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
		case .RGB:
			colorspace = .RGB
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
		case .LAB:
			colorspace = .LAB
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
			colors.append(try readFloat32(inputStream))
			
		case .Gray:
			colorspace = .Gray
			colors.append(try readFloat32(inputStream))
		}
		
		let colorTypeValue: UInt16 = try readIntegerBigEndian(inputStream)
		guard let colorType = ASEColorType(rawValue: Int(colorTypeValue)) else {
			ASEPaletteLogger.log(.error, "Invalid color type %@", colorTypeValue)
			throw PAL.CommonError.unknownColorType(Int(colorTypeValue))
		}
		
		let color = try PAL.Color(name: name, colorSpace: colorspace, colorComponents: colors, colorType: colorType.asColorType())
		if let _ = currentGroup {
			currentGroup?.colors.append(color)
		}
		else {
			palette.colors.append(color)
		}
	}
}

extension PAL.Coder.ASE {
	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	public func encode(_ palette: PAL.Palette) throws -> Data {
		var outputData = Data(capacity: 1024)
		
		// Write header
		outputData.append(ASE_HEADER_DATA)
		
		outputData.append(try writeUInt16BigEndian(1))
		outputData.append(try writeUInt16BigEndian(0))
		
		var blocksData = Data(capacity: 1024)
		do {
			var totalBlocks = palette.colors.count + (palette.groups.count * 2) // group-start + group-end
			palette.groups.forEach { totalBlocks += $0.colors.count }
			
			// The total number of blocks (group start/group end/color)
			blocksData.append(try writeUInt32BigEndian(UInt32(totalBlocks)))
			
			// Write the 'global' colors
			for color in palette.colors {
				blocksData.append(try self.writeColorData(color))
			}
			
			// Write the groups
			for group in palette.groups {
				// group header
				blocksData.append(try writeUInt16BigEndian(ASE_GROUP_START))
				
				var groupData = Data(capacity: 1024)
				do {
					// Write the group name
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
				blocksData.append(try writeUInt16BigEndian(ASE_GROUP_END))
				blocksData.append(try writeUInt32BigEndian(0))
			}
		}
		
		outputData.append(blocksData)
		return outputData
	}
	
	func writeColorData(_ color: PAL.Color) throws -> Data {
		var outputData = Data(capacity: 1024)
		
		// Write the color block header
		outputData.append(try writeUInt16BigEndian(ASE_BLOCK_COLOR))
		
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
			let colorModel = ASEColorModel.from(color.colorSpace)
			
			colorData.append(try writeASCII(colorModel.rawValue))
			
			switch color.colorSpace {
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
			let mappedColorType = ASEColorType.from(color.colorType)
			let colorType = UInt16(mappedColorType.rawValue)
			colorData.append(try writeUInt16BigEndian(colorType))
		}
		
		// Write the block length
		outputData.append(try writeUInt32BigEndian(UInt32(colorData.count)))
		// Write the color block data
		outputData.append(colorData)
		
		return outputData
	}
}
