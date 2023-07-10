//
//  PAL+Palette+platform.swift
//
//  Created by Darren Ford on 16/5/2022.
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#if canImport(CoreGraphics)

import Foundation
import CoreGraphics

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public extension PAL.Palette {

	/// Import a palette by retrieving the unique pixel colors in the first row of the image
	/// - Parameters:
	///   - fileURL: The file URL for the image to import
	///   - accuracy: The color accuracy for determining unique values
	/// - Returns: A palette
	static func importFromImage(_ fileURL: URL, accuracy: Double = 0.001) throws -> PAL.Palette {

		#if os(macOS)
		let image = NSImage(contentsOf: fileURL)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
		#else
		let data = try Data(contentsOf: fileURL)
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

			func isMostlyEqualTo(p2: Pixel?, accuracy: Double = 0.001) -> Bool {
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

		let palcols = try unique.map {
			try PAL.Color(
				rf: Float32($0.r),
				gf: Float32($0.g),
				bf: Float32($0.b),
				af: Float32($0.a)
			)
		}
		return PAL.Palette(colors: palcols)
	}

}

#endif

