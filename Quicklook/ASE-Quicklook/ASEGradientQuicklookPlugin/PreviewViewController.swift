//
//  PreviewViewController.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
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

class PreviewViewController: NSViewController, QLPreviewingController {

	@IBOutlet weak var gradientView: GradientDisplayView!

	var gradient: PAL.Gradient?

	override var nibName: NSNib.Name? {
		return NSNib.Name("PreviewViewController")
	}

	override func loadView() {
		super.loadView()
		// Do any additional setup after loading the view.
	}

	/*
	 * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.
	 *
	 func preparePreviewOfSearchableItem(identifier: String, queryString: String?, completionHandler handler: @escaping (Error?) -> Void) {
	 // Perform any setup necessary in order to prepare the view.

	 // Call the completion handler so Quick Look knows that the preview is fully loaded.
	 // Quick Look will display a loading spinner while the completion handler is not called.
	 handler(nil)
	 }
	 */

	func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {

		// Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.

		// Perform any setup necessary in order to prepare the view.

		// Call the completion handler so Quick Look knows that the preview is fully loaded.
		// Quick Look will display a loading spinner while the completion handler is not called.

		do {
			try self.configure(for: url)
			gradientView.gradient = gradient
			handler(nil)
		}
		catch {
			handler(error)
		}

		handler(nil)
	}

	func configure(for url: URL) throws {
		self.gradient = try PAL.Gradient.Decode(from: url)
	}
}


class GradientDisplayView: NSView {
	override var isOpaque: Bool { false }

	private var _gradient: CGGradient?

	var gradient: PAL.Gradient? {
		didSet {
			self._gradient = gradient?.cgGradient()
		}
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		guard
			let g = _gradient,
			let ctx = NSGraphicsContext.current?.cgContext
		else {
			return
		}

		let contextRect = self.bounds.insetBy(dx: 1, dy: 1)

		let boundsPath = CGPath(
			roundedRect: contextRect,
			cornerWidth: 4,
			cornerHeight: 4,
			transform: nil
		)

		ctx.saveGState()
		ctx.addPath(boundsPath)
		ctx.clip()
		ctx.drawLinearGradient(
			g,
			start: .zero,
			end: CGPoint(x: contextRect.width, y: 0),
			options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
		)
		ctx.restoreGState()

		ctx.saveGState()
		ctx.addPath(boundsPath)
		ctx.setStrokeColor(NSColor.textColor.withAlphaComponent(0.1).cgColor)
		ctx.setLineWidth(1)
		ctx.strokePath()
		ctx.restoreGState()
	}

}
