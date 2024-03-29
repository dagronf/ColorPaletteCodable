//
//  ViewController.swift
//  Palette Viewer
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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
import ColorPaletteCodable

import SwiftUI

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

	@IBAction @objc func exportSwift(_ sender: Any) {

	}
}

