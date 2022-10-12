//
//  CLRPaletteCoder.swift
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

#if os(macOS)
import AppKit
#endif

/// An NSColorList palette coder/decoder.
public extension PAL.Coder {
	struct CLR: PAL_PaletteCoder {
		public let fileExtension = "clr"
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
			return try PAL.Palette(cl)
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
		// We only store 'global' colors in the colorlist. If you need some other behaviour, build a new
		// ASE.Palette containing a flat collection
		let cl = palette.colorListFromGlobalColors()

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
