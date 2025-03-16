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

// MARK: - Modification

public extension PAL.Color {
	/// Replace the color components of this color to rgb components while keeping its unique identifier
	/// - Parameters:
	///   - whitef: The while component (0.0 ... 1.0)
	///   - af: Alpha component (0.0 ... 1.0)
	mutating func setRGB(rf: Double, gf: Double, bf: Double, af: Double) {
		self.colorSpace = .RGB
		self.colorComponents = [rf.unitClamped, gf.unitClamped, bf.unitClamped]
		self.alpha = af.unitClamped
	}

	/// Replace the color components of this color to gray components while keeping its unique identifier
	/// - Parameters:
	///   - whitef: The while component (0.0 ... 1.0)
	///   - af: Alpha component (0.0 ... 1.0)
	mutating func setGray(whitef: Double, af: Double) {
		self.colorSpace = .Gray
		self.colorComponents = [whitef.unitClamped]
		self.alpha = af.unitClamped
	}

	/// Replace the color components of this color with those of another color while keeping its unique identifier
	/// - Parameter color: The color whose components will be used to replace these
	mutating func setColor(_ color: PAL.Color) {
		self.name = color.name
		self.colorSpace = color.colorSpace
		self.colorComponents = color.colorComponents
		self.alpha = color.alpha
	}
}
