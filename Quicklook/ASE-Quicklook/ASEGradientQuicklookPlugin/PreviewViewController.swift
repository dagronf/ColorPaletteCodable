//
//  PreviewViewController.swift
//  ASEGradientQuicklookPlugin
//
//  Created by Darren Ford on 25/10/2022.
//

import Cocoa
import Quartz

import ColorPaletteCodable

class PreviewViewController: NSViewController, QLPreviewingController {

	@IBOutlet weak var imageView: NSImageView!

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
			imageView.image = gradient?.image(size: CGSize(width: 500, height: 50))
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
