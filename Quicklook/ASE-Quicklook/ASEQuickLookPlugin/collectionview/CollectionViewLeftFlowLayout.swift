//
//  CollectionFlowLeftAligned.swift
//  ASEQuickLookPlugin
//
//  Created by Darren Ford on 17/5/2022.
//

import AppKit
import Foundation

class CollectionViewLeftFlowLayout: NSCollectionViewFlowLayout {
	override func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes] {
		let defaultAttributes = super.layoutAttributesForElements(in: rect)

		if defaultAttributes.isEmpty {
			return defaultAttributes
		}

		var leftAlignedAttributes = [NSCollectionViewLayoutAttributes]()

		var xCursor = self.sectionInset.left // left margin
		var lastYPosition = defaultAttributes[0].frame.origin.y // if/when there is a new row, we want to start at left margin
		var lastItemHeight = defaultAttributes[0].frame.size.height

		for attributes in defaultAttributes {
			// copy() Needed to avoid warning from CollectionView that cached values are mismatched
			guard let newAttributes = attributes.copy() as? NSCollectionViewLayoutAttributes else {
				continue
			}

			if newAttributes.frame.origin.y > (lastYPosition + lastItemHeight) {
				// We have started a new row
				xCursor = self.sectionInset.left
				lastYPosition = newAttributes.frame.origin.y
			}

			newAttributes.frame.origin.x = xCursor

			xCursor += newAttributes.frame.size.width + minimumInteritemSpacing
			lastItemHeight = newAttributes.frame.size.height

			leftAlignedAttributes.append(newAttributes)
		}
		return leftAlignedAttributes
	}
}
