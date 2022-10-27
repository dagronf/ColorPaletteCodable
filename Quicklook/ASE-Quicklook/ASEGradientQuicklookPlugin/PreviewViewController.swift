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
	@IBOutlet var gradientView: GradientDisplayView!

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
			self.gradientView.gradient = self.gradient
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

		/*
		 ┌────────────────────┐
		 │                    │█
		 │                    │█
		 │                    │█
		 │                    │█
		 │                    │█
		 └────────────────────┘█
		  ██████████████████████
		 */

		// Give a 1px breathing space around the outside of the drawing
		let insetRect = self.bounds.insetBy(dx: 1, dy: 1)

		let barHeight = min(200.0, insetRect.height - 4)

		do {
			var horizontalRect = insetRect
			horizontalRect.size.height = barHeight

			let yOffset = (insetRect.height - barHeight) / 2


			// The drawing rectangle, WITHOUT the shadow
			let coreRect = CGRect(
				x: horizontalRect.origin.x,
				y: yOffset,
				width: horizontalRect.width - 3,
				height: horizontalRect.height - 3
			)

			// The path for the gradient content
			let boundsPath = CGPath(roundedRect: coreRect, cornerWidth: 4, cornerHeight: 4, transform: nil)

			// Draw the gradient within the bounds path
			ctx.savingGState {
				$0.addPath(boundsPath)
				$0.clip()
				$0.drawLinearGradient(
					g,
					start: CGPoint(x: coreRect.minX, y: coreRect.maxY),
					end: CGPoint(x: coreRect.maxX, y: coreRect.minY),
					options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
				)
			}

			// Add a shadow to the gradient path.
			ctx.savingGState {
				// Add a path around the bounds
				$0.addPath(CGPath(rect: self.bounds, transform: nil))
				// Add another path around the bounds path
				$0.addPath(boundsPath)
				// Clip the drawing using evenOdd, which means that the clip path is the DIFFERENCE between the two paths
				$0.clip(using: .evenOdd)

				// Now, draw the shadow
				$0.addPath(boundsPath)
				$0.setFillColor(CGColor.white.copy(alpha: 0.3)!)
				$0.setShadow(offset: CGSize(width: 2, height: -2), blur: 3, color: .black)
				$0.fillPath()
			}

			// Draw a border around the gradient path
			ctx.savingGState {
				$0.addPath(boundsPath)
				let alpha: Double = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast ? 1.0 : 0.1
				$0.setStrokeColor(NSColor.textColor.withAlphaComponent(alpha).cgColor)
				$0.setLineWidth(1)
				$0.strokePath()
			}
		}
	}
}

extension CGContext {
	// Call a block while wrapped in a GState save
	@inlinable func savingGState(_ block: (CGContext) -> Void) {
		self.saveGState()
		defer { self.restoreGState() }
		block(self)
	}
}
