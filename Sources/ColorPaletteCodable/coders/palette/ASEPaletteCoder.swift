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

/// An ASE file reader, based on [the format defined here](http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase)
public extension PAL.Coder {
	struct ASE: PAL_PaletteCoder {
		public let name = "Adobe Swatch Exchange"
		public let fileExtension = ["ase"]
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
		let reader = BytesReader(inputStream: inputStream)
		var result = PAL.Palette()
		
		// Load and validate the header
		let header = try reader.readData(count: 4)
		if header != ASE_HEADER_DATA {
			ColorPaletteLogger.log(.error, "Invalid .ase header")
			throw PAL.CommonError.invalidASEHeader
		}
		
		// Read version (currently not being used for anything)
		let version0: UInt16 = try reader.readUInt16(.big)
		let version1: UInt16 = try reader.readUInt16(.big)
		if version0 != 1 || version1 != 0 {
			// Unknown version?
			//throw PAL.CommonError.invalidVersion
			ColorPaletteLogger.log(.error, "ASECoder: Untested ASE version %d.%d - attempting load...", version0, version1)
		}
		
		// Read the number of blocks contained within the ase file
		let numberOfBlocks: UInt32 = try reader.readUInt32(.big)

		// The currently active group. If nil, colors are added to the global group
		var currentGroup: PAL.Group?
		
		// Read in all the blocks
		for _ in 0 ..< numberOfBlocks {
			// The type of block
			let type: UInt16 = try reader.readUInt16(.big)

			// currently not validating the block lengths
			let _: UInt32 = try reader.readUInt32(.big)

			switch type {
			case ASE_GROUP_START:
				guard currentGroup == nil else {
					ColorPaletteLogger.log(.error, "Attempting to open group with a group already open")
					throw PAL.CommonError.groupAlreadyOpen
				}
				currentGroup = try self.readStartGroupBlock(reader)
			case ASE_GROUP_END:
				guard let c = currentGroup else {
					ColorPaletteLogger.log(.error, "Attempting to close group without an open group")
					throw PAL.CommonError.groupNotOpen
				}
				try self.readEndGroupBlock(inputStream, currentGroup: c, palette: &result)
				currentGroup = nil
			case ASE_BLOCK_COLOR:
				// Pass group in by reference so we can add to it
				try self.readColor(reader, currentGroup: &currentGroup, palette: &result)
			default:
				ColorPaletteLogger.log(.error, "Unknown ase block type")
				throw PAL.CommonError.unknownBlockType
			}
		}
		return result
	}
	
	private func readStartGroupBlock(_ reader: BytesReader) throws -> PAL.Group {
		// Read in the name
		let stringLen: UInt16 = try reader.readUInt16(.big)
		let name = try reader.readStringUTF16NullTerminated(.big)
		assert(stringLen == name.count + 1)
		return PAL.Group(name: name)
	}
	
	private func readEndGroupBlock(_ inputStream: InputStream, currentGroup: PAL.Group, palette: inout PAL.Palette) throws {
		palette.groups.append(currentGroup)
	}
	
	private func readColor(_ reader: BytesReader, currentGroup: inout PAL.Group?, palette: inout PAL.Palette) throws {
		// Read in the name
		let stringLen: UInt16 = try reader.readUInt16(.big)
		let name = try reader.readStringUTF16NullTerminated(.big)
		guard stringLen == name.count + 1 else {
			ColorPaletteLogger.log(.error, "Invalid color name")
			throw PAL.CommonError.invalidString
		}
		
		let mode = try reader.readStringASCII(length: 4)
		guard let colorModel = ASEColorModel(rawValue: mode) else {
			ColorPaletteLogger.log(.error, "Invalid .ase color model %@", mode)
			throw PAL.CommonError.unknownColorMode(mode)
		}
		
		var colors: [Float32] = []
		
		let colorspace: PAL.ColorSpace
		
		switch colorModel {
		case .CMYK:
			colorspace = .CMYK
			colors.append(try reader.readFloat32(.big))
			colors.append(try reader.readFloat32(.big))
			colors.append(try reader.readFloat32(.big))
			colors.append(try reader.readFloat32(.big))
		case .RGB:
			colorspace = .RGB
			colors.append(try reader.readFloat32(.big))
			colors.append(try reader.readFloat32(.big))
			colors.append(try reader.readFloat32(.big))
		case .LAB:
			colorspace = .LAB
			colors.append(try reader.readFloat32(.big))
			colors.append(try reader.readFloat32(.big))
			colors.append(try reader.readFloat32(.big))

		case .Gray:
			colorspace = .Gray
			colors.append(try reader.readFloat32(.big))
		}
		
		let colorTypeValue: UInt16 = try reader.readUInt16(.big)
		guard let colorType = ASEColorType(rawValue: Int(colorTypeValue)) else {
			ColorPaletteLogger.log(.error, "Invalid color type %@", colorTypeValue)
			throw PAL.CommonError.unknownColorType(Int(colorTypeValue))
		}
		
		let color = try PAL.Color(
			colorSpace: colorspace,
			colorComponents: colors.map { Double($0) },
			name: name,
			colorType: colorType.asColorType()
		)
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
		let writer = try BytesWriter()

		// Write header
		try writer.writeData(ASE_HEADER_DATA)
		try writer.writeUInt16(1, .big)
		try writer.writeUInt16(0, .big)

		do {
			var totalBlocks = palette.colors.count + (palette.groups.count * 2) // group-start + group-end
			palette.groups.forEach { totalBlocks += $0.colors.count }
			
			// The total number of blocks (group start/group end/color)
			try writer.writeUInt32(UInt32(totalBlocks), .big)

			// Write the 'global' colors
			for color in palette.colors {
				try self.writeColorData(writer, color)
			}
			
			// Write the groups
			for group in palette.groups {
				// group header
				try writer.writeUInt16(ASE_GROUP_START, .big)

				let groupWriter = try BytesWriter()
				do {
					// Write the group name
					let groupName = group.name.data(using: .utf16BigEndian)!
					let groupNameLen = UInt16(group.name.count + 1)
					// Length of the name + zero terminator
					try groupWriter.writeUInt16(groupNameLen, .big)
					try groupWriter.writeData(groupName)
					try groupWriter.writeData(Common.DataTwoZeros)
				}
				
				// Write the group data length (the number of bytes between this block tag and the next
				try writer.writeUInt32(UInt32(groupWriter.count), .big)
				// And the group data
				try writer.writeData(groupWriter.data())

				for color in group.colors {
					try self.writeColorData(writer, color)
				}
				
				// group footer
				try writer.writeUInt16(ASE_GROUP_END, .big)
				try writer.writeUInt32(0, .big)
			}
		}

		return try writer.data()
	}
	
	private func writeColorData(_ writer: BytesWriter, _ color: PAL.Color) throws {
		// Write the color block header
		try writer.writeUInt16(ASE_BLOCK_COLOR, .big)

		// Generate the color data
		let colorData = try BytesWriter()
		do {
			// Write the name
			let colorName = color.name.data(using: .utf16BigEndian)!
			let colorNameLen = UInt16(color.name.count + 1)

			// Length of the name + zero terminator
			try colorData.writeUInt16(colorNameLen, .big)
			if colorName.count > 0 {
				try colorData.writeData(colorName)
			}
			try colorData.writeData(Common.DataTwoZeros)

			// Write the model
			let colorModel = ASEColorModel.from(color.colorSpace)
			try colorData.writeStringASCII(colorModel.rawValue)

			// Write the components
			let mappedComponents = color.colorComponents.map { Float32($0) }
			switch color.colorSpace {
			case .CMYK:
				try colorData.writeFloat32(mappedComponents[0], .big)
				try colorData.writeFloat32(mappedComponents[1], .big)
				try colorData.writeFloat32(mappedComponents[2], .big)
				try colorData.writeFloat32(mappedComponents[3], .big)
			case .RGB, .LAB:
				try colorData.writeFloat32(mappedComponents[0], .big)
				try colorData.writeFloat32(mappedComponents[1], .big)
				try colorData.writeFloat32(mappedComponents[2], .big)
			case .Gray:
				try colorData.writeFloat32(mappedComponents[0], .big)
			}
			
			// Write the color type
			let mappedColorType = ASEColorType.from(color.colorType)
			let colorType = UInt16(mappedColorType.rawValue)
			try colorData.writeUInt16(colorType, .big)
		}
		
		// Write the block length
		try writer.writeUInt32(UInt32(colorData.count), .big)
		// Write the color block data
		try writer.writeData(colorData.data())
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static var adobeSwatchExchange: Self { Self(filenameExtension: "ase", conformingTo: .data)! }
}
#endif
