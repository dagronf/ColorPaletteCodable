//
//  ThumbnailProvider.swift
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

import QuickLookThumbnailing

import ColorPaletteCodable

class ThumbnailProvider: QLThumbnailProvider {
	override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
		guard
			let gradient = try? PAL.Gradient.Decode(from: request.fileURL),
			let cgGradient = gradient.cgGradient()
		else {
			handler(nil, nil)
			return
		}

		// Second way: Draw the thumbnail into a context passed to your block, set up with Core Graphics's coordinate system.
		handler(QLThumbnailReply(contextSize: request.maximumSize, drawing: { context -> Bool in
			// Draw the thumbnail here.

			let maxWidth = request.maximumSize.width * request.scale
			let maxHeight = request.maximumSize.height * request.scale
			let maxSize = CGSize(width: maxWidth, height: maxHeight)
			//let expectedRect = CGRect(origin: .zero, size: maxSize)

			let div = maxWidth / 24

			let bounds = CGRect(origin: .zero, size: maxSize).insetBy(dx: div, dy: div)
			let pth = CGPath(
				roundedRect: bounds,
				cornerWidth: div,
				cornerHeight: div,
				transform: nil
			)

			context.savingGState {
				$0.addPath(pth)
				$0.clip()
				$0.drawLinearGradient(
					cgGradient,
					start: CGPoint(x: bounds.minX, y: bounds.maxY),
					end: CGPoint(x: bounds.maxX, y: bounds.minY),
					options: [.drawsAfterEndLocation, .drawsBeforeStartLocation]
				)
			}

			context.savingGState {
				$0.addPath(pth)
				$0.setStrokeColor(CGColor(gray: 0.0, alpha: 1.0))
				$0.setLineWidth(0.5)
				$0.strokePath()
			}

			return true
		}), nil)
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
