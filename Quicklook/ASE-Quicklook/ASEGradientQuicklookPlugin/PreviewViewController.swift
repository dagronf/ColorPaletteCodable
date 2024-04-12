//
//  PreviewViewController.swift
//
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

import Cocoa
import Quartz

import ColorPaletteCodable
import Defaults

import SwiftUI

extension Defaults.Keys {
	static let presentation = Key<PresentationType>("presentation", default: .linear)
	static let flipped = Key<Bool>("flipped", default: false)
}

enum PresentationType: Int, DefaultsSerializable {
	case linear = 0
	case radial = 1
}

class GradientPreviewViewController: NSViewController, QLPreviewingController {
	var gradients: PAL.Gradients?

	var gradientViewController: NSHostingController<GradientsView>?

	override func loadView() {
		self.view = NSView()
		self.view.translatesAutoresizingMaskIntoConstraints = false
	}

	func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
		do {
			self.gradients = try PAL.Gradients.Decode(from: url)

			let v = NSHostingView(rootView: GradientsView(gradients: self.gradients ?? PAL.Gradients(gradients: []), selectedGradient: .constant(nil)))
			v.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview(v)

			self.view.addConstraint(NSLayoutConstraint(item: v, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
			self.view.addConstraint(NSLayoutConstraint(item: v, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
			self.view.addConstraint(NSLayoutConstraint(item: v, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))
			self.view.addConstraint(NSLayoutConstraint(item: v, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0))

			handler(nil)
		}
		catch {
			handler(error)
		}

		handler(nil)
	}
}
