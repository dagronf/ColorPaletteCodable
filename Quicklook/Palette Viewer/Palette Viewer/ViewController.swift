//
//  ViewController.swift
//  Palette Viewer
//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Cocoa
import SwiftUI
import UniformTypeIdentifiers

import ColorPaletteCodable

class ViewController: NSViewController {

	let currentPalette = PaletteModel(nil)

	private lazy var hostedView: PaletteView = {
		PaletteView(title: self.currentPalette.palette?.name, paletteModel: self.currentPalette)
	}()

	override func loadView() {
		super.loadView()
		let containerView = self.view

		let nsView = NSHostingView(rootView: hostedView)

		containerView.addSubview(nsView)
		nsView.translatesAutoresizingMaskIntoConstraints = false
		nsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
		nsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
		nsView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
		nsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

		self.hostedView.paletteModel = currentPalette
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	//var exportAccessory: ExportTypeAccessoryViewController?

	@IBAction @objc func exportPalette(_ sender: Any) {
		guard 
			let window = self.view.window,
			let palette = self.currentPalette.palette
		else {
			return
		}
		let filename = palette.name.isEmpty ? "exported" : palette.name

		let savePanel = NSSavePanel()
		let vc = ExportTypeAccessoryViewController(owner: savePanel, ExportablePaletteUTTypes)

		// Store the export accessory inside the save panel so we don't have to manage it ourself
		objc_setAssociatedObject(savePanel, "accessory-view", vc, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

		savePanel.allowedContentTypes = ExportablePaletteUTTypes
		savePanel.accessoryView = vc.view
		savePanel.canCreateDirectories = true
		savePanel.isExtensionHidden = false
		savePanel.title = "Export palette"
		savePanel.nameFieldStringValue = filename
		savePanel.message = "Choose a folder and a name to store the palette"
		savePanel.nameFieldLabel = "Palette file name:"
		savePanel.beginSheetModal(for: window) { [weak self] response in
			guard response == .OK, let selectedURL = savePanel.url else {
				return
			}
			self?.performPaletteExport(url: selectedURL, selectedType: vc.selectedType)
		}
	}

	private func performPaletteExport(url: URL, selectedType: UTType) {
		if let palette = self.currentPalette.palette,
			let coder = PAL.Palette.coder(for: selectedType),
			let data = try? coder.encode(palette)
		{
			try? data.write(to: url)
		}
		//self.exportAccessory = nil
	}
}
