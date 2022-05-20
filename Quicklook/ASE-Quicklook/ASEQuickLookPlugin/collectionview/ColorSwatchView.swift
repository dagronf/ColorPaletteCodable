//
//  ColorSwatchView.swift
//  ASEQuickLookPlugin
//
//  Created by Darren Ford on 17/5/2022.
//

import Cocoa

class ColorSwatchView: NSCollectionViewItem {
	var toolTip: String? {
		didSet {
			self.view.toolTip = toolTip
		}
	}
	var displayColor: CGColor? {
		didSet {
			self.view.layer!.backgroundColor = displayColor
			self.view.layer!.borderColor = NSColor.textColor.cgColor
			self.view.layer!.borderWidth = 1
		}
	}

	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		//self.view.wantsLayer = true
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		//self.view.wantsLayer = true
	}

	override func viewDidLayout() {
		super.viewDidLayout()
		self.view.effectiveAppearance.performAsCurrentDrawingAppearance {
			self.view.layer!.borderColor = NSColor.textColor.cgColor
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
