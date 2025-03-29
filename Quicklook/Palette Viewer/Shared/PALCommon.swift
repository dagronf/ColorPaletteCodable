//
//  PALCommon.swift
//  Palette Viewer
//
//  Created by Darren Ford on 21/8/2023.
//

import Foundation
import UniformTypeIdentifiers

import ColorPaletteCodable

public let ExportablePaletteTypes: [String] = [
	PAL.Coder.JSON.utTypeString,
	PAL.Coder.ACO.utTypeString,
	PAL.Coder.ASE.utTypeString,
	PAL.Coder.ACT.utTypeString,
	PAL.Coder.CLR.utTypeString,
	PAL.Coder.GIMP.utTypeString,
	PAL.Coder.PaintShopPro.utTypeString,
	PAL.Coder.SketchPalette.utTypeString,
	PAL.Coder.ACO.utTypeString,
	PAL.Coder.RGBA.utTypeString,
	PAL.Coder.SVG.utTypeString,
	PAL.Coder.OpenOfficePaletteCoder.utTypeString,
	PAL.Coder.DCP.utTypeString,
	PAL.Coder.ProcreateSwatchesCoder.utTypeString,
]

public let ExportablePaletteUTTypes: [UTType] = {
	ExportablePaletteTypes.map { UTType($0)! }
}()


public let ExportableGradientTypes: [String] = [
	PAL.Gradients.Coder.JSON.utTypeString,
	PAL.Gradients.Coder.DCG.utTypeString, 
	PAL.Gradients.Coder.GIMPGradientCoder.utTypeString,
	PAL.Gradients.Coder.SVG.utTypeString,
	PAL.Gradients.Coder.GNUPlotGradientCoder.utTypeString,
	PAL.Gradients.Coder.ColorPaletteTablesCoder.utTypeString, 
]

public let ExportableGradientUTTypes: [UTType] = {
	ExportableGradientTypes.map { UTType($0)! }
}()
