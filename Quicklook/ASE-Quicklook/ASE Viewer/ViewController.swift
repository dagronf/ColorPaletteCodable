//
//  ViewController.swift
//  ASE Viewer
//
//  Created by Darren Ford on 19/5/2022.
//

import Cocoa
import ASEPalette

class ViewController: NSViewController {

	var asePaletteVC: PreviewViewController?
	var palette: ASE.Palette? {
		didSet {
			asePaletteVC?.currentPalette.palette = palette
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		let vc = PreviewViewController()
		vc.loadView()
		
		let v = vc.view

		view.addSubview(v)

		view.addConstraint(NSLayoutConstraint(item: v, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: v, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: v, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: v, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))

		asePaletteVC = vc

		v.needsLayout = true
		view.needsLayout = true
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

