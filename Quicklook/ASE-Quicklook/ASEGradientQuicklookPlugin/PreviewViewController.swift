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
import Defaults

extension Defaults.Keys {
	static let presentation = Key<PresentationType>("presentation", default: .linear)
	static let flipped = Key<Bool>("flipped", default: false)
}

enum PresentationType: Int, DefaultsSerializable {
	case linear = 0
	case radial = 1
}

class PreviewViewController: NSViewController, QLPreviewingController {
	@IBOutlet var gradientView: GradientDisplayView!
	@IBOutlet weak var gradientStyleSegment: NSSegmentedControl!

	var gradient: PAL.Gradient?

	@objc dynamic var selectedPresentationTag: Int = Defaults[.presentation].rawValue {
		didSet {
			self.gradientView.presentationType = PresentationType(rawValue: selectedPresentationTag)!
		}
	}

	@objc dynamic var flipGradient: Bool = Defaults[.flipped] {
		didSet {
			self.gradientView.flipGradient = flipGradient
		}
	}

	override var nibName: NSNib.Name? {
		return NSNib.Name("PreviewViewController")
	}

	override func loadView() {
		super.loadView()
		// Do any additional setup after loading the view.
	}

	func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
		do {
			self.gradient = try PAL.Gradient.Decode(from: url)
			self.gradientView.gradient = self.gradient
			handler(nil)
		}
		catch {
			handler(error)
		}

		handler(nil)
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

	var presentationType: PresentationType = Defaults[.presentation] {
		didSet {
			Defaults[.presentation] = presentationType
			self.needsDisplay = true
		}
	}

	var flipGradient: Bool = Defaults[.flipped] {
		didSet {
			Defaults[.flipped] = flipGradient
			self.needsDisplay = true
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

		if presentationType == .linear {

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
						start: flipGradient ? CGPoint(x: coreRect.maxX, y: coreRect.minY) : CGPoint(x: coreRect.minX, y: coreRect.maxY),
						end: flipGradient ? CGPoint(x: coreRect.minX, y: coreRect.maxY) : CGPoint(x: coreRect.maxX, y: coreRect.minY),
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
		else {
			let radialRect = insetRect.insetBy(dx: 16, dy: 16)

			let w = min(radialRect.width - 3, radialRect.height - 3)

			let midx = (radialRect.width - w) / 2
			let midy = (radialRect.height - w) / 2

			// The drawing rectangle, WITHOUT the shadow
			let coreRect = CGRect(
				x: radialRect.origin.x + midx,
				y: radialRect.origin.y + 16 + midy,
				width: w,
				height: w
			)

			let maxR = max(coreRect.width, coreRect.height) / 2

			// The path for the gradient content
			let boundsPath = CGPath(ellipseIn: coreRect, transform: nil)

			// Draw the gradient within the bounds path
			ctx.savingGState {
				$0.addPath(boundsPath)
				$0.clip()
				$0.drawRadialGradient(
					g,
					startCenter: CGPoint(x: coreRect.midX, y: coreRect.midY),
					startRadius: flipGradient ? maxR : 0,
					endCenter: CGPoint(x: coreRect.midX, y: coreRect.midY),
					endRadius: flipGradient ? 0 : maxR,
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
