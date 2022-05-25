//
//  File.swift
//  
//
//  Created by Darren Ford on 24/5/2022.
//

import DSFRegex
import Foundation

public extension PAL.Coder {
	struct GIMP: PAL_PaletteCoder {
		public let fileExtension = "gpl"
		public init() {}
	}
}

public extension PAL.Coder.GIMP {
	func decode(from inputStream: InputStream) throws -> PAL.Palette {
		let allData = inputStream.readAllData()
		guard let content = String(data: allData, encoding: .utf8) else {
			throw PAL.CommonError.invalidFormat
		}

		let lines = content.split(whereSeparator: \.isNewline)
		guard
			lines.count > 0,
			lines[0] == "GIMP Palette"
		else {
			throw PAL.CommonError.invalidFormat
		}

		var palette = PAL.Palette()

		let regex = try DSFRegex(#"^\s*(\d+)\s+(\d+)\s+(\d+)(.*)$"#)

		for line in lines.dropFirst() {
			if line.starts(with: "Name:") {
				//Name:  Web design
				let colorlistName = line.suffix(line.count - 5).trimmingCharacters(in: .whitespacesAndNewlines)
				if colorlistName.count > 0 {
					palette.name = colorlistName
				}
			}
			else if line.starts(with: "#") {
				continue
			}

			let lineStr = String(line)

			let searchResult = regex.matches(for: lineStr)

			for match in searchResult {
				let rs = lineStr[match.captures[0]]
				let gs = lineStr[match.captures[1]]
				let bs = lineStr[match.captures[2]]
				let ss = lineStr[match.captures[3]]

				guard
					let rv = Int(rs),
					let gv = Int(gs),
					let bv = Int(bs)
				else {
					continue
				}

				let sv = ss.trimmingCharacters(in: .whitespacesAndNewlines)

				let re = max(0, min(1, Float32(rv) / 255.0))
				let ge = max(0, min(1, Float32(gv) / 255.0))
				let be = max(0, min(1, Float32(bv) / 255.0))

				let c = try PAL.Color(name: sv, colorSpace: .RGB, colorComponents: [re, ge, be])
				palette.colors.append(c)
			}
		}
		return palette
	}
}

public extension PAL.Coder.GIMP {
	func encode(_ palette: PAL.Palette) throws -> Data {
		var result = "GIMP Palette\n"
		if !palette.name.isEmpty {
			result += "Name: \(palette.name)\n"
		}

		result += "#Colors: \(palette.colors.count)\n"
		for color in palette.colors {

			// Colors are RGB
			let rgb = try color.converted(to: .RGB)

			let rv = Int(min(255, max(0, rgb.colorComponents[0] * 255)).rounded(.towardZero))
			let gv = Int(min(255, max(0, rgb.colorComponents[1] * 255)).rounded(.towardZero))
			let bv = Int(min(255, max(0, rgb.colorComponents[2] * 255)).rounded(.towardZero))

			result += "\(rv)\t\(gv)\t\(bv)"
			if !rgb.name.isEmpty {
				result += "\t\(rgb.name)"
			}
			result += "\n"
		}
		guard let data = result.data(using: .utf8) else {
			throw PAL.CommonError.unsupportedColorSpace
		}

		return data
	}
}
