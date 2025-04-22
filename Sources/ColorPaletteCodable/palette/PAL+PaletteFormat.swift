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

public extension PAL {
	/// Supported palette formats
	enum PaletteFormat: CaseIterable {
		case acb                // Adobe Color Book
		case aco                // Adobe Photoshop Swatch
		case act                // Adobe Color Tables
		case androidXML         // Android XML Palette file
		case ase                // Adobe Swatch Exchange
		case basicXML           // Basic XML palette format
		case clr                // macOS NSColorList
		case corelPainter       // Corel Painter Swatches
		case corelDraw          // CorelDraw XML
		case scribusXML         // Scribus XML swatches
		case corelPalette       // Corel Palette
		case csv                // CSV Palette
		case dcp                // ColorPaletteCodable binary format
		case gimp               // GIMP gpl format
		case hexRGBA            // Hex RGBA coded files
#if canImport(CoreGraphics)
		case image              // image-based palette coder
#endif
		case json               // ColorPaletteCodable binary format
		case openOffice         // OpenOffice palette format (.soc)
		case paintNET           // Paint.NET palette file (.txt)
		case paintShopPro       // Paint Shop Pro palette (.pal, .psppalette)
		case rgba               // RGBA encoded text files (.rgba, .txt)
		case rgb                // RGB encoded text files (.rgb, .txt)
		case riff               // Microsoft RIFF palette (.pal))
		case sketch             // Sketch palette file (.sketchpalette)
		case svg                // Scalable Vector Grapihcs palette (.svg)
		case swift              // (export only) Swift source file (.swift)
		case corelDrawV3        // Corel Draw V3 file (.pal)
		case clf                // LAB colors
		case swatches           // Procreate swatches
		case autodeskColorBook  // Autodesk Color Book (unencrypted only) (.acb)
		case simplePalette      // Simple Palette format
		case swatchbooker       // Swatchbooker .sbz file
		case afpalette          // Affinity Designer .afpalette file

		// This needs to go last, so it doesn't override the other PAL types
		case vga24bit      // 24-bit RGB VGA (3 bytes RRGGBB)
		case vga18bit      // 18-bit RGB VGA (3 bytes RRGGBB)
	}
}

public extension PAL.PaletteFormat {
	/// Create a new coder based on the format
	var coder: PAL_PaletteCoder {
		switch self {
		case .acb                : return PAL.Coder.ACB()
		case .aco                : return PAL.Coder.ACO()
		case .act                : return PAL.Coder.ACT()
		case .androidXML         : return PAL.Coder.AndroidColorsXML()
		case .ase                : return PAL.Coder.ASE()
		case .basicXML           : return PAL.Coder.BasicXML()
		case .clr                : return PAL.Coder.CLR()
		case .corelPainter       : return PAL.Coder.CorelPainter()
		case .corelDraw          : return PAL.Coder.CorelXMLPalette()
		case .scribusXML         : return PAL.Coder.ScribusXMLPaletteCoder()
		case .corelPalette       : return PAL.Coder.CPL()
		case .csv                : return PAL.Coder.CSV()
		case .dcp                : return PAL.Coder.DCP()
		case .gimp               : return PAL.Coder.GIMP()
		case .hexRGBA            : return PAL.Coder.HEX()
#if canImport(CoreGraphics)
		case .image              : return PAL.Coder.Image()
#endif
		case .json               : return PAL.Coder.JSON()
		case .openOffice         : return PAL.Coder.OpenOfficePaletteCoder()
		case .paintNET           : return PAL.Coder.PaintNET()
		case .paintShopPro       : return PAL.Coder.PaintShopPro()
		case .rgba               : return PAL.Coder.RGBA()
		case .rgb                : return PAL.Coder.RGB()
		case .riff               : return PAL.Coder.RIFF()
		case .sketch             : return PAL.Coder.SketchPalette()
		case .svg                : return PAL.Coder.SVG()
		case .swift              : return PAL.Coder.SwiftCoder()
		case .corelDrawV3        : return PAL.Coder.CorelDraw3PaletteCoder()
		case .vga24bit           : return PAL.Coder.VGA24BitPaletteCoder()
		case .vga18bit           : return PAL.Coder.VGA18BitPaletteCoder()
		case .clf                : return PAL.Coder.CLF()
		case .swatches           : return PAL.Coder.ProcreateSwatchesCoder()
		case .autodeskColorBook  : return PAL.Coder.AutodeskColorBook()
		case .simplePalette      : return PAL.Coder.SimplePaletteCoder()
		case .swatchbooker       : return PAL.Coder.SwatchbookerCoder()
		case .afpalette          : return PAL.Coder.AFPaletteCoder()
		}
	}
}

