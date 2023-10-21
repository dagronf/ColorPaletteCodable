//
//  GradientDocument.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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

import SwiftUI

class GradientDocument: NSDocument {

	var gradients: PAL.Gradients?

	var gradientsView: GradientsInteractorView?
	var selectedGradient: UUID? = nil

	override var windowNibName: String? {
		// Override to return the nib file name of the document.
		// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override makeWindowControllers() instead.
		return "GradientDocument"
	}

	override func windowControllerDidLoadNib(_ aController: NSWindowController) {
		super.windowControllerDidLoadNib(aController)
		// Add any code here that needs to be executed once the windowController has loaded the document's window.

		aController.window?.autorecalculatesKeyViewLoop = true

		let g = self.gradients?.expandAllGradientsToEdges() ?? PAL.Gradients(gradients: [])
		let rootView = GradientsInteractorView(gradients: g, parent: self)
		self.gradientsView = rootView
		let v = NSHostingController(rootView: rootView)
		v.view.setFrameSize(NSSize(width: 600, height: 400))

		aController.contentViewController = v
	}

	override func writableTypes(for saveOperation: NSDocument.SaveOperationType) -> [String] {
		ExportableGradientTypes
	}

	override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
		guard let g = self.gradients else {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}

		if typeName == "public.dagronf.jsoncolorgradient" {
			return try PAL.Gradients.Coder.JSON().encode(g)
		}
		else if typeName == "public.dagronf.gimp.ggr" {
			return try PAL.Gradients.Coder.GGR().encode(g)
		}

		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func read(from url: URL, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override read(from:ofType:) instead.  If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
		self.gradients = try PAL.Gradients.Decode(from: url)
	}
}

extension GradientDocument: NSToolbarItemValidation {
	func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
		if self.selectedGradient != nil {
			return true
		}
		return false
	}


	@IBAction func ExportSelectedGradient(_ sender: NSButton) {
		if let selected = self.selectedGradient,
			let gradient = self.gradients?.find(id: selected)
		{
			try? exportGradient(gradient)
		}
	}

	@IBAction func ShowSwiftUIGenerated(_ sender: NSButton) {
		present(PAL.Gradients.Coder.SwiftUIGen(), sender)
	}

	@IBAction func ShowSwiftGenerated(_ sender: NSButton) {
		present(PAL.Gradients.Coder.SwiftGen(), sender)
	}

	func present(_ generator: PAL_GradientsCoder, _ sender: NSButton) {
		let export: PAL.Gradients? = {
			if let selected = self.selectedGradient,
				let gradient = self.gradients?.find(id: selected) {
				return PAL.Gradients(gradients: [gradient])
			}
			return self.gradients
		}()

		guard let gs = export else { fatalError() }

		guard
			let data = try? generator.encode(gs),
			let str = String(data: data, encoding: .utf8)
		else {
			fatalError()
		}

		let popover = NSPopover()
		popover.behavior = .semitransient

		let controller = NSHostingController(rootView: CodePopupView(code: str))
		controller.view.translatesAutoresizingMaskIntoConstraints = false
		popover.contentViewController = controller
		popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
	}
}

#endif
