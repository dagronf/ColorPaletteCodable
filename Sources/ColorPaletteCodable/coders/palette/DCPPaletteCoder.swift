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

// A Basic binary encoder/decoder for Palettes

import Foundation
import BytesParser

public extension PAL.Coder {
	/// An object representing a DCP file
	struct DCP: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .dcp
		public let name = "Color Palette"
		public let fileExtension = ["dcp"]
		public init() {}
	}
}

// MARK: Decode

private let BOM__: UInt16 = 32156
private let version__: UInt16 = 1
private let groupIdentifier__: UInt8 = 0xEA
private let colorIdentifier__: UInt8 = 0xC0

public extension PAL.Coder.DCP {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let parser = BytesReader(inputStream: inputStream)
		var result = PAL.Palette(format: self.format)

		// Read BOM
		guard try parser.readUInt16(.little) == BOM__ else {
			throw PAL.CommonError.invalidBOM
		}

		// Read version
		guard try parser.readUInt16(.little) == version__ else {
			throw PAL.CommonError.invalidBOM
		}

		// Palette name
		result.name = try parser.readPascalStringUTF16(.little)

		// Read the expected number of groups
		let expectedGroupCount = try parser.readUInt16(.little)

		// Read in the groups
		let groups: [PAL.Group] = try (0 ..< expectedGroupCount).map { _ in
			// Read a group identifer tag
			guard try parser.readByte() == groupIdentifier__ else { throw PAL.CommonError.invalidBOM }

			// Read the group name (uint16 length + utf16 string)
			let groupName = try parser.readPascalStringUTF16(.little)

			// Read the expected number of colors
			let expectedColorCount = try parser.readUInt16(.little)

			// The groups colors
			let colors = try (0 ..< expectedColorCount).map { _ in
				try parser.readColor()
			}

			return PAL.Group(colors: colors, name: groupName)
		}

		// First group is always the 'global' colors, even if there are none
		guard let globalColors = groups.first else { throw PAL.CommonError.invalidFormat }
		result.colors = globalColors.colors
		result.groups = Array(groups.dropFirst())
		return result
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation of the palette
	///
	/// Currently not supported for Adobe Color Book
	func encode(_ palette: PAL.Palette) throws -> Data {
		let file = try BytesWriter()

		// Expected BOM
		try file.writeUInt16(BOM__, .little)

		// Version
		try file.writeUInt16(version__, .little)

		// Write the palette name
		try file.writePascalStringUTF16(palette.name, .little)

		// Write the number of groups
		try file.writeUInt16(UInt16(palette.allGroups.count), .little)

		try palette.allGroups.forEach { group in
			// Write a group identifer tag
			try file.writeByte(groupIdentifier__)

			// Write the group name (uint16 length + utf16 string)
			try file.writePascalStringUTF16(group.name, .little)

			// Write the number of colors in the group
			try file.writeUInt16(UInt16(group.colors.count), .little)

			try group.colors.forEach { color in
				// The color
				try file.writeColor(color)
			}
		}

		return try file.data()
	}
}

extension BytesWriter {
	func writeColor(_ color: PAL.Color) throws {
		// Write a color identifer tag
		try self.writeByte(colorIdentifier__)

		// Color name
		try self.writePascalStringUTF16(color.name, .little)

		// Write the colorspace identifier
		switch color.colorSpace {
		case .CMYK: try self.writeUInt8(1)
		case .RGB: try self.writeUInt8(2)
		case .LAB: try self.writeUInt8(3)
		case .Gray: try self.writeUInt8(4)
		}

		// Write the color components
		let comps = color.colorComponents.map { Float32($0) }
		try self.writeFloat32(comps, .little)

		// Color alpha
		try self.writeFloat32(Float32(color.alpha), .little)

		// Color type
		switch color.colorType {
		case .global: try self.writeUInt8(1)
		case .spot: try self.writeUInt8(2)
		case .normal: try self.writeUInt8(3)
		}
	}
}

extension BytesReader {
	func readColor() throws -> PAL.Color {
		// Read a color identifer tag
		guard try self.readByte() == colorIdentifier__ else { throw PAL.CommonError.invalidBOM }

		// Read the group name (uint16 length + utf16 string)
		let colorName = try self.readPascalStringUTF16(.little)

		let colorspaceID = try self.readUInt8()

		let colorSpace: PAL.ColorSpace
		let components: [Float32]

		switch colorspaceID {
		case 1:
			// CMYK
			colorSpace = .CMYK
			components = try (0 ..< 4).map { _ in try self.readFloat32(.little) }
		case 2:
			// RGB
			colorSpace = .RGB
			components = try (0 ..< 3).map { _ in try self.readFloat32(.little) }
		case 3:
			// LAB
			colorSpace = .LAB
			components = try (0 ..< 3).map { _ in try self.readFloat32(.little) }
		case 4:
			// Gray
			colorSpace = .Gray
			components = [ try self.readFloat32(.little) ]
		default:
			throw PAL.CommonError.invalidFormat
		}

		// Alpha component
		let alpha = try self.readFloat32(.little)
		// Color type
		let type = try self.readUInt8()
		let colorType: PAL.ColorType = try {
			switch type {
			case 1: return .global
			case 2: return .spot
			case 3: return .normal
			default: throw PAL.CommonError.invalidFormat
			}
		}()

		return try PAL.Color(
			colorSpace: colorSpace,
			colorComponents: components.map { Double($0) },
			alpha: Double(alpha),
			name: colorName,
			colorType: colorType
		)
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let dcp = UTType("public.dagronf.colorpalette.dcp")!
}
#endif
