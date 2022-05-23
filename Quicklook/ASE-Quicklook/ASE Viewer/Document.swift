//
//  Document.swift
//  Palette Viewer
//
//  Created by Darren Ford on 19/5/2022.
//

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

//	override func data(ofType typeName: String) throws -> Data {
//		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
//		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
//		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//	}

	override func read(from url: URL, ofType typeName: String) throws {
		if url.pathExtension == "txt" {
			self.currentPalette = try PAL.Palette.load(fileURL: url, forcedExtension: "rgba")
		}
		else {
			self.currentPalette = try PAL.Palette.load(fileURL: url)
		}
	}
}
