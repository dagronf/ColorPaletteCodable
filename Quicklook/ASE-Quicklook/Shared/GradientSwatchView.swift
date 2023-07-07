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
		//.shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.6), radius: 3, y: 1.5)
}
