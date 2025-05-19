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

#if canImport(SwiftUI) && canImport(UniformTypeIdentifiers)

import CoreTransferable
import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// A transferrable representation for `PAL.Color`
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

/// A transferrable representation for `PAL.Gradient`
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension PAL.Gradient: Transferable {
	/// The transferrable representation for this type (JSON encoded PAL.Gradient)
	public static var transferRepresentation: some TransferRepresentation {
		CodableRepresentation(contentType: .palGradient)
	}
}

/// A transferrable representation for `PAL.Gradients`
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension PAL.Gradients: Transferable {
	/// The transferrable representation for this type (JSON encoded PAL.Gradients)
	public static var transferRepresentation: some TransferRepresentation {
		CodableRepresentation(contentType: .palGradients)
	}
}

#endif
