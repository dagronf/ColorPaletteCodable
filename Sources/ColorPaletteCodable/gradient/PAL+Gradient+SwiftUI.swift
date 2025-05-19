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

// SwiftUI helpers for PAL.Gradient

#if canImport(Darwin) && canImport(SwiftUI)

import SwiftUI

@available(macOS 10.15, *)
public extension SwiftUI.Image {
	/// Create an image representation of a gradient
	/// - Parameters:
	///   - gradient: The gradient
	///   - size: The image size
	///   - startPoint: The unit start point for the gradient
	///   - endPoint: The unit end point for the gradient
	///   - label: The label to apply
	init(
		gradient: PAL.Gradient,
		size: CGSize,
		startPoint: UnitPoint = UnitPoint(x: 0, y: 0),
		endPoint: UnitPoint = UnitPoint(x: 1, y: 0),
		label: @autoclosure () -> Text
	) throws {
		let gr = try gradient.cgImage(
			size: size,
			unitStartPoint: CGPoint(x: startPoint.x, y: startPoint.y),
			unitEndPoint: CGPoint(x: endPoint.x, y: endPoint.y)
		)
		self = Image(gr, scale: 1, label: label())
	}

	/// Create an image representation of a gradient
	/// - Parameters:
	///   - gradient: The gradient
	///   - width: The image width
	///   - height: The image height
	///   - startPoint: The unit start point for the gradient
	///   - endPoint: The unit end point for the gradient
	///   - label: The label to apply
	init(
		gradient: PAL.Gradient,
		width: Double,
		height: Double,
		startPoint: UnitPoint = UnitPoint(x: 0, y: 0),
		endPoint: UnitPoint = UnitPoint(x: 1, y: 0),
		label: @autoclosure () -> Text
	) throws {
		try self.init(
			gradient: gradient,
			size: CGSize(width: width, height: height),
			startPoint: startPoint,
			endPoint: endPoint,
			label: label()
		)
	}
}

@available(macOS 10.15, *)
public extension SwiftUI.Image {
	/// Create a decorative image representation of a gradient (no label)
	/// - Parameters:
	///   - gradient: The gradient
	///   - size: The image size
	///   - startPoint: The unit start point for the gradient
	///   - endPoint: The unit end point for the gradient
	init(
		gradient: PAL.Gradient,
		size: CGSize,
		startPoint: UnitPoint = UnitPoint(x: 0, y: 0),
		endPoint: UnitPoint = UnitPoint(x: 1, y: 0)
	) throws {
		let gr = try gradient.cgImage(
			size: size,
			unitStartPoint: CGPoint(x: startPoint.x, y: startPoint.y),
			unitEndPoint: CGPoint(x: endPoint.x, y: endPoint.y)
		)
		self = Image(cgImage: gr)
	}

	/// Create a decorative image representation of a gradient (no label)
	/// - Parameters:
	///   - gradient: The gradient
	///   - width: The image width
	///   - height: The image height
	///   - startPoint: The unit start point for the gradient
	///   - endPoint: The unit end point for the gradient
	init(
		gradient: PAL.Gradient,
		width: Double,
		height: Double,
		startPoint: UnitPoint = UnitPoint(x: 0, y: 0),
		endPoint: UnitPoint = UnitPoint(x: 1, y: 0)
	) throws {
		try self.init(
			gradient: gradient,
			size: CGSize(width: width, height: height),
			startPoint: startPoint,
			endPoint: endPoint
		)
	}
}

#endif
