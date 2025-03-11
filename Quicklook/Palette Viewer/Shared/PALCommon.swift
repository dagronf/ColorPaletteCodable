//
//  PALCommon.swift
//  Palette Viewer
//
//  Created by Darren Ford on 21/8/2023.
//

import Foundation

import UniformTypeIdentifiers

public let ExportablePaletteTypes: [String] = [
	"public.dagronf.colorpalette",
	"public.xml",
	"com.adobe.aco",
	"com.adobe.ase",
	"com.adobe.act",
	"com.apple.color-file",
	"public.dagronf.gimp.gpl",
	"public.dagronf.corel.psppalette",
	"com.bohemiancoding.sketch.palette",
	"public.dagronf.palette.rgb",
	"public.dagronf.palette.rgba",
	"public.svg-image",
	"org.openoffice.palette",
	"public.dagronf.colorpalette.dcp",
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
