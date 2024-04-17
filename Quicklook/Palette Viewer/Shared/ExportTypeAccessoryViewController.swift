//
//  ExportTypeAccessoryViewController.swift
//  Palette Viewer
//
//  Created by Darren Ford on 18/8/2023.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

class ExportTypeAccessoryViewController: NSViewController {
	let exportTypes: [UTType]
	weak var savePanel: NSSavePanel?

	init(owner: NSSavePanel, _ allowedExportTypes: [UTType]) {
		assert(allowedExportTypes.count > 0)
		self.savePanel = owner
		self.exportTypes = allowedExportTypes
		self.selectedType = allowedExportTypes[0]
		super.init(nibName: nil, bundle: nil)
	}

	var selectedType: UTType

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		let root = NSView()
		root.translatesAutoresizingMaskIntoConstraints = false

		let base = NSStackView()
		base.orientation = .horizontal
		base.translatesAutoresizingMaskIntoConstraints = false

		let t = NSTextField(labelWithString: "Format: ")
		t.translatesAutoresizingMaskIntoConstraints = false
		base.addArrangedSubview(t)

		let b = NSPopUpButton()
		b.translatesAutoresizingMaskIntoConstraints = false
		b.action = #selector(formatDidChange(_:))
		b.target = self
		b.removeAllItems()

		self.exportTypes.forEach { type in
			let desc = type.localizedDescription ?? type.description
			if let extn = type.preferredFilenameExtension {
				b.addItem(withTitle: "\(desc) (*.\(extn))")
			}
			else {
				b.addItem(withTitle: "\(desc)")
			}
		}

		base.addArrangedSubview(b)

		root.addSubview(base)
		base.leadingAnchor.constraint(greaterThanOrEqualTo: root.leadingAnchor).isActive = true
		base.centerXAnchor.constraint(equalTo: root.centerXAnchor).isActive = true
		base.topAnchor.constraint(equalTo: root.topAnchor, constant: 20).isActive = true
		base.centerYAnchor.constraint(equalTo: root.centerYAnchor).isActive = true

		self.view = root
	}

	@IBAction func formatDidChange(_ sender: NSPopUpButton) {
		let index = sender.indexOfSelectedItem
		self.selectedType = self.exportTypes[index]
		self.savePanel?.allowedContentTypes = [ self.selectedType ]
	}
}
