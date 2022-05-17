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

	func paletteGroups(for palette: ASE.Palette) -> [ASE.Group] {
		var groups: [ASE.Group] = []
		if palette.global.colors.count > 0 {
			groups.append(palette.global)
		}
		groups.append(contentsOf: palette.groups)
		return groups
	}

	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		guard let p = self.currentPalette else { return 0 }
		return p.groups.count + (p.global.colors.count > 0 ? 1 : 0)
	}

	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let p = self.currentPalette else { return 0 }
		let groups = self.paletteGroups(for: p)
		return groups[section].colors.count
	}

	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		guard let p = self.currentPalette else { return NSCollectionViewItem() }

		guard let swatch = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ColorSwatchView"), for: indexPath) as? ColorSwatchView else {
			assert(false)
			return NSCollectionViewItem()
		}

		let groups = self.paletteGroups(for: p)
		let color = groups[indexPath.section].colors[indexPath.item]
		guard let cg = color.cgColor, let ns = NSColor(cgColor: cg) else {
			assert(false)
			return NSCollectionViewItem()
		}

		swatch.colorWell.color = ns
		swatch.colorWell.toolTip = color.name

		return swatch
	}

	func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
		guard let p = self.currentPalette else { return NSView() }
		let groups = self.paletteGroups(for: p)
		
		guard
			let view = collectionView.makeSupplementaryView(
				ofKind: NSCollectionView.elementKindSectionHeader,
				withIdentifier: NSUserInterfaceItemIdentifier("ColorGroupHeaderView"),
				for: indexPath)
				as? ColorGroupHeaderView
		else {
			fatalError()
		}

		let name: String = {
			let core = groups[indexPath.section].name
			if core == "_global" {
				return ""
			}
			if core == "" {
				return "<unnamed>"
			}
			return core
		}()

		view.groupNameTextField.stringValue = name

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
