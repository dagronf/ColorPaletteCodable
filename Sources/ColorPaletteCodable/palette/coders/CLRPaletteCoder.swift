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

#if os(macOS)
import AppKit
#endif

/// An NSColorList palette coder/decoder.
public extension PAL.Coder {
	struct CLR: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .clr
		public let name = "Apple NSColorList"
		public let fileExtension = ["clr"]
		public static let utTypeString = "com.apple.color-file"    // conforms to `public.data`
		public init() {}
	}
}

extension PAL.Coder.CLR {
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {
#if os(macOS)
		let allData = inputStream.readAllData()
		let cl = try withDataWrittenToTemporaryFile(allData, fileExtension: "clr") { fileURL in
			return NSColorList(name: "", fromFile: fileURL.path)
		}
		if let cl = cl {
			var p = try PAL.Palette(cl)
			p.format = self.format
			return p
		}
		throw PAL.CommonError.unableToLoadFile
#else
		throw PAL.CommonError.unsupportedCoderType
#endif
	}
}

public extension PAL.Coder.CLR {
	func encode(_ palette: PAL.Palette) throws -> Data {
#if os(macOS)
		// Flatten all the colors into the color list
		let cl = palette.colorListFromAllColors()

		let data = try withTemporaryFile("clr") { tempURL -> Data in
			try cl.write(to: tempURL)
			return try Data(contentsOf: tempURL)
		}
		return data
#else
		throw PAL.CommonError.unsupportedCoderType
#endif
	}
}

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let appleColorList = UTType(PAL.Coder.CLR.utTypeString)!
}
#endif
