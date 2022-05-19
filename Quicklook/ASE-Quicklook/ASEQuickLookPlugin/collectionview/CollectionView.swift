//
//  CollectionView.swift
//  ASEQuickLookPlugin
//
//  Created by Darren Ford on 17/5/2022.
//

import Foundation
import AppKit

import ASEPalette

extension PreviewViewController: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {

	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return self.currentGroups.count
	}

	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.currentGroups[section].colors.count
	}

	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		guard let swatch = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ColorSwatchView"), for: indexPath) as? ColorSwatchView else {
			assert(false)
			return NSCollectionViewItem()
		}

		let color = self.currentGroups[indexPath.section].colors[indexPath.item]
		guard let cg = color.cgColor, let ns = NSColor(cgColor: cg) else {
			assert(false)
			return NSCollectionViewItem()
		}

		swatch.colorWell.color = ns
		swatch.colorWell.toolTip = color.name

		return swatch
	}

	func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
		guard
			let view = collectionView.makeSupplementaryView(
				ofKind: NSCollectionView.elementKindSectionHeader,
				withIdentifier: NSUserInterfaceItemIdentifier("ColorGroupHeaderView"),
				for: indexPath)
				as? ColorGroupHeaderView
		else {
			fatalError()
		}

		let group = self.currentGroups[indexPath.section]

		let name: String = {
			let core = group.name
			if core == "" {
				return "<unnamed>"
			}
			return core
		}()

		view.groupNameTextField.stringValue = "\(name) (\(group.colors.count))"

		return view
	}

	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
		guard let p = self.currentPalette else { return .zero }
		let groups = self.paletteGroups(for: p)
		if groups[section].name == "_global" {
			return .zero
		}
		return NSSize(width: 0, height: 28)
	}

//	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
//		return NSSize(width: 26, height: 26)
//	}

}
