//
//  GradientViewController.swift
//  Palette Viewer
//
//  Created by Darren Ford on 28/10/2022.
//

import Cocoa

//import SwiftUI
//import GradientEditorUI

class GradientViewController: NSViewController {

	@IBOutlet weak var gradientEditorContainer: NSView!

//	lazy var hostedView: GradientEditor = {
//		GradientEditor(
//			startPoint: UnitPoint.bottomLeading,
//			endPoint: UnitPoint.topTrailing,
//			stops: [
//				GradientStop(isMovable: false, unit: 0, color: CGColor(gray: 0, alpha: 1)),
//				GradientStop(isMovable: false, unit: 1, color: CGColor(gray: 1, alpha: 1))
//			]
//		)
//	}()
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		// Do view setup here.
//
//		let content = NSHostingView<GradientEditor>(rootView: hostedView)
//
//		gradientEditorContainer.addSubview(content)
//
//		content.translatesAutoresizingMaskIntoConstraints = false
//		content.leadingAnchor.constraint(equalTo: gradientEditorContainer.leadingAnchor, constant: 8).isActive = true
//		content.trailingAnchor.constraint(equalTo: gradientEditorContainer.trailingAnchor, constant: -8).isActive = true
//		content.topAnchor.constraint(equalTo: gradientEditorContainer.topAnchor, constant: 4).isActive = true
//		content.bottomAnchor.constraint(equalTo: gradientEditorContainer.bottomAnchor, constant: -4).isActive = true
//
//	}

}


//struct GradientEditor: View {
//
//	@State var startPoint: UnitPoint = UnitPoint.bottomLeading
//	@State var endPoint: UnitPoint = UnitPoint.topTrailing
//	@State var stops: [GradientStop] = [
//		GradientStop(isMovable: false, unit: 0, color: CGColor(gray: 0, alpha: 1)),
//		GradientStop(isMovable: false, unit: 1, color: CGColor(gray: 1, alpha: 1))
//	]
//
//	var body: some View {
//		GradientFlatLinearEditorView(
//			startPoint: $startPoint,
//			endPoint: $endPoint,
//			stops: $stops
//		)
//	}
//}
