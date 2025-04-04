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

func exportGradient(_ gradient: PAL.Gradient) throws {
	let flattened = try gradient.mergeTransparencyStops()
	let toEncode = PAL.Gradients(gradients: [flattened])
	let filename = (gradient.name ?? "exported")

	let savePanel = NSSavePanel()
	let vc = ExportTypeAccessoryViewController(owner: savePanel, ExportableGradientUTTypes)

	// Store the export accessory inside the save panel so we don't have to manage it ourself
	objc_setAssociatedObject(savePanel, "accessory-view", vc, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

	savePanel.allowedContentTypes = ExportableGradientUTTypes
	savePanel.canCreateDirectories = true
	savePanel.isExtensionHidden = false
	savePanel.title = "Save gradient"
	savePanel.nameFieldStringValue = filename
	savePanel.message = "Choose a folder and a name to store the gradient."
	savePanel.nameFieldLabel = "Gradient file name:"

	savePanel.accessoryView = vc.view

	let response = savePanel.runModal()
	if response == .OK {
		if let coder = PAL.Gradients.coder(for: vc.selectedType),
			let data = try? coder.encode(toEncode)
		{
			try? data.write(to: savePanel.url!)
		}
	}
}

func exportPalette(_ gradient: PAL.Gradient) throws {

	let palette = try gradient.palette()

	let filename = (gradient.name ?? "exported")

	//let supportedTypes: [UTType] = [.jsonColorPalette, .gimpPalette, .aco, .clr]

	let savePanel = NSSavePanel()
	savePanel.allowedContentTypes = ExportablePaletteUTTypes
	savePanel.canCreateDirectories = true
	savePanel.isExtensionHidden = false
	savePanel.title = "Save palette"
	savePanel.nameFieldStringValue = filename
	savePanel.message = "Choose a folder and a name to store the palette."
	savePanel.nameFieldLabel = "Palette file name:"

	let vc = ExportTypeAccessoryViewController(owner: savePanel, ExportablePaletteUTTypes)
	savePanel.accessoryView = vc.view

	let response = savePanel.runModal()
	if response == .OK {
		if let coder = PAL.Palette.coder(for: vc.selectedType) {
			let data = try coder.encode(palette)
			try data.write(to: savePanel.url!)
		}
	}
}

struct GradientSwatchView: View {
	let gradient: PAL.Gradient
	let cornerRadius: Double
	@Binding var selectedGradient: UUID?

	@State var showSavePanel = false

	var isSelected: Bool { selectedGradient == gradient.id }

	var filename: String {
		(gradient.name ?? "exported")
	}

	var uniqueFilename: String {
		(gradient.name ?? "gradient") + "_" + gradient.id.uuidString
	}

	func generateGradientData() throws -> Data {
		let flattened = try gradient.mergeTransparencyStops()
		return try PAL.Gradients.Coder.GIMPGradientCoder().encode(PAL.Gradients(gradients: [flattened]))
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
				try? exportGradient(gradient)
			}
			Button("Export Palette…") {
				try? exportPalette(gradient)
			}
		})
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

struct GradientSwatchView_Previews: PreviewProvider {
	static let gradient1 = PAL.Gradient(
		colorPositions: [
			(position: 0.0, color: PAL.Color.red),
			(position: 1.0, color: PAL.Color.white),
		],
		name: "Simple"
	)
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
