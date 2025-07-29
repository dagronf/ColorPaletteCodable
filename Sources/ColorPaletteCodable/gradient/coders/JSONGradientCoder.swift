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

public extension PAL.Gradients.Coder {
	/// Simple JSON encoder/decoder
	struct JSON: PAL_GradientsCoder {
		/// The gradients format
		public static var format: PAL.GradientsFormat { .json }
		/// The coder's file format
		public static let fileExtension = "jsoncolorgradient"
		/// The uniform type string for the gradient type
		public static let utTypeString = "public.dagronf.colorpalette.gradients.json"

		/// Create
		public init() {}

		/// Attempt to decode a gradient using the
		/// - Parameter inputStream: The input stream containing the data
		/// - Returns: a gradient
		public func decode(from inputStream: InputStream) throws -> PAL.Gradients {
			try JSONDecoder().decode(PAL.Gradients.self, from: inputStream.readAllData())
		}

		/// Encode the gradient using the default JSON format
		/// - Parameter gradients: The gradients to encode
		/// - Returns: encoded data
		public func encode(_ gradients: PAL.Gradients) throws -> Data {
			try JSONEncoder().encode(gradients)
		}
	}
}

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let jsoncolorgradient = UTType(PAL.Gradients.Coder.JSON.utTypeString)!
}
#endif
