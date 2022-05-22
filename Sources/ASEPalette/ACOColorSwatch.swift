//
//  ACOColorSwatch.swift
//
//  Created by Darren Ford on 22/5/2022.
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

public extension ASE {

	/// An object representing an ACO (Adobe Photoshop Swatch)
	///
	/// Based on the discussion here: https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#50577411_pgfId-1070626
	struct ACOColorSwatch: Equatable {

		/// The colors assigned to the swatch
		public var colors = [ASE.Color]()

		/// Create an empty ACO swatch file
		public init() { }

		/// Create from an array of ASE colors
		public init(colors: [ASE.Color]) {
			self.colors = colors
		}

		/// Create using the contents of `fileURL`
		public init(fileURL: URL) throws {
			try self._load(fileURL: fileURL)
		}

		/// Create using the contents of `data`
		public init(data: Data) throws {
			try self._load(data: data)
		}

		/// Returns an ACO data representation
		public func data() throws -> Data {
			try self._data()
		}
	}
}
