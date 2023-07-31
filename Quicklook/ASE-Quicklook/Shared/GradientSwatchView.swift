//
//  GradientSwatchView.swift
//  ASE-Quicklook
//
//  Created by Darren Ford on 9/7/2023.
//

import Foundation
import SwiftUI
import ColorPaletteCodable

struct GradientSwatchView: View {
	let gradient: PAL.Gradient
	let cornerRadius: Double
	@Binding var selectedGradient: UUID?

	var isSelected: Bool { selectedGradient == gradient.id }

	var body: some View {

		Button {
			selectedGradient = gradient.id
		} label: {
			ZStack {
				RoundedRectangle(cornerRadius: cornerRadius)
					.fill(
						LinearGradient(
							gradient: gradient.SwiftUIGradient()!,
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						)
					)
					.mask {
						LinearGradient(
							gradient: gradient.SwiftUITransparencyGradient(),
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						)
					}
					.help(gradient.name ?? "<unnamed>")

				RoundedRectangle(cornerRadius: cornerRadius)
					.strokeBorder(isSelected ? Color.accentColor : Color(white: 0.4), lineWidth: isSelected ? 4 : 1)
					.animation(.linear(duration: 0.1), value: isSelected)
			}
		}
		.buttonStyle(.borderless)
	}
}

struct GradientSwatchView_Previews: PreviewProvider {
	static let gradient1 = PAL.Gradient(name: "Simple", colorPositions: [
		(position: 0.0, color: PAL.Color.red),
		(position: 1.0, color: PAL.Color.white),
	])
	static let gradient2 = PAL.Gradient(
		stops: [
			PAL.Gradient.Stop(position: 0, color: .red),
			PAL.Gradient.Stop(position: 0.5, color: .green),
			PAL.Gradient.Stop(position: 1, color: .blue),
		],
		transparencyStops: [
			PAL.Gradient.TransparencyStop(position: 0, value: 1),
			PAL.Gradient.TransparencyStop(position: 0.199, value: 1),
			PAL.Gradient.TransparencyStop(position: 0.2, value: 0),
			PAL.Gradient.TransparencyStop(position: 0.4, value: 1),
			PAL.Gradient.TransparencyStop(position: 1, value: 1),
		]
	)
	static var previews: some View {
		HStack() {
			GradientSwatchView(gradient: Self.gradient1, cornerRadius: 16, selectedGradient: .constant(nil))
				.frame(width: 100, height: 100)
			GradientSwatchView(gradient: Self.gradient2, cornerRadius: 16, selectedGradient: .constant(nil))
				.frame(width: 100, height: 100)
		}
		.padding(8)
	}
}
