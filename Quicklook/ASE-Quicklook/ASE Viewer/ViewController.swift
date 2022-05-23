//
//  ViewController.swift
//  Palette Viewer
//
//  Created by Darren Ford on 19/5/2022.
//

import Cocoa
import ColorPaletteCodable

import SwiftUI

class ViewController: NSViewController {

	let currentPalette = PaletteModel(nil)

	private lazy var hostedView: PaletteView = {
		PaletteView(paletteModel: self.currentPalette)
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


}

