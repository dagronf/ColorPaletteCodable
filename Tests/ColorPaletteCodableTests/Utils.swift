@testable import ColorPaletteCodable
import Foundation
import XCTest

/// Locate the URL for the specified resource name
func resourceURL(for name: String) throws -> URL {
	let encoded = try XCTUnwrap(name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))
	let core = try XCTUnwrap(URL(string: encoded))
	let extn = core.pathExtension
	let name = core.deletingPathExtension().path
	return try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: extn))
}

/// Return the data for the fileURL's content
func dataURL(for name: String) throws -> Data {
	let fileURL = try resourceURL(for: name)
	return try Data(contentsOf: fileURL)
}

/// Load a palette from the resources
func loadResourcePalette(named name: String) throws -> PAL.Palette {
	let paletteURL = try resourceURL(for: name)
	return try PAL.Palette(paletteURL)
}

/// Load a palette from the resources, forcing the use of a specific coder
func loadResourcePalette(named name: String, using coder: PAL_PaletteCoder) throws -> PAL.Palette {
	let paletteURL = try resourceURL(for: name)
	return try PAL.Palette(paletteURL, usingCoder: coder)
}

/// Load a gradient from the resources
func loadResourceGradient(named name: String) throws -> PAL.Gradients {
	let gradientURL = try resourceURL(for: name)
	return try PAL.Gradients(gradientURL)
}

/// Load data from a resource file
func loadResourceData(named name: String) throws -> Data {
	let dataURL = try resourceURL(for: name)
	return try Data(contentsOf: dataURL)
}

// MARK: - Color equality checker

func AreAllColorsEqual(_ a: [PAL.Color], _ b: [PAL.Color], precision: UInt = 5) -> Bool {
	guard a.count == b.count else {
		Swift.print("mismatched color count")
		return false
	}

	var success: Bool = true

	zip(a, b).enumerated().forEach { item in
		if AreColorsEqual(item.element.0, b: item.element.1, precision: precision) == false {
			Swift.print("mismatched color at `\(item.offset)`")
			success = false
		}
	}
	return success
}

func AreColorsEqual(_ a: PAL.Color, b: PAL.Color, precision: UInt = 5) -> Bool {

	guard a.name == b.name else {
		Swift.print("mismatched color name `\(a.name)` -> `\(b.name)`")
		return false
	}

	guard a.colorSpace == b.colorSpace else {
		Swift.print("mismatched colorspace `\(a.colorSpace)` -> `\(b.colorSpace)`")
		return false
	}

	guard a.colorComponents.count == b.colorComponents.count else {
		Swift.print("mismatched color components `\(a.colorComponents.count)` -> `\(b.colorComponents.count)`")
		return false
	}

	var success = true

	zip(a.colorComponents, b.colorComponents).enumerated().forEach { item in
		if item.element.0.isEqual(to: item.element.1, precision: precision) == false {
			success = false
			Swift.print("mismatched color component \(item.offset): `\(item.element.0)` -> `\(item.element.1)`")
		}
	}

	return success
}


// MARK: - Output folder writer

class TestFilesContainer {

	// Note:  DateFormatter is thread safe
	// See https://developer.apple.com/documentation/foundation/dateformatter#1680059
	private static let iso8601Formatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX ISO8601
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HHmmssZ"
		return dateFormatter
	}()

	private let root: Subfolder
	var rootFolder: URL { self.root.folder }
	init(named name: String) throws {
		let baseURL = FileManager.default
			.temporaryDirectory
			.appendingPathComponent(name)
		let url = baseURL.appendingPathComponent(Self.iso8601Formatter.string(from: Date()))
		try? FileManager.default.removeItem(at: url)
		try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		self.root = Subfolder(url)
		Swift.print("TestContainer(\(name) - Generated files at: \(url)")

		let latest = baseURL.appendingPathComponent("_latest")
		try? FileManager.default.removeItem(at: latest)
		try! FileManager.default.createSymbolicLink(at: latest, withDestinationURL: url)
	}

	func subfolder(with components: String...) throws -> Subfolder {
		var subfolder = self.rootFolder
		components.forEach { subfolder.appendPathComponent($0) }
		try FileManager.default.createDirectory(at: subfolder, withIntermediateDirectories: true)
		return Subfolder(subfolder)
	}

	class Subfolder {
		let folder: URL

		init(_ parent: URL) {
			self.folder = parent
		}
		init(named name: String, parent: URL) throws {
			let subf = parent.appendingPathComponent(name)
			try FileManager.default.createDirectory(at: subf, withIntermediateDirectories: true)
			self.folder = subf
		}

		func subfolder(with components: String...) throws -> Subfolder {
			var subfolder = self.folder
			components.forEach { subfolder.appendPathComponent($0) }
			try FileManager.default.createDirectory(at: subfolder, withIntermediateDirectories: true)
			return Subfolder(subfolder)
		}

		@discardableResult func write(
			_ data: Data,
			to file: String
		) throws -> URL {
			let tempURL = self.folder.appendingPathComponent(file)
			try data.write(to: tempURL)
			return tempURL
		}

		@discardableResult
		func write(
			_ string: String,
			to file: String,
			encoding: String.Encoding = .utf8
		) throws -> URL {
			let tempURL = self.folder.appendingPathComponent(file)
			try string.write(to: tempURL, atomically: true, encoding: encoding)
			return tempURL
		}

		@discardableResult
		func write(_ colors: [PAL.Color], coder: PAL_PaletteCoder, filename: String) throws -> URL {
			try self.write(PAL.Palette(colors: colors), coder: coder, filename: filename)
		}

		@discardableResult
		func write(_ palette: PAL.Palette, coder: PAL_PaletteCoder, filename: String) throws -> URL {
			let data = try coder.encode(palette)
			let tempURL = self.folder.appendingPathComponent(filename)
			try data.write(to: tempURL)
			return tempURL
		}

		@discardableResult
		func write(_ gradient: PAL.Gradient, coder: PAL_GradientsCoder, filename: String) throws -> URL {
			let data = try coder.encode(gradient)
			let tempURL = self.folder.appendingPathComponent(filename)
			try data.write(to: tempURL)
			return tempURL
		}
	}
}
