//
//  Document.swift
//  Palette Viewer
//
//  Copyright © 2025 Darren Ford. All rights reserved.
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
import UniformTypeIdentifiers

class Document: NSDocument {

	var currentPalette: PAL.Palette?

	override init() {
	    super.init()
		// Add your subclass-specific initialization here.
	}

//	override class var autosavesInPlace: Bool {
//		return true
//	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
		let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
		self.addWindowController(windowController)

		let vc = windowController.contentViewController as! ViewController
		vc.representedObject = self
		vc.currentPalette.palette = currentPalette

		vc.view.setFrameSize(NSSize(width: 800, height: 600))

	}

	override func writableTypes(for saveOperation: NSDocument.SaveOperationType) -> [String] {
		ExportablePaletteTypes
	}

	override func data(ofType typeName: String) throws -> Data {
		guard let pal = currentPalette else {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}

		if
			let t = UTType(typeName),
			let extn = t.preferredFilenameExtension,
			let coder = PAL.Palette.coder(for: extn).first
		{
			return try coder.encode(pal)
		}
		else if typeName == "RGB Text File" {
			return try PAL.Coder.RGB().encode(pal)
		}
		else if typeName == "RGBA Text File" {
			return try PAL.Coder.RGBA().encode(pal)
		}

		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func read(from url: URL, ofType typeName: String) throws {
		self.currentPalette = try PAL.Palette.Decode(from: url)
	}
}

#endif
