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

import Foundation

#if !os(Linux)
import ZIPFoundation
#endif

public extension PAL.Coder {
	/// A Procreate Swatch file encoder/decoder
	///
	/// * Does not support named colors (will be discarded on export)
	struct ProcreateSwatchesCoder: PAL_PaletteCoder {
		public let format: PAL.PaletteFormat = .swatches
		public let name = "Procreate Swatches"

		public let fileExtension = ["swatches"]
		public static let utTypeString = "public.dagronf.colorpalette.palette.procreate.swatches"
	}
}

#if !os(Linux)

public extension PAL.Coder.ProcreateSwatchesCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let data = inputStream.readAllData()

		let archive = try Archive(data: data, accessMode: .read)
		guard let entry = archive["Swatches.json"] else {
			throw PAL.CommonError.invalidFormat
		}

		var jsonData = Data()
		let _ = try archive.extract(entry) { data in
			jsonData.append(data)
		}

		let swatches: [_SwatchPalette]

		do {
			// Could be an array of swatch palettes
			swatches = try JSONDecoder().decode([_SwatchPalette].self, from: jsonData)
		}
		catch {
			do {
				// Could also be single swatch palette
				let s = try JSONDecoder().decode(_SwatchPalette.self, from: jsonData)
				swatches = [s]
			}
		}

		var result = PAL.Palette(format: .swatches)

		swatches.forEach { palette in
			let groupColors = palette.swatches
				.compactMap { $0 }
				.map { color in
					var c = PAL.Color(hf: color.hue, sf: color.saturation, bf: color.brightness, name: color.name ?? "")
					c.alpha = color.alpha
					return c
				}
			let group = PAL.Group(colors: groupColors, name: palette.name)
			result.groups.append(group)
		}
		return result
	}

	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		/// If there's no colors, then throw an error
		if palette.totalColorCount == 0 {
			throw PAL.CommonError.tooFewColors
		}

		// Map each group in the palette
		let groups = [PAL.Group(colors: palette.colors, name: palette.name)] + palette.groups

		let mapped: [_SwatchPalette] = try groups.compactMap { group in
			if group.colors.count == 0 {
				// Don't bother adding empty groups
				return nil
			}
			return _SwatchPalette(
				name: group.name,
				swatches: try group.colors.map {
					let hsb = try $0.hsb()
					return _SwatchPalette.Swatch(hue: hsb.hf, saturation: hsb.sf, brightness: hsb.bf, alpha: hsb.af)
				}
			)
		}

		let data = try JSONEncoder().encode(mapped)

		let archive = try Archive(accessMode: .create)
		try archive.addEntry(
			with: "Swatches.json",
			type: .file,
			uncompressedSize: Int64(data.count),
			compressionMethod: .deflate
		) { (position: Int64, size: Int) in
			data.subdata(in: Data.Index(position)..<Int(position)+size)
		}

		guard let archiveData = archive.data else {
			throw PAL.CommonError.cannotGenerateOutputZip
		}
		return archiveData
	}
}

#else
public extension PAL.Coder.ProcreateSwatchesCoder {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		throw PAL.CommonError.notImplemented
	}
	/// Encode the palette
	/// - Parameter palette: The palette to encode
	/// - Returns: The encoded representation  of the palette
	func encode(_ palette: PAL.Palette) throws -> Data {
		throw PAL.CommonError.notImplemented
	}
}
#endif

// MARK: - UTType identifiers

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
@available(macOS 11, iOS 14, tvOS 14, watchOS 7, *)
public extension UTType {
	static let procreateSwatches = UTType(PAL.Coder.ProcreateSwatchesCoder.utTypeString)!
}
#endif

// MARK: - JSON structure

private struct _SwatchPalette: Codable {
	struct Swatch: Codable {
		let name: String?
		let hue: Double
		let saturation: Double
		let brightness: Double
		let alpha: Double
		let colorSpace: Int?

		let origin: Int?
		let colorModel: Int?
		let colorProfile: String?
		let version: String?
		let components: [Double]?

		init(name: String? = nil, hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) {
			self.name = name
			self.hue = hue
			self.saturation = saturation
			self.brightness = brightness
			self.alpha = alpha

			self.colorSpace = nil
			self.origin = nil
			self.colorModel = nil
			self.colorProfile = nil
			self.version = nil
			self.components = [hue, saturation, brightness]
		}

		init(from decoder: any Decoder) throws {
			let container: KeyedDecodingContainer<_SwatchPalette.Swatch.CodingKeys> = try decoder.container(keyedBy: _SwatchPalette.Swatch.CodingKeys.self)
			self.name = try container.decodeIfPresent(String.self, forKey: _SwatchPalette.Swatch.CodingKeys.name)
			self.hue = try container.decode(Double.self, forKey: _SwatchPalette.Swatch.CodingKeys.hue)
			self.saturation = try container.decode(Double.self, forKey: _SwatchPalette.Swatch.CodingKeys.saturation)
			self.brightness = try container.decode(Double.self, forKey: _SwatchPalette.Swatch.CodingKeys.brightness)
			self.alpha = try container.decodeIfPresent(Double.self, forKey: _SwatchPalette.Swatch.CodingKeys.alpha) ?? 1.0
			self.colorSpace = try container.decodeIfPresent(Int.self, forKey: _SwatchPalette.Swatch.CodingKeys.colorSpace) ?? 0
			self.origin = try container.decodeIfPresent(Int.self, forKey: _SwatchPalette.Swatch.CodingKeys.origin)
			self.colorModel = try container.decodeIfPresent(Int.self, forKey: _SwatchPalette.Swatch.CodingKeys.colorModel)
			self.colorProfile = try container.decodeIfPresent(String.self, forKey: _SwatchPalette.Swatch.CodingKeys.colorProfile)
			self.version = try container.decodeIfPresent(String.self, forKey: _SwatchPalette.Swatch.CodingKeys.version)
			self.components = try container.decodeIfPresent([Double].self, forKey: _SwatchPalette.Swatch.CodingKeys.components)
		}
	}

	struct ColorProfile: Codable {
		let colorSpace: Int
		let hash: String
		let iccName: String
		let iccData: String

		init(from decoder: any Decoder) throws {
			let container: KeyedDecodingContainer<_SwatchPalette.ColorProfile.CodingKeys> = try decoder.container(keyedBy: _SwatchPalette.ColorProfile.CodingKeys.self)
			self.colorSpace = try container.decode(Int.self, forKey: _SwatchPalette.ColorProfile.CodingKeys.colorSpace)
			self.hash = try container.decode(String.self, forKey: _SwatchPalette.ColorProfile.CodingKeys.hash)
			self.iccName = try container.decode(String.self, forKey: _SwatchPalette.ColorProfile.CodingKeys.iccName)
			self.iccData = try container.decode(String.self, forKey: _SwatchPalette.ColorProfile.CodingKeys.iccData)
		}
	}

	let name: String
	let swatches: [_SwatchPalette.Swatch?]
	let colorProfiles: [_SwatchPalette.ColorProfile]?

	init(name: String, swatches: [_SwatchPalette.Swatch]) {
		self.name = name
		self.swatches = swatches
		self.colorProfiles = nil
	}

	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.swatches = try container.decode([_SwatchPalette.Swatch?].self, forKey: .swatches)
		self.colorProfiles = try container.decodeIfPresent([_SwatchPalette.ColorProfile].self, forKey: .colorProfiles)
	}
}

