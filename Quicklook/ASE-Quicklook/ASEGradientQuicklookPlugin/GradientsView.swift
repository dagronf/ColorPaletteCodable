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

	var body: some View {
		VStack {
			ZStack {
				CheckerboardView()
				if gradients.count == 1 {
					let gradient = gradients.gradients.first!
					RoundedRectangle(cornerRadius: 16)
						.fill(
							LinearGradient(
								gradient: gradient.SwiftUIGradient()!,
								startPoint: .topLeading,
								endPoint: .bottomTrailing
							)
						)
						.help(gradient.name ?? "<unnamed>")
						.padding(8)
				}
				else {
					VStack(spacing: 1) {
						Text("􀦳 \(gradients.count) gradient(s)")
							.font(.title2).fontWeight(.heavy)
							.truncationMode(.tail)
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(4)
							.background(Rectangle().fill(.background))
						Divider()
						GeometryReader { geo in
							let dim: (Double, Double, Double) = {
								if geo.size.width < 220 {
									return (4, 24.0, 4)
								}
								if geo.size.width < 400 {
									return (6, 52.0, 6)
								}
								else {
									return (8, 96.0, 16)
								}
							}()

							ScrollView(.vertical, showsIndicators: true) {
								FlowLayout(
									mode: .scrollable,
									items: gradients.gradients,
									itemSpacing: dim.0
								) { gradient in
									RoundedRectangle(cornerRadius: dim.2)
										.fill(
											LinearGradient(
												gradient: gradient.SwiftUIGradient()!,
												startPoint: .topLeading,
												endPoint: .bottomTrailing
											)
										)
										.frame(width: dim.1, height: dim.1)
										.help(gradient.name ?? "<unnamed>")
								}
								.shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.6), radius: 3, y: 1)
								.padding(8)
							}
						}
					}
				}
			}
		}
	}
}

struct GradientsView1_Previews: PreviewProvider {

	static let dummy: PAL.Gradients = {
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

	static var previews: some View {
		GradientsView(gradients: Self.dummy)
	}
}

struct GradientsView2_Previews: PreviewProvider {
	static let dummy: PAL.Gradients = {
		let gradient1 = PAL.Gradient(colorPositions: [
			(position: 0.0, color: PAL.Color.red),
			(position: 1.0, color: PAL.Color.white),
		])
		return PAL.Gradients(gradients: [gradient1])
	}()
	static var previews: some View {
		GradientsView(gradients: Self.dummy)
	}
}
