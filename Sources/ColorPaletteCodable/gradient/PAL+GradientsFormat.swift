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
	enum GradientsFormat: CaseIterable {
		case json
		case dcg
		case gimp
		case adobeGRD
		case paintShopPro
		case colorPaletteTables
		case gnuplot
		case svg
		case swiftGen
		case swiftUIGen
	}
}

public extension PAL.GradientsFormat {
	/// Create a new coder based on the format
	var coder: PAL_GradientsCoder {
		switch self {
		case .json: return PAL.Gradients.Coder.JSON()
		case .dcg:  return PAL.Gradients.Coder.DCG()
		case .gimp:  return PAL.Gradients.Coder.GIMPGradientCoder()
		case .adobeGRD:  return PAL.Gradients.Coder.AdobeGradientsCoder()
		case .paintShopPro: return PAL.Gradients.Coder.PaintShopProGradientCoder()
		case .svg: return PAL.Gradients.Coder.SVG()
		case .colorPaletteTables: return PAL.Gradients.Coder.ColorPaletteTablesCoder()
		case .gnuplot: return PAL.Gradients.Coder.GNUPlotGradientCoder()
		case .swiftGen: return PAL.Gradients.Coder.SwiftGen()
		case .swiftUIGen: return PAL.Gradients.Coder.SwiftUIGen()
		}
	}
}
