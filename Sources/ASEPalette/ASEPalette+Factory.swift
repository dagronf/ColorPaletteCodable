//
//  File.swift
//  
//
//  Created by Darren Ford on 23/5/2022.
//

import Foundation

extension ASE.Palette {
	enum ColorSpace {
		case RGB
		case CMYK
		case Gray
		case LAB
	}
}

public protocol PaletteCoder {

	var fileExtension: String { get }

	func read(_ inputStream: InputStream) throws -> ASE.Palette

	func data(for palette: ASE.Palette) throws -> Data
}

extension PaletteCoder {
	/// Load from the contents of a fileURL
	func load(fileURL: URL) throws -> ASE.Palette {
		guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
			throw ASE.CommonError.unableToLoadFile
		}
		inputStream.open()
		return try read(inputStream)
	}

	/// Load from data
	func load(data: Data) throws -> ASE.Palette {
		let inputStream = InputStream(data: data)
		inputStream.open()
		return try read(inputStream)
	}

	/// Return the pal
	func data(_ palette: ASE.Palette) throws -> Data {
		return try data(for: palette)
	}
}


public extension ASE {

	class Factory {

		public static let shared = ASE.Factory()

		var engines: [PaletteCoder] = [
			ACOPaletteCoder(),
			ASEPaletteCoder(),
			CLRPaletteCoder()
		]

		public let ase: PaletteCoder = ASEPaletteCoder()
		public let aco: PaletteCoder = ACOPaletteCoder()
		public let clr: PaletteCoder = CLRPaletteCoder()

		public func coder(for fileExtension: String) -> PaletteCoder? {
			let fileExt = fileExtension.lowercased()
			return engines.first(where: { fileExt == $0.fileExtension } )
		}

		/// Load from the contents of a fileURL
		public func load(fileURL: URL) throws -> ASE.Palette {
			guard let inputStream = InputStream(fileAtPath: fileURL.path) else {
				throw ASE.CommonError.unableToLoadFile
			}
			return try load(fileExtension: fileURL.pathExtension, inputStream: inputStream)
		}

		/// Load from data
		public func load(fileExtension: String, data: Data) throws -> ASE.Palette {
			let inputStream = InputStream(data: data)
			return try load(fileExtension: fileExtension, inputStream: inputStream)
		}

		/// Load from an inputstream
		public func load(fileExtension: String, inputStream: InputStream) throws -> ASE.Palette {
			let fileExt = fileExtension.lowercased()
			guard let engine = engines.first(where: { fileExt == $0.fileExtension } ) else {
				throw ASE.CommonError.unsupportedPaletteType
			}
			inputStream.open()
			return try engine.read(inputStream)
		}

		public func data(_ palette: ASE.Palette, _ fileExtension: String) throws -> Data {
			let fileExt = fileExtension.lowercased()
			guard let engine = engines.first(where: { fileExt == $0.fileExtension } ) else {
				throw ASE.CommonError.unsupportedPaletteType
			}
			return try engine.data(for: palette)
		}
	}
}
