//
//  GradientsView.swift
//  ASE-Quicklook
//
//  Created by Darren Ford on 7/7/2023.
//

import SwiftUI
import ColorPaletteCodable
import SwiftUIFlowLayout

struct GradientsView: View {

	let gradients: PAL.Gradients

	@Binding var selectedGradient: UUID?

	var body: some View {
		VStack {
			ZStack {
				CheckerboardView()
				if gradients.count == 1 {
					GradientSwatchView(
						gradient: gradients.gradients.first!,
						cornerRadius: 16,
						selectedGradient: $selectedGradient
					)
					.padding(8)
				}
				else {
					VStack(spacing: 1) {
						HStack {
							Text("􀐜 \(gradients.count) gradient(s)")
								.font(.title2).fontWeight(.heavy)
								.truncationMode(.tail)
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding(4)
							.frame(maxWidth: .infinity)
						}
						.background(Rectangle().fill(.background))

						Divider()

						GeometryReader { geo in
							let dim: (Double, Double, Double) = {
								if geo.size.width < 220 {
									return (2, 24.0, 4)
								}
								if geo.size.width < 400 {
									return (4, 52.0, 6)
								}
								else {
									return (6, 96.0, 16)
								}
							}()

							ScrollView(.vertical, showsIndicators: true) {
								FlowLayout(
									mode: .scrollable,
									items: gradients.gradients,
									itemSpacing: dim.0
								) { gradient in
									GradientSwatchView(
										gradient: gradient,
										cornerRadius: dim.2,
										selectedGradient: $selectedGradient
									)
									.frame(width: dim.1, height: dim.1)
								}
								.padding(8)
							}
						}
					}
				}
			}
			.onTapGesture {
				selectedGradient = nil
			}
		}
	}
}

struct SingleGradient_Previews: PreviewProvider {
	static let gradient1 = PAL.Gradient(
		colorPositions: [
			(position: 0.0, color: PAL.Color.red),
			(position: 1.0, color: PAL.Color.white),
		],
		name: "Simple"
	)
	static var previews: some View {
		GradientSwatchView(gradient: Self.gradient1, cornerRadius: 16, selectedGradient: .constant(nil))
			.padding(20)
	}
}

struct MultipleGradients_Previews: PreviewProvider {

	static let dummy: PAL.Gradients = {
		let gradient1 = PAL.Gradient(
			colorPositions: [
				(position: 0.0, color: PAL.Color.red),
				(position: 1.0, color: PAL.Color.white),
			],
			name: "Simple")
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

	static var previews: some View {
		GradientsView(gradients: Self.dummy, selectedGradient: .constant(nil))
	}
}
