@testable import ColorPaletteCodable
import Foundation
import XCTest

/// Locate the URL for the specified resource name
func resourceURL(for name: String) throws -> URL {
	let core = try XCTUnwrap(URL(string: name))
	let extn = core.pathExtension
	let name = core.deletingPathExtension().path
	return try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: extn))
}

/// Load a palette from the resources
func loadResourcePalette(named name: String) throws -> PAL.Palette {
	let paletteURL = try resourceURL(for: name)
	return try PAL.LoadPalette(paletteURL)
}

/// Load a gradient from the resources
func loadResourceGradient(named name: String) throws -> PAL.Gradients {
	let gradientURL = try resourceURL(for: name)
	return try PAL.LoadGradient(gradientURL)
}

/// Load data from a resource file
func loadResourceData(named name: String) throws -> Data {
	let dataURL = try resourceURL(for: name)
	return try Data(contentsOf: dataURL)
}
