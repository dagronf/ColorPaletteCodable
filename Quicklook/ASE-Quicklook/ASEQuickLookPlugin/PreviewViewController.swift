//
//  PreviewViewController.swift
//  ASEQuickLookPlugin
//
//  Created by Darren Ford on 17/5/2022.
//

import Cocoa
import Quartz

import ASEPalette

class PreviewViewController: NSViewController, QLPreviewingController {

	@IBOutlet weak var collectionView: NSCollectionView!

	var currentPalette: ASE.Palette? {
		didSet {
			if let p = currentPalette {
				if p.colors.count > 0 {
					currentGroups.append(ASE.Group(name: "Global colors", colors: p.colors))
				}
				currentGroups.append(contentsOf: p.groups)
			}
			self.collectionView.reloadData()
		}
	}
	var currentGroups = [ASE.Group]()

	override var nibName: NSNib.Name? {
		return NSNib.Name("PreviewViewController")
	}

	override func loadView() {
		super.loadView()
		// Do any additional setup after loading the view.

		collectionView.register(
			ColorSwatchView.self,
			forItemWithIdentifier: NSUserInterfaceItemIdentifier("ColorSwatchView")
		)

//		collectionView.register(
//			ColorGroupHeaderView.self,
//			forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader,
//			withIdentifier: NSUserInterfaceItemIdentifier("ColorGroupHeaderView")
//		)

//		let layout = NSCollectionViewFlowLayout()
//		layout.scrollDirection = .vertical
//		layout.minimumInteritemSpacing = 1
//		layout.minimumLineSpacing = 1
//		layout.sectionInset = NSEdgeInsets(top: 0, left: 25, bottom: 8, right: 8)
//		layout.itemSize = NSSize(width: 26, height: 26)
//		collectionView.collectionViewLayout = layout
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
		self.currentGroups = []
		let palette = try ASE.Palette.init(fileURL: url)
		self.currentPalette = palette
	}
}
