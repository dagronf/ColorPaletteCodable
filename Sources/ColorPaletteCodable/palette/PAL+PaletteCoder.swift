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

public extension PAL.Palette {
	/// All coders
	static var AvailableCoders: [PAL_PaletteCoder] {
		PAL.PaletteFormat.allCases.map { $0.coder }
	}

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
		PAL.Coder.CorelDraw3PaletteCoder(),
		PAL.Coder.ScribusXMLPaletteCoder(),
		PAL.Coder.SimplePaletteCoder()
	]
}

public extension PAL.Palette {
	/// Returns a coder for the specified fileExtension
	static func coder(for fileExtension: String) -> [PAL_PaletteCoder] {
		let lext = fileExtension.lowercased()
		return AvailableCoders.filter({ $0.fileExtension.contains(lext) })
	}

	/// Return the coder for the specific UTType string (eg. "com.adobe.ase")
	/// - Parameter typeString: The UTType string
	/// - Returns: A coder matching the uttype, or nil for no coder
	static func coder(forTypeString typeString: String) -> PAL_PaletteCoder? {
		let lTS = typeString.lowercased()
		return AvailableCoders.first(where: { lTS == $0.utTypeString().lowercased() })
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

		// Loop through coders that support this path extension and try each one until one works
		for coder in coders {
			do {
				return try coder.decode(from: fileURL)
			}
			catch {
				// Move on to the next matching coder
			}
		}

		// None of our coders worked
		throw PAL.CommonError.unsupportedPaletteType
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
