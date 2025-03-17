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
	/// Supported gradient formats
	enum GradientCoderFormat: CaseIterable {
		case json
		case dcg
		case ggr
		case grd
		case psp
		case svg
		case cpt
		case gpf		// GNUPlot format

		/// Create a new coder based on the format
		public var coder: PAL_GradientsCoder {
			switch self {
			case .json: return PAL.Gradients.Coder.JSON()
			case .dcg:  return PAL.Gradients.Coder.DCG()
			case .ggr:  return PAL.Gradients.Coder.GGR()
			case .grd:  return PAL.Gradients.Coder.GRD()
			case .psp:  return PAL.Gradients.Coder.PSP()
			case .svg:  return PAL.Gradients.Coder.SVG()
			case .cpt:  return PAL.Gradients.Coder.CPT()
			case .gpf:  return PAL.Gradients.Coder.GPF()
			}
		}
	}
}
