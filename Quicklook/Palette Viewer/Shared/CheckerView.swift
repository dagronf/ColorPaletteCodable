//
//  CheckerView.swift
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

import Foundation
import AppKit

class CheckerView: NSView {

	var checkerboardLayer: CheckerboardLayer { self.layer as! CheckerboardLayer }
	var color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 0.01) {
		didSet {
			self.checkerboardLayer.color0 = self.color0
			self.layer?.needsDisplay()
		}
	}
	var color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0.03) {
		didSet {
			self.checkerboardLayer.color1 = self.color1
			self.layer?.needsDisplay()
		}
	}

	var width: Double = 20 {
		didSet {
			self.checkerboardLayer.width = Float(self.width)
			self.layer?.needsDisplay()
		}
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	private func setup() {
		self.wantsLayer = true
		self.translatesAutoresizingMaskIntoConstraints = false
		self.layer = CheckerboardLayer()

		self.checkerboardLayer.color0 = self.color0
		self.checkerboardLayer.color1 = self.color1
	}
}

import CoreImage.CIFilterBuiltins

class CheckerboardLayer: CALayer {

	private let filter = CIFilter.checkerboardGenerator()
	private let context = CIContext(options: nil)

	var color0: CIColor = CIColor(red: 1, green: 1, blue: 1, alpha: 0.01) { didSet { self.filter.color0 = color0; self.needsDisplay() } }
	var color1: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0.03) { didSet { self.filter.color1 = color1; self.needsDisplay() } }
	var width: Float = 20 { didSet { self.filter.width = width; self.needsDisplay() } }

	override init() {
		super.init()
		self.syncSettings()
	}

	private func syncSettings() {
		self.filter.color0 = color0
		self.filter.color1 = color1
		self.filter.width = width
	}

	override init(layer: Any) {
		if let l = layer as? CheckerboardLayer {
			self.color0 = l.color0
			self.color1 = l.color1
			self.width = l.width
			super.init()
		}
		else {
			fatalError()
		}
	}

	required init?(coder: NSCoder) {
		fatalError()
	}

	override func layoutSublayers() {
		super.layoutSublayers()
		CATransaction.setDisableActions(true)
		if let newIm = self.filter.outputImage {
			let cgImage = self.context.createCGImage(newIm, from: self.bounds)
			self.contents = cgImage
		}
	}
}


#if canImport(SwiftUI)

import SwiftUI

struct CheckerboardView: NSViewRepresentable {
	let dimension: Double
	let color0: CGColor?
	let color1: CGColor?

	init(dimension: Double = 20, color0: CGColor? = nil, color1: CGColor? = nil) {
		self.dimension = dimension
		self.color0 = color0
		self.color1 = color1
	}

	func makeNSView(context: Context) -> CheckerView {
		let v = CheckerView()
		v.width = self.dimension

		if let c0 = self.color0 {
			v.color0 = CIColor(cgColor: c0)
		}
		if let c1 = self.color1 {
			v.color1 = CIColor(cgColor: c1)
		}

		return v
	}

	func updateNSView(_ nsView: CheckerView, context: Context) {

	}

	typealias NSViewType = CheckerView
}

#endif
