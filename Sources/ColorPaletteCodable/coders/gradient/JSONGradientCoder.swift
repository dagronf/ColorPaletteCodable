//
//  JSONGradientCoder.swift
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

public extension PAL.Gradient.Coder {
	/// Simple JSON encoder/decoder
	struct JSON: PAL_GradientCoder {
		/// The coder's file format
		public static let fileExtension = "jsoncolorgradient"

		/// Create
		public init() {}

		/// Attempt to decode a gradient using the
		/// - Parameter inputStream: The input stream containing the data
		/// - Returns: a gradient
		public func decode(from inputStream: InputStream) throws -> PAL.Gradient {
			try JSONDecoder().decode(PAL.Gradient.self, from: inputStream.readAllData())
		}

		/// Encode the gradient using the default JSON format
		/// - Parameter gradient: The gradient to encode
		/// - Returns: encoded data
		public func encode(_ gradient: PAL.Gradient) throws -> Data {
			try JSONEncoder().encode(gradient)
		}
	}
}
