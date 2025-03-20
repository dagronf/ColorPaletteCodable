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
]

public let ExportablePaletteUTTypes: [UTType] = {
	ExportablePaletteTypes.map { UTType($0)! }
}()


public let ExportableGradientTypes: [String] = [
	"public.dagronf.jsoncolorgradient",
	"public.dagronf.colorpalette.gradients",
	"public.dagronf.gimp.ggr",
	"public.svg-image",
	"public.dagronf.gnuplot.gpf",
	"public.dagronf.cpt",
]

public let ExportableGradientUTTypes: [UTType] = {
	ExportableGradientTypes.map { UTType($0)! }
}()
