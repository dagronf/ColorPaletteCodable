//
//  GradientViewController.swift
//  Palette Viewer
//
//  Created by Darren Ford on 28/10/2022.
//

import AppKit
import ColorPaletteCodable

//class GradientViewController: NSViewController {
//
//	let gradientVC: PreviewViewController = {
//		PreviewViewController(nibName: nil, bundle: nil)
//	}()
//	var childView: NSView { gradientVC.view }
//
//	var gradients: PAL.Gradients? {
//		didSet {
//			self.gradientVC.gradients = self.gradients
//			self.gradientVC.rebuild()
//		}
//	}
//
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//
//		self.view.translatesAutoresizingMaskIntoConstraints = false
//
//		self.view.addSubview(childView)
//		self.view.addConstraint(NSLayoutConstraint(item: childView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
//		self.view.addConstraint(NSLayoutConstraint(item: childView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
//		self.view.addConstraint(NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))
//		self.view.addConstraint(NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0))
//	}
//}
