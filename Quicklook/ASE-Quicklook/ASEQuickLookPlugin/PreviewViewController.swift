//
//  PreviewViewController.swift
//  ASEQuickLookPlugin
//
//  Created by Darren Ford on 17/5/2022.
//

import Cocoa
import Quartz
import SwiftUI

import ColorPaletteCodable

class PreviewViewController: NSViewController, QLPreviewingController {
	@IBOutlet var collectionView: NSCollectionView!
	
	override var nibName: NSNib.Name? {
		return NSNib.Name("PreviewViewController")
	}
	
	let currentPalette = PaletteModel(nil)
	private lazy var hostedView = PaletteView(paletteModel: self.currentPalette)
	
	override func loadView() {
		super.loadView()
		let containerView = self.view
		
		let nsView = NSHostingView(rootView: hostedView)
		
		containerView.addSubview(nsView)
		nsView.translatesAutoresizingMaskIntoConstraints = false
		nsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
		nsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
		nsView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
		nsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
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
			handler(nil)
		}
		catch {
			handler(error)
		}
	}
	
	func configure(for url: URL) throws {
		self.currentPalette.palette = nil
		self.currentPalette.palette = try PAL.Palette.Decode(from: url)
	}
}
