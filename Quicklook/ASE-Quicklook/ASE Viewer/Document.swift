//
//  Document.swift
//  Palette Viewer
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
	}

	override func writableTypes(for saveOperation: NSDocument.SaveOperationType) -> [String] {
		[
			"public.dagronf.colorpalette",
			"com.adobe.ase",
			"com.adobe.aco",
			"com.apple.color-file",
			"public.dagronf.gimp.gpl",
			"RGB Text File",
			"RGBA Text File",
		]
	}

	override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
		//let extension =  UTTypeCopyPreferredTagWithClass(myUTI, kUTTagClassFilenameExtension);
		guard let pal = currentPalette else {
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}

		if
			let t = UTType(typeName),
			let extn = t.preferredFilenameExtension,
			let coder = PAL.Palette.coder(for: extn)
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
		if url.pathExtension == "txt" {
			// Force the RGBA decoder (which will fallback to RGB if it cannot find alpha)
			self.currentPalette = try PAL.Palette.Decode(from: url, usingCoder: PAL.Coder.RGBA())
		}
		else if url.pathExtension == "jsoncolorgradient" {
			self.currentPalette = try PAL.Gradient.Decode(from: url).palette()
		}
		else if url.pathExtension == "ggr" {
			self.currentPalette = try PAL.Gradient.Decode(from: url).palette()
		}
		else {
			self.currentPalette = try PAL.Palette.Decode(from: url)
		}
	}
}

#endif
