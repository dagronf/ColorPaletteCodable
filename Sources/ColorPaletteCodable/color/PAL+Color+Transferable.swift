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

// PAL.Color Support for CoreTransferable and the `Transferable` protocol

#if canImport(UniformTypeIdentifiers)

import Foundation
import UniformTypeIdentifiers

@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	/// The UTType for a JSON encoded `PAL.Color` value
	static let palColor = UTType(exportedAs: "public.dagronf.colorpalette.color", conformingTo: UTType.json)
	static let systemColor = UTType("com.apple.cocoa.pasteboard.color")!
}

#if canImport(SwiftUI)
import SwiftUI
import CoreTransferable

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension PAL.Color: Transferable {

	private var swcolor: SwiftUI.Color { self.SwiftUIColor ?? .black }

	public static var transferRepresentation: some TransferRepresentation {
		// Add the basic transfer representation for a SwiftUI.Color
		ProxyRepresentation(exporting: \.swcolor)
		// Add PAL.Color as a codable type
		CodableRepresentation(contentType: .palColor)
	}
}

#endif
#endif
