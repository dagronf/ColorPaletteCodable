//
//  GradientInteractorView.swift
//  Palette Viewer
//
//  Created by Darren Ford on 7/7/2023.
//

import SwiftUI
import ColorPaletteCodable

struct GradientsInteractorView: View {
	let gradients: PAL.Gradients

	let parent: GradientDocument?

	@State var palette = PaletteModel(PAL.Palette())
	@State var selectedGradient: UUID? = nil

	var selected: PAL.Gradient? {
		guard let s = selectedGradient else { return nil }
		return gradients.find(id: s)
	}

	var body: some View {
		HSplitView {
			GradientsView(
				gradients: gradients,
				selectedGradient: $selectedGradient
			)
			.layoutPriority(1)
			VStack {
				if let s = selected {
					ScrollView {
						VStack(spacing: 20) {
							GradientTransparencyView(gradient: s)
							GradientColorListView(gradient: s)
						}
					}
					.frame(minWidth: 250)
				}
				else {
					ZStack {
						Rectangle()
							.fill(.regularMaterial)
						Text("No selection").font(.headline)
					}
				}
			}
		}.toolbar {
			ToolbarItem(placement: .automatic) {
				  Button(action: toggleSidebar, label: { // 1
						Image(systemName: "sidebar.leading")
				  })
			 }
		}
		.onAppear {
			updatePalette()
			if gradients.count > 0 {
				// Select the first one by default
				selectedGradient = gradients.gradients[0].id
			}
		}
		.onChange(of: selectedGradient) { newValue in
			updatePalette()
			parent?.selectedGradient = selectedGradient
		}
	}

	func updatePalette() {
		if let s = selectedGradient, let gradient = gradients.find(id: s) {
			palette = PaletteModel(gradient.palette)
		}
		else {
			palette = PaletteModel(PAL.Palette())
		}
	}

	private func toggleSidebar() { // 2
		 NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
	}
}

#if DEBUG

private let dummy: PAL.Gradients = {
	let gradient1 = PAL.Gradient(name: "Simple", colorPositions: [
		(position: 0.0, color: PAL.Color.red),
		(position: 1.0, color: PAL.Color.white),
	])
	let gradient2 = PAL.Gradient(name: "Parrot!", colorPositions: [
		(position: 0.0, color: PAL.Color.blue),
		(position: 0.5, color: PAL.Color.green),
		(position: 0.75, color: PAL.Color.yellow),
		(position: 1.0, color: PAL.Color.black),
	])
	return PAL.Gradients(gradients: [gradient1, gradient2])
}()

struct GradientsInteractorView_Previews: PreviewProvider {
	static var previews: some View {
		GradientsInteractorView(gradients: dummy, parent: nil, selectedGradient: dummy.gradients[0].id)
	}
}

struct GradientsInteractorViewNoSelection_Previews: PreviewProvider {
	static var previews: some View {
		GradientsInteractorView(gradients: dummy, parent: nil, selectedGradient: nil)
	}
}

#endif
