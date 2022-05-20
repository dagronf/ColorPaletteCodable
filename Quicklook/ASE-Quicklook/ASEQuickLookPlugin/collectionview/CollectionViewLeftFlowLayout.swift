//
//  CollectionFlowLeftAligned.swift
//  ASEQuickLookPlugin
//
//  Created by Darren Ford on 17/5/2022.
//

import AppKit
import Foundation

// This seems to work, but is SLOW for large sections
class CollectionViewLeftFlowLayout: NSCollectionViewFlowLayout {

	override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
		let originalAttributes = super.layoutAttributesForElements(in: rect)
		var attributesToReturn = [NSCollectionViewLayoutAttributes]()

		for attributes in originalAttributes {
			let copiedAttributes = attributes.copy() as! NSCollectionViewLayoutAttributes
			if copiedAttributes.representedElementKind == nil {
				copiedAttributes.frame = self.layoutAttributesForItem(at: attributes.indexPath!)!.frame
			}
			attributesToReturn.append(copiedAttributes)
		}
		return attributesToReturn
	}


	override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
		guard
			let flowLayout = self.collectionView?.collectionViewLayout as? NSCollectionViewFlowLayout,
			let curAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? NSCollectionViewLayoutAttributes
		else {
			return nil
		}

		let sectionInset = flowLayout.sectionInset

		if indexPath.item == 0 {
			let f = curAttributes.frame
			curAttributes.frame = CGRect(x: sectionInset.left, y: f.origin.y, width: f.size.width, height: f.size.height)
			return curAttributes
		}

		let prevIndexPath = NSIndexPath(forItem: indexPath.item-1, inSection: indexPath.section)
		let prevFrame = self.layoutAttributesForItem(at: prevIndexPath as IndexPath)!.frame
		let prevFrameRightPoint = prevFrame.origin.x + prevFrame.size.width + self.minimumInteritemSpacing //maximumCellSpacing

		let curFrame = curAttributes.frame
		let stretchedCurFrame = CGRect(x: 0, y: curFrame.origin.y, width: self.collectionView!.frame.size.width, height: curFrame.size.height)

		if prevFrame.intersects(stretchedCurFrame) {
			curAttributes.frame = CGRect(x: prevFrameRightPoint, y: curFrame.origin.y, width: curFrame.size.width, height: curFrame.size.height)
		} else {
			curAttributes.frame = CGRect(x: sectionInset.left, y: curFrame.origin.y, width: curFrame.size.width, height: curFrame.size.height)
		}

		return curAttributes
	}
}



// WORKING BUT SLOW

//class CollectionViewLeftFlowLayout: NSCollectionViewFlowLayout {
//
//	var maximumCellSpacing = CGFloat(2.0)
//
//	override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
//		let attributesToReturn = super.layoutAttributesForElements(in: rect)
//
//		for attributes in attributesToReturn {
//			if attributes.representedElementKind == nil {
//				attributes.frame = self.layoutAttributesForItem(at: attributes.indexPath!)!.frame
//			}
//		}
//		return attributesToReturn
//	}
//
//	override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
//		let curAttributes = super.layoutAttributesForItem(at: indexPath)
//		let sectionInset = (self.collectionView?.collectionViewLayout as! NSCollectionViewFlowLayout).sectionInset
//
//		if indexPath.item == 0 {
//			let f = curAttributes!.frame
//			curAttributes!.frame = CGRect(x: sectionInset.left, y: f.origin.y, width: f.size.width, height: f.size.height)
//			return curAttributes
//		}
//
//		let prevIndexPath = NSIndexPath(forItem: indexPath.item-1, inSection: indexPath.section)
//		let prevFrame = self.layoutAttributesForItem(at: prevIndexPath as IndexPath)!.frame
//		let prevFrameRightPoint = prevFrame.origin.x + prevFrame.size.width + maximumCellSpacing
//
//		let curFrame = curAttributes!.frame
//		let stretchedCurFrame = CGRect(x: 0, y: curFrame.origin.y, width: self.collectionView!.frame.size.width, height: curFrame.size.height)
//
//		if prevFrame.intersects(stretchedCurFrame) {
//			curAttributes!.frame = CGRect(x: prevFrameRightPoint, y: curFrame.origin.y, width: curFrame.size.width, height: curFrame.size.height)
//		} else {
//			curAttributes!.frame = CGRect(x: sectionInset.left, y: curFrame.origin.y, width: curFrame.size.width, height: curFrame.size.height)
//		}
//
//		return curAttributes
//	}
//}
