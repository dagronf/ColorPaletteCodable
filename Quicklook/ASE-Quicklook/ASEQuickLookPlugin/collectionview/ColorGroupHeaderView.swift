//
//  ColorGroupHeaderView.swift
//  ASEQuickLookPlugin
//
//  Created by Darren Ford on 17/5/2022.
//

import Cocoa

class ColorGroupHeaderView: NSView {

	@IBOutlet var groupNameTextField: NSTextField!
	@IBOutlet var separator: NSBox!

	var showSeparator: Bool = true {
		didSet {
			self.separator.isHidden = !showSeparator
		}
	}
}
