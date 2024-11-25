//
//  SketchPaletteCoder.swift
//
//  Copyright © 2024 Darren Ford. All rights reserved.
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

import Foundation

public extension PAL.Coder {
	/// .sketchpalette Sketch palette file
	struct SketchPalette: PAL_PaletteCoder {
		public let name = "Sketch Palette"
		public let fileExtension = ["sketchpalette"]
		public init() {}

		// com.bohemiancoding.sketch.drawing
	}
}

extension PAL.Coder.SketchPalette {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	public func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let data = inputStream.readAllData()
		let sketchFile = try JSONDecoder().decode(SketchFile.self, from: data)
		var palette = PAL.Palette()
		palette.colors = sketchFile.colors.compactMap { try? PAL.Color(rf: $0.red, gf: $0.green, bf: $0.blue, af: $0.alpha) }
		return palette
	}

	public func encode(_ palette: PAL.Palette) throws -> Data {
		// Flatten _all_ the colors in the palette (including global and group colors)
		let flattenedColors = palette.allColors()

		// Always write colors as RGBA for this format
		let colors = try flattenedColors
			.map { try $0.converted(to: .RGB) }
			.map { SketchColor(red: try $0.r(), green: try $0.g(), blue: try $0.b(), alpha: $0.alpha) }

		let file = SketchFile(
			compatibleVersion: "1.4",
			pluginVersion: "1.4",
			colors: colors
		)
		return try JSONEncoder().encode(file)
	}
}

////

private struct SketchColor: Codable {
	let red: Float32
	let green: Float32
	let blue: Float32
	let alpha: Float32
}

private struct SketchFile: Codable {
	let compatibleVersion: String
	let pluginVersion: String
	let colors: [SketchColor]

	init(compatibleVersion: String, pluginVersion: String, colors: [SketchColor]) {
		self.compatibleVersion = compatibleVersion
		self.pluginVersion = pluginVersion
		self.colors = colors
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.compatibleVersion = try container.decode(String.self, forKey: .compatibleVersion)
		self.pluginVersion = try container.decode(String.self, forKey: .pluginVersion)

		if let colors = try? container.decode([SketchColor].self, forKey: .colors) {
			self.colors = colors
		}
		else if let hexColors = try? container.decode([String].self, forKey: .colors) {
			let colors = try hexColors.compactMap { try PAL.Color(rgbaHexString: $0) }
				.compactMap { SketchColor(red: try $0.r(), green: try $0.g(), blue: try $0.b(), alpha: $0.alpha) }
			self.colors = colors
		}
		else {
			throw PAL.CommonError.invalidFormat
		}
	}
}

