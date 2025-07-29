//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#if canImport(CoreGraphics)

import SwiftImageReadWrite

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension PAL.Coder {
	/// A coder that handles loading a palette from an image (just the first row of the image)
	struct Image: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .image
		public let name = "Image"

		/// Supported import image types
		public let fileExtension = ["png", "jpeg", "jpg", "gif"]
		public static let utTypeString = "public.image"
		
		/// When importing, the accuracy when determining identical colors
		public let accuracy: Double

		/// The format to use when exporting a palette image
		public enum ExportType {
			/// A line of horizontal swatches
			case swatch(CGSize = .init(width: 32, height: 32))
			/// An image of size
			case image(CGSize)
		}

		/// When exporting, the image format
		public var exportType: ExportType
		/// When exporting, the type of image to generate
		public var exportImageType: SwiftImageReadWrite.ImageExportType

		/// Create a PNG coder/decoder
		/// - Parameters:
		///   - accuracy: When decoding, the accuracy required when matching colors
		///   - exportType: The type of export
		///   - exportImageType: When exporting, the type of image to generate
		public init(
			accuracy: Double = 0.001,
			exportType: ExportType = .swatch(),
			exportImageType: SwiftImageReadWrite.ImageExportType = .png()
		) {
			self.accuracy = accuracy
			self.exportType = exportType
			self.exportImageType = exportImageType
		}
	}
}

public extension PAL.Coder.Image {
	/// Decode a palette using the first row of a image
	/// - Parameter inputStream: The image data
	/// - Returns: A palette representing the unique colors in the image
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let data = inputStream.readAllData()
		var p = try __decode(data: data, accuracy: accuracy)
		p.format = self.format
		return p
	}
}

public extension PAL.Coder.Image {
	/// Export an image representation for the palette
	/// - Parameter palette: The palette
	/// - Returns: Raw image data
	func encode(_ palette: PAL.Palette) throws -> Data {
		let colors = palette.allColors()

		let swatchSize: CGSize = {
			switch self.exportType {
			case .swatch(let sz):
				return sz
			case .image(let sz):
				return CGSize(width: sz.width / CGFloat(colors.count), height: sz.height)
			}
		}()
		return try __encode(colors, swatchSize: swatchSize, exportImageType: exportImageType)
	}
}

// MARK: - Generic image decode

private func __decode(data: Data, accuracy: Double) throws -> PAL.Palette {
#if os(macOS)
	let image = NSImage(data: data)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
#else
	let image = UIImage(data: data)?.cgImage
#endif

	guard let image = image else {
		throw PAL.CommonError.invalidFormat
	}

	let dataSize = image.width * image.height * 4
	var pixelData = [UInt8](repeating: 0, count: Int(dataSize))

	let bi = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue

	guard
		let ctx = CGContext(
			data: &pixelData,
			width: image.width,
			height: image.height,
			bitsPerComponent: 8,
			bytesPerRow: image.width * 4,
			space: CGColorSpace(name: CGColorSpace.sRGB)!,
			bitmapInfo: bi
		)
	else {
		throw PAL.CommonError.invalidFormat
	}

	// Draw the image onto our known context
	ctx.draw(image, in: CGRect(origin: .zero, size: CGSize(width: image.width, height: image.height)))

	struct Pixel: Equatable {
		let r: Double
		let g: Double
		let b: Double
		let a: Double

		func isMostlyEqualTo(p2: Pixel?, accuracy: Double) -> Bool {
			guard let p2 = p2 else { return false }
			return abs(self.r - p2.r) <= accuracy
				&& abs(self.g - p2.g) <= accuracy
				&& abs(self.b - p2.b) <= accuracy
				&& abs(self.a - p2.a) <= accuracy
		}
	}

	// Loop through the pixels in the first row and gather the unique colors
	var unique = [Pixel]()
	stride(from: 0, to: image.width * 4, by: 4).forEach { index in
		// each 'pixel' is four bytes rgba
		let pixel = Array(pixelData[index ..< index + 4])
		let p = Pixel(
			r: Double(pixel[0]) / 255.0,
			g: Double(pixel[1]) / 255.0,
			b: Double(pixel[2]) / 255.0,
			a: Double(pixel[3]) / 255.0
		)
		if !p.isMostlyEqualTo(p2: unique.last, accuracy: accuracy) {
			unique.append(p)
		}
	}

	let palcols = unique.map {
		rgbf($0.r, $0.g, $0.b, $0.a)
	}
	return PAL.Palette(colors: palcols)
}

private func __encode(_ colors: [PAL.Color], swatchSize: CGSize, exportImageType: ImageExportType) throws -> Data {
	guard !colors.isEmpty else { throw PAL.CommonError.cannotCreateImage }

	let bi = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue

	let width = Int(swatchSize.width) * colors.count
	let height = Int(swatchSize.height)

	guard
		let ctx = CGContext(
			data: nil,
			width: width,
			height: height,
			bitsPerComponent: 8,
			bytesPerRow: width * 4,
			space: CGColorSpace(name: CGColorSpace.sRGB)!,
			bitmapInfo: bi
		)
	else {
		throw PAL.CommonError.invalidFormat
	}

	var offset: CGFloat = 0
	for color in colors {
		guard let cgcolor = color.cgColor else { throw PAL.CommonError.cannotCreateImage }
		let dest = CGRect(x: offset, y: 0, width: swatchSize.width, height: swatchSize.height)
		ctx.setFillColor(cgcolor)
		ctx.addPath(CGPath(rect: dest, transform: nil))
		ctx.fillPath()
		offset += swatchSize.width
	}

	guard let cgImage = ctx.makeImage() else {
		throw PAL.CommonError.cannotCreateImage
	}

	return try cgImage.imageData(for: exportImageType)
}

#endif
