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
	/// A coder for Paint Shop Pro (.pspgradient) gradients
	struct PaintShopProGradientCoder: PAL_GradientsCoder {
		/// The gradients format
		public static var format: PAL.GradientsFormat { .paintShopPro }
		/// The coder's file format
		public static let fileExtension = "pspgradient"
		/// The uniform type string for the gradient type
		public static let utTypeString = "public.dagronf.colorpalette.gradient.corel.paintshoppro.pspgradient"

		public init() {}
	}
}

public extension PAL.Gradients.Coder.PaintShopProGradientCoder {
	/// Encode the gradient using pspgradient format
	/// - Parameter gradients: The gradients to encode
	/// - Returns: encoded data
	func encode(_ gradients: PAL.Gradients) throws -> Data {
		// Same as Adobe GRD v3
		try PAL.Gradients.Coder.AdobeGradientsCoder().encode(gradients)
	}
}

public extension PAL.Gradients.Coder.PaintShopProGradientCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	///
	/// Note that the psppalette scheme appears to be equal to v3 of the grd format
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		// Same as Adobe GRD v3
		var g = try PAL.Gradients.Coder.AdobeGradientsCoder().decode(from: inputStream)
		g.format = self.format
		return g
	}
}
