//
//  File.swift
//
//
//  Created by Darren Ford on 23/5/2022.
//

import Foundation

/// A simple RGB(A) plain text file importer
///
/// Format of the form
/// ```
/// #fcfc80
/// #fcfc80
/// #fcf87c
/// #fcf87c
/// #fcf478
/// #f8f478
/// ```

internal struct RGBPaletteCoder: PaletteCoder {
	var fileExtension = "rgb"
	func read(_ inputStream: InputStream) throws -> ASE.Palette {
		let data = inputStream.readAllData()
		guard let text = String(data: data, encoding: .utf8) else {
			throw ASE.CommonError.unableToLoadFile
		}
		let lines = text.split(separator: "\n")
		var palette = ASE.Palette()
		try lines.forEach { line in
			let l = line.trimmingCharacters(in: CharacterSet.whitespaces)

			if l.isEmpty {
				// Skip over empty lines
				return
			}

			do {
				// Try with rgba, and if it throws try rgb
				let color = try ASE.Color(rgbaHexString: l)
				palette.colors.append(color)
			}
			catch {
				// Try with rgb
				let color = try ASE.Color(rgbHexString: l)
				palette.colors.append(color)
			}
		}
		return palette
	}

	func data(for palette: ASE.Palette) throws -> Data {
		var result = ""
		for color in palette.colors {
			if !result.isEmpty { result += "\n" }
			guard let h = color.hexRGB else {
				throw ASE.CommonError.unsupportedColorSpace
			}
			result += h
		}
		guard let d = result.data(using: .utf8) else {
			throw ASE.CommonError.unsupportedColorSpace
		}
		return d
	}
}


internal struct RGBAPaletteCoder: PaletteCoder {
	var fileExtension = "rgba"
	func read(_ inputStream: InputStream) throws -> ASE.Palette {
		let data = inputStream.readAllData()
		guard let text = String(data: data, encoding: .utf8) else {
			throw ASE.CommonError.unableToLoadFile
		}
		let lines = text.split(separator: "\n")
		var palette = ASE.Palette()
		try lines.forEach { line in
			let l = line.trimmingCharacters(in: CharacterSet.whitespaces)

			if l.isEmpty {
				// Skip over empty lines
				return
			}

			do {
				// Try with rgba, and if it throws try rgb
				let color = try ASE.Color(rgbaHexString: l)
				palette.colors.append(color)
			}
			catch {
				// Fallback to trying RGB with alpha 1
				let color = try ASE.Color(rgbHexString: l)
				palette.colors.append(color)
			}
		}
		return palette
	}

	func data(for palette: ASE.Palette) throws -> Data {
		var result = ""
		for color in palette.colors {
			if !result.isEmpty { result += "\n" }
			guard let h = color.hexRGBA else {
				throw ASE.CommonError.unsupportedColorSpace
			}
			result += h
		}
		guard let d = result.data(using: .utf8) else {
			throw ASE.CommonError.unsupportedColorSpace
		}
		return d
	}
}
