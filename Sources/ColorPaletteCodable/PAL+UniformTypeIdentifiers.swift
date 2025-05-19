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

// Transferrable UTI types for the core object types

#if canImport(UniformTypeIdentifiers)

import Foundation
import UniformTypeIdentifiers

@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	/// A `PAL.Color` object
	static let palColor = UTType(exportedAs: "public.dagronf.colorpalette.color", conformingTo: UTType.json)
	/// A `PAL.Gradient` object
	static let palGradient = UTType(exportedAs: "public.dagronf.colorpalette.gradient.json", conformingTo: UTType.json)
	/// A `PAL.Gradients` object
	static let palGradients = UTType(exportedAs: "public.dagronf.colorpalette.gradients.json", conformingTo: UTType.json)

	/// System color type
	static let systemColor = UTType("com.apple.cocoa.pasteboard.color")!
}

#endif
