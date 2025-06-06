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
			VStack(spacing: 1) {
				Text("􀪫 Properties")
					.font(.title2).fontWeight(.heavy)
					.truncationMode(.tail)
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(4)
					.background(Rectangle().fill(.background))
				Divider()
				if let s = selected {
					ScrollView {
						VStack(alignment: .leading, spacing: 16) {
							VStack {
								Text("Gradient (\(s.stops.count) stops)")
									.font(.title3).fontWeight(.heavy)
									.frame(maxWidth: .infinity, alignment: .leading)
									.padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
									.background(RoundedRectangle(cornerRadius: 4).fill(.separator))
								GradientComponentView(gradient: s)
									.frame(height: 84)
									.padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
							}

							VStack {
								GradientColorListView(gradient: s)
									.frame(minWidth: 300, minHeight: 200)
								if s.hasTransparency {
									VStack {
										if let ts = s.transparencyStops {
											Text("Transparency (\(ts.count) stops)")
												.font(.title3).fontWeight(.heavy)
												.frame(maxWidth: .infinity, alignment: .leading)
												.padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
												.background(RoundedRectangle(cornerRadius: 4).fill(.separator))
										}
										else {
											Text("Transparency map")
												.font(.title3).fontWeight(.heavy)
												.frame(maxWidth: .infinity, alignment: .leading)
												.padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
												.background(RoundedRectangle(cornerRadius: 4).fill(.separator))
										}
										GradientTransparencyView(gradient: s)
										GradientTransparencyStopsListView(gradient: s)
											.frame(minWidth: 300, minHeight: 200)
									}
								}
							}
						}
						.padding(4)
					}
					.frame(minWidth: 310)
				}
				else {
					ZStack {
						Rectangle()
							.fill(.regularMaterial)
						Text("No selection").font(.headline)
					}
				}
			}
		}
		.onAppear {
			updatePalette()
			if gradients.count > 0 {
				// Select the first one by default
				selectedGradient = gradients.gradients[0].id
			}
		}
		.onChange(of: selectedGradient) { _, newValue in
			updatePalette()
			parent?.selectedGradient = selectedGradient
		}
	}

	func updatePalette() {
		if
			let s = self.selectedGradient,
			let gradient = gradients.find(id: s),
			let gradientPalette = try? gradient.palette()
		{
			self.palette = PaletteModel(gradientPalette)
		}
		else {
			self.palette = PaletteModel(PAL.Palette())
		}
	}

	private func toggleSidebar() { // 2
		 NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
	}
}

#if DEBUG

private let dummy: PAL.Gradients = {
	let gradient1 = PAL.Gradient(
		stops: [
			PAL.Gradient.Stop(position: 0.0, color: PAL.Color.red),
			PAL.Gradient.Stop(position: 1.0, color: PAL.Color.white),
		],
		transparencyStops: [
			PAL.Gradient.TransparencyStop(position: 0, value: 1),
			PAL.Gradient.TransparencyStop(position: 0.3, value: 0.3),
			PAL.Gradient.TransparencyStop(position: 1, value: 1),
		],
		name: "Simple"
	)

	let gradient2 = PAL.Gradient(
		colorPositions: [
			(position: 0.0, color: PAL.Color.blue),
			(position: 0.5, color: PAL.Color.green),
			(position: 0.75, color: PAL.Color.yellow),
			(position: 1.0, color: PAL.Color.black),
		],
		name: "Parrot!"
	)
	return PAL.Gradients(gradients: [gradient1, gradient2])
}()

struct GradientsInteractorView_Previews: PreviewProvider {
	static var previews: some View {
		GradientsInteractorView(gradients: dummy, parent: nil, selectedGradient: dummy.gradients[0].id)
			.frame(height: 600)
	}
}

struct GradientsInteractorViewNoSelection_Previews: PreviewProvider {
	static var previews: some View {
		GradientsInteractorView(gradients: dummy, parent: nil, selectedGradient: nil)
			.frame(height: 600)
	}
}

#endif
