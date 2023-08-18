//
//  ThumbnailProvider.swift
//  ASEPaletteThumbnailGenerator
//
//  Created by Darren Ford on 18/8/2023.
//

import QuickLookThumbnailing
import ColorPaletteCodable

class ThumbnailProvider: QLThumbnailProvider {

	override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
		guard
			let palette = try? PAL.Palette.Decode(from: request.fileURL)
		else {
			handler(nil, nil)
			return
		}

		// Second way: Draw the thumbnail into a context passed to your block, set up with Core Graphics's coordinate system.
		handler(QLThumbnailReply(contextSize: request.maximumSize, drawing: { (context) -> Bool in
			let maxWidth = request.maximumSize.width * request.scale
			let maxHeight = request.maximumSize.height * request.scale
			let maxSize = CGSize(width: maxWidth, height: maxHeight)

			let dimension: CGFloat = {
				if maxWidth < 100 { return 4 }
				if maxWidth < 150 { return 6 }
				return 8
			}()

			PAL.Image.DrawPaletteImage(
				palette: palette,
				context: context,
				size: maxSize,
				dimension: CGSize(width: dimension, height: dimension)
			)

			return true
		}), nil)
	}
}
