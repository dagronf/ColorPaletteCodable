//
//  GradientDocument.swift
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

#if os(macOS)

import Cocoa
import ColorPaletteCodable

class GradientDocument: NSDocument {

	var gradient: PAL.Gradient?

	let gradientVC = GradientViewController()

	override var windowNibName: String? {
		// Override to return the nib file name of the document.
		// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override makeWindowControllers() instead.
		return "GradientDocument"
	}

	override func windowControllerDidLoadNib(_ aController: NSWindowController) {
		super.windowControllerDidLoadNib(aController)
		// Add any code here that needs to be executed once the windowController has loaded the document's window.

		aController.window?.autorecalculatesKeyViewLoop = true

		aController.contentViewController = gradientVC
//		containerView.addSubview(gradientVC.view)
//
//		gradientVC.view.translatesAutoresizingMaskIntoConstraints = false
//		gradientVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
//		gradientVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
//		gradientVC.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
//		gradientVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

	}

	override func writableTypes(for saveOperation: NSDocument.SaveOperationType) -> [String] {
		[
			"public.dagronf.jsoncolorgradient",
			"public.dagronf.gimp.ggr",
		]
	}

	override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func read(from url: URL, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
		self.gradient = try PAL.Gradient.Decode(from: url)

		//throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	//    override class var autosavesInPlace: Bool {
	//        return true
	//    }

}

#endif
