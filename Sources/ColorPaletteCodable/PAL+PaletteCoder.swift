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

public extension PAL {
	/// Supported palette formats
	enum PaletteCoderType: CaseIterable {
		case acb           // Adobe Color Book
		case aco           // Adobe Photoshop Swatch
		case act           // Adobe Color Tables
		case androidXML    // Android XML Palette file
		case ase           // Adobe Swatch Exchange
		case basicXML      // Basic XML palette format
		case clr           // macOS NSColorList
		case corelPainter  // Corel Painter Swatches
		case corelDraw     // CorelDraw XML
		case corelPalette  // Corel Palette
		case csv           // CSV Palette
		case dcp           // ColorPaletteCodable binary format
		case gimp          // GIMP gpl format
		case hexRGBA       // Hex RGBA coded files
		#if canImport(CoreGraphics)
		case image         // image-based palette coder
		#endif
		case json          // ColorPaletteCodable binary format
		case openOffice    // OpenOffice palette format (.soc)
		case paintNET      // Paint.NET palette file (.txt)
		case paintShopPro  // Paint Shop Pro palette (.pal, .psppalette)
		case rgba          // RGBA encoded text files (.rgba, .txt)
		case rgb           // RGB encoded text files (.rgb, .txt)
		case riff          // Microsoft RIFF palette (.pal))
		case sketch        // Sketch palette file (.sketchpalette)
		case svg           // Scalable Vector Grapihcs palette (.svg)
		case swift         // (export only) Swift source file (.swift)

		/// Create a new coder based on the format
		public var coder: PAL_PaletteCoder {
			switch self {
			case .acb          : return PAL.Coder.ACB()
			case .aco          : return PAL.Coder.ACO()
			case .act          : return PAL.Coder.ACT()
			case .androidXML   : return PAL.Coder.AndroidColorsXML()
			case .ase          : return PAL.Coder.ASE()
			case .basicXML     : return PAL.Coder.BasicXML()
			case .clr          : return PAL.Coder.CLR()
			case .corelPainter : return PAL.Coder.CorelPainter()
			case .corelDraw    : return PAL.Coder.CorelXMLPalette()
			case .corelPalette : return PAL.Coder.CPL()
			case .csv          : return PAL.Coder.CSV()
			case .dcp          : return PAL.Coder.DCP()
			case .gimp         : return PAL.Coder.GIMP()
			case .hexRGBA      : return PAL.Coder.HEX()
			#if canImport(CoreGraphics)
			case .image        : return PAL.Coder.Image()
			#endif
			case .json         : return PAL.Coder.JSON()
			case .openOffice   : return PAL.Coder.OpenOfficePaletteCoder()
			case .paintNET     : return PAL.Coder.PaintNET()
			case .paintShopPro : return PAL.Coder.PaintShopPro()
			case .rgba         : return PAL.Coder.RGBA()
			case .rgb          : return PAL.Coder.RGB()
			case .riff         : return PAL.Coder.RIFF()
			case .sketch       : return PAL.Coder.SketchPalette()
			case .svg          : return PAL.Coder.SVG()
			case .swift        : return PAL.Coder.SwiftCoder()
			}
		}
	}
}

public extension PAL.Palette {
	/// All coders
	static let AvailableCoders: [PAL_PaletteCoder] =
		PAL.PaletteCoderType.allCases.map { $0.coder }

	/// All text-based coders
	static let TextBasedCoders: [PAL_PaletteCoder] = [
		PAL.Coder.RGB(),
		PAL.Coder.RGBA(),
		PAL.Coder.CSV(),
		PAL.Coder.JSON(),
		PAL.Coder.GIMP(),
		PAL.Coder.PaintShopPro(),
		PAL.Coder.SketchPalette(),
		PAL.Coder.CorelXMLPalette(),
		PAL.Coder.BasicXML(),
		PAL.Coder.HEX(),
		PAL.Coder.PaintNET(),
		PAL.Coder.CorelPainter(),
		PAL.Coder.AndroidColorsXML(),
		PAL.Coder.OpenOfficePaletteCoder(),
	]
}

public extension PAL.Palette {
	/// Returns a coder for the specified fileExtension
	static func coder(for fileExtension: String) -> [PAL_PaletteCoder] {
		let lext = fileExtension.lowercased()
		return AvailableCoders.filter({ $0.fileExtension.contains(lext) })
	}
	
	/// Returns a coder for the specified fileURL
	static func coder(for fileURL: URL) -> [PAL_PaletteCoder] {
		let lext = fileURL.pathExtension.lowercased()
		return AvailableCoders.filter({ $0.fileExtension.contains(lext) })
	}

	/// Returns the first coder for the file type
	@inlinable static func firstCoder(for fileExtension: String) -> PAL_PaletteCoder? {
		PAL.Palette.coder(for: fileExtension).first
	}

	/// Returns the first coder for the file type
	@inlinable static func firstCoder(for fileURL: URL) -> PAL_PaletteCoder? {
		PAL.Palette.coder(for: fileURL).first
	}

	/// Decode a palette from the contents of a fileURL
	/// - Parameters:
	///   - fileURL: The file to load
	///   - coder: If set, provides a coder to use instead if using the fileURL extension
	/// - Returns: A palette
	static func Decode(from fileURL: URL, usingCoder coder: PAL_PaletteCoder? = nil) throws -> PAL.Palette {
		let coders: [PAL_PaletteCoder] = try {
			if let coder = coder {
				return [coder]
			}

			let coders = self.coder(for: fileURL.pathExtension)
			guard coders.count > 0 else {
				throw PAL.CommonError.unsupportedCoderType
			}

			return coders
		}()

		var lastError: Error = PAL.CommonError.unsupportedPaletteType

		// Loop through coders that support this path extension and try each one until one works
		for coder in coders {
			do {
				return try coder.decode(from: fileURL)
			}
			catch {
				lastError = error
			}
		}

		// None of our coders worked
		throw lastError
	}
	
	/// Decode a palette from the contents of a fileURL
	/// - Parameters:
	///   - data: The data
	///   - fileExtension: The expected file extension for the data
	/// - Returns: A palette
	static func Decode(from data: Data, fileExtension: String) throws -> PAL.Palette {
		let coders = self.coder(for: fileExtension)
		guard coders.count > 0 else {
			throw PAL.CommonError.unsupportedCoderType
		}

		// Loop through coders that support this path extension and try each one until one works
		for coder in coders {
			do {
				return try coder.decode(from: data)
			}
			catch {

			}
		}

		// None of our coders worked
		throw PAL.CommonError.unsupportedPaletteType
	}
	
//	/// Encode the specified palette using the specified coder
//	/// - Parameters:
//	///   - palette: The palette to encode
//	///   - fileExtension: The coder to use for the encoded data
//	/// - Returns: The encoded data
//	static func Encode(_ palette: PAL.Palette, fileExtension: String) throws -> Data {
//		guard let coder = self.coder(for: fileExtension) else {
//			throw PAL.CommonError.unsupportedCoderType
//		}
//		return try coder.encode(palette)
//	}
}

#if !os(Linux) && !os(Windows)

import UniformTypeIdentifiers

@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension PAL.Palette {
	/// Returns a coder that handles the specified UTType
	static func coder(for type: UTType) -> PAL_PaletteCoder? {
		AvailableCoders.first { coder in
			coder.fileExtension.first?.lowercased() == type.preferredFilenameExtension?.lowercased()
		}
	}
}

#endif
