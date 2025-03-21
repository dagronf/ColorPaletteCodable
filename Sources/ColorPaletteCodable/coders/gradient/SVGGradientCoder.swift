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
	/// A coder for PSP gradients
	struct SVG: PAL_GradientsCoder {
		/// The coder's file format
		public static let fileExtension = "svg"
		/// The uniform type string for the gradient type
		public static let utTypeString = "public.svg-image"

		public init() {}
	}
}

public extension PAL.Gradients.Coder.SVG {
	func encode(_ gradients: PAL.Gradients) throws -> Data {
		let width: Int = 400
		let rowHeight: Int = 50

		let totalHeight = gradients.gradients.count * rowHeight

		// SVG header
		var content = """
<svg width="\(width)" height="\(totalHeight)" viewBox="0 0 \(width) \(totalHeight)" fill="none" xmlns="http://www.w3.org/2000/svg">

"""

		gradients.gradients.enumerated().forEach { gradient in
			content += """
   <rect width="\(width)" height="\(rowHeight)" x="0" y="\(gradient.offset * rowHeight)" fill="url(#gradient-fill-\(gradient.offset))"/>

"""
		}

		content += "   <defs>\n"

		try gradients.gradients.enumerated().forEach { gradient in
			content += """
      <linearGradient id="gradient-fill-\(gradient.offset)" x1="0" y1="0" x2="\(width)" y2="0" gradientUnits="userSpaceOnUse">

"""
			// Merge any transparency information into the primary gradient stops
			let merged = try gradient.element.mergeTransparencyStops()

			// Map the stops 0 -> 1
			let g = try merged.normalized()

			try g.stops.forEach { stop in
				let cl = try stop.color.hexRGB(hashmark: true)
				content += "         <stop offset=\"\(stop.position)\" stop-color=\"\(cl)\" stop-opacity=\"\(stop.color.alpha)\" />\n"
			}
			content += "      </linearGradient>\n"
		}

		content += """
   </defs>
</svg>
"""
		if let data = content.data(using: .utf8) {
			return data
		}
		throw PAL.CommonError.cannotGenerateGradient
	}
}

public extension PAL.Gradients.Coder.SVG {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		throw PAL.CommonError.notImplemented
	}
}
