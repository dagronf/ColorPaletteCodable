//
//  ASEPalette.swift
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
import OSLog

// http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase

let ase_log = OSLogger(subsystem: Bundle.main.bundleIdentifier!, category: "ASEPalette")

/// Common namespace for all ASEPalette types
public class ASE { }

/// An object representing an ASE (Adobe Swatch Exchange) palette
extension ASE {
	public struct Palette: Equatable {
		public var version0: UInt16 = 1
		public var version1: UInt16 = 0

		/// Colors that are not assigned to a group
		public var global = Group(name: "_global")
		/// The groups of colors
		public var groups = [Group]()

		/// Create an empty palette
		public init() {}

		/// Create an ASEPalette from the specified file url
		public init(fileURL: URL) throws {
			guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
				ase_log.log(.error, "Unable to load .ase file")
				throw ASE.CommonError.unableToLoadFile
			}
			try self._load(inputStream: inputStream)
		}

		/// Create an ASEPalette from the specified raw data
		public init(data: Data) throws {
			let inputStream = InputStream(data: data)
			try self._load(inputStream: inputStream)
		}

		/// Returns an ASE data representation for the object
		public func data() throws -> Data {
			return try _data()
		}

		// private

		// The current color group that we are loading into
		internal var _currentGroup: Group?
	}
}
