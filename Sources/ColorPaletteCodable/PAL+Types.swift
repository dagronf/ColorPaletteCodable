//
//  PAL+Types.swift
//
//  Created by Darren Ford on 16/5/2022.
//  Copyright © 2024 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

public extension PAL {
	/// A color representation for a color
	enum ColorSpace: String, Codable {
		case CMYK
		case RGB
		case LAB
		case Gray
	}

	/// The type of the color (normal, spot, global)
	enum ColorType: String, Codable {
		case global
		case spot
		case normal
	}

	/// Cross-platform size structure
	struct Size {
		public var width: Double
		public var height: Double
		public init(width: Double, height: Double) {
			self.width = width
			self.height = height
		}
	}
}

#if canImport(UIKit)
import UIKit
#endif

public extension PAL {
	/// Cross-platform edge insets
	struct EdgeInsets {
		public var top: Double
		public var left: Double
		public var bottom: Double
		public var right: Double
		public init(top: Double, left: Double, bottom: Double, right: Double) {
			self.top = top
			self.left = left
			self.bottom = bottom
			self.right = right
		}

		#if canImport(AppKit)
		/// Create from NSEdgeInsets
		public init(_ edgeInsets: NSEdgeInsets) {
			self.top = Double(edgeInsets.top)
			self.left = Double(edgeInsets.left)
			self.bottom = Double(edgeInsets.bottom)
			self.right = Double(edgeInsets.right)
		}

		/// Edge insets
		@inlinable public var edgeInsets: NSEdgeInsets {
			NSEdgeInsets(
				top: CGFloat(top),
				left: CGFloat(left),
				bottom: CGFloat(bottom),
				right: CGFloat(right)
			)
		}

		#endif

		#if canImport(UIKit)
		/// Create from UIEdgeInsets
		public init(_ edgeInsets: UIEdgeInsets) {
			self.top = edgeInsets.top
			self.left = edgeInsets.left
			self.bottom = edgeInsets.bottom
			self.right = edgeInsets.right
		}

		#if !targetEnvironment(macCatalyst)
		/// Edge insets
		@inlinable public var edgeInsets: UIEdgeInsets {
			UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
		}
		#endif
		#endif
	}
}
