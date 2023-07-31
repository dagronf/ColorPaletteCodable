//
//  GradientSwatchView.swift
//  ASE-Quicklook
//
//  Created by Darren Ford on 9/7/2023.
//

import Foundation
import SwiftUI
import ColorPaletteCodable

import UniformTypeIdentifiers

struct GradientSwatchView: View {
	let gradient: PAL.Gradient
	let cornerRadius: Double
	@Binding var selectedGradient: UUID?

	var isSelected: Bool { selectedGradient == gradient.id }

	var filename: String {
		(gradient.name ?? "exported") + ".ggr"
	}

	var uniqueFilename: String {
		(gradient.name ?? "gradient") + "_" + gradient.id.uuidString + ".ggr"
	}

	func generateGradientData() throws -> Data {
		let flattened = try gradient.mergeTransparencyStops()
		return try PAL.Gradients.Coder.GGR().encode(PAL.Gradients(gradients: [flattened]))
	}

	func generateDragContent() -> URL {
		let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(uniqueFilename)
		let data = try! generateGradientData()
		try! data.write(to: url)
		return url
	}

	var body: some View {
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
		.focusable()
		.accessibilityAddTraits(.isButton)
		.onTapGesture {
			selectedGradient = gradient.id
		}
		.draggable(
			generateDragContent()
		)
		.contextMenu(menuItems: {
			Button("Export Gradient…") {
				let data = try! generateGradientData()
				let savePanel = NSSavePanel()
				savePanel.allowedContentTypes = [ UTType("public.dagronf.gimp.ggr")! ]
				savePanel.canCreateDirectories = true
				savePanel.isExtensionHidden = false
				savePanel.title = "Save gradient"
				savePanel.nameFieldStringValue = filename
				savePanel.message = "Choose a folder and a name to store the gradient."
				savePanel.nameFieldLabel = "Gradient file name:"

				let response = savePanel.runModal()
				if response == .OK {
					try? data.write(to: savePanel.url!)
				}
			}
		})
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
