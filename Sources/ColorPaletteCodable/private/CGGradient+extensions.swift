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

#if canImport(CoreGraphics)

import CoreGraphics

// MARK: - Peeking inside a gradient

extension CGGradient {
	/// Return a gradient snapshor for this gradient
	var snapshot: CGGradientSnapshot { CGGradientSnapshot(gradient: self) }
}

class CGGradientSnapshot {
	/// Return the color at the fractional position within the gradient
	/// - Parameter unitValue: The unit value (clamped to 0.0 ... 1.0)
	/// - Returns: Color at a specified unit value
	func color(at unitValue: CGFloat) -> CGColor {
		let fraction = unitValue.clamped(to: 0.0 ... 1.0)
		let pixel = Int((CGFloat(self.snapshotSize) * fraction).rounded(.towardZero))
		let offset = pixel * 4

		let r = bitmap[offset + 0]
		let g = bitmap[offset + 1]
		let b = bitmap[offset + 2]
		let a = bitmap[offset + 3]

		return CGColor(
			colorSpace: Self.colorSpace,
			components: [
				CGFloat(r) * Self.divisor,
				CGFloat(g) * Self.divisor,
				CGFloat(b) * Self.divisor,
				CGFloat(a) * Self.divisor
			]
		)!
	}

	// Private

	private static let divisor: CGFloat = 1.0 / 255.0
	private static let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
	private let snapshotSize = 4096
	private let gradient: CGGradient
	private lazy var bitmap: [UInt8] = {
		[UInt8](repeating: 0, count: (self.snapshotSize + 1) * 4)
	}()

	fileprivate init(gradient: CGGradient) {
		self.gradient = gradient
		self.build()
	}

	private func build() {
		let sz = self.snapshotSize + 1
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		guard
			let ctx = CGContext(
				data: &bitmap,
				width: sz,
				height: 1,
				bitsPerComponent: 8,
				bytesPerRow: sz * 4,
				space: Self.colorSpace,
				bitmapInfo: bitmapInfo.rawValue
			)
		else {
			fatalError()
		}

		ctx.drawLinearGradient(
			gradient,
			start: .init(x: 0, y: 0),
			end: .init(x: sz, y: 0),
			options: []
		)
	}
}

#endif
