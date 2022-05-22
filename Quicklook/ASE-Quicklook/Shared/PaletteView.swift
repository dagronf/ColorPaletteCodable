//
//  PaletteView.swift
//  ASE-Quicklook
//
//  Created by Darren Ford on 22/5/2022.
//

import SwiftUI
import SwiftUIFlowLayout
import UniformTypeIdentifiers

import ASEPalette

class PaletteModel: ObservableObject {
	@Published var palette: ASE.Palette?
	init(_ palette: ASE.Palette?) {
		self.palette = palette
	}
}

struct PaletteView: View {
	@ObservedObject var paletteModel: PaletteModel

	var body: some View {
		ScrollView(.vertical) {
			if let p = paletteModel.palette {
				if p.colors.count > 0 {
					GroupingView(name: "Global colors", colors: p.colors)
				}
				ForEach(p.groups) { group in
					GroupingView(name: group.name, colors: group.colors)
				}
			}
		}
	}
}

struct GroupingView: View {
	let name: String
	let colors: [ASE.Color]
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {

			HStack(spacing: 4) {
				Text("􀐠")
					.font(.title3)
					.fontWeight(.semibold)
				Text("\(name) (\(colors.count))")
					.font(.title3)
					.fontWeight(.semibold)
			}
			.padding(4)

			FlowLayout(mode: .scrollable,
						  items: colors,
						  itemSpacing: 1) {
				ColorView(color: $0)
					.frame(width: 26, height: 26)
			}
			.padding(EdgeInsets(top: 0, leading: 8, bottom: 4, trailing: 8))

			Divider()
				.padding(EdgeInsets(top: 4, leading: 8, bottom: -4, trailing: 8))
		}
	}
}

struct ColorView: View {
	let color: ASE.Color
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 4)
				.fill(Color(cgColor: color.cgColor ?? .clear))
				.shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 0.5)
			RoundedRectangle(cornerRadius: 4)
				.stroke(Color(NSColor.disabledControlTextColor.cgColor), lineWidth: 1)
		}
		.help("Name: \(color.name)\nMode: \(color.modelString)\nType: \(color.typeString)")
		.onDrag {
			if let c = color.nsColor {
				return NSItemProvider(item: c, typeIdentifier: UTType.nsColor.identifier)
			}
			return NSItemProvider()
		} preview: {
			ColorTooltipView(color: color)
		}
	}
}

struct ColorTooltipView: View {
	let color: ASE.Color
	var body: some View {
		HStack {
			ColorView(color: color)
				.frame(width: 20, height: 20)
			VStack(alignment: .leading, spacing: 1) {
				Text("Name: \(color.name)").font(.caption2)
				Text("Mode: \(color.modelString)").font(.caption2)
				Text("Type: \(color.typeString)").font(.caption2)
			}
		}
		.padding(4)
	}
}

// MARK: - Previews

#if DEBUG

let _display: ASE.Palette = {
	try! ASE.Palette(
		rgbColors: [
			ASE.RGB(1.0, 0, 0),
			ASE.RGB(0, 1.0, 0),
			ASE.RGB(0, 0, 1.0),
		],
		groups: [
			ASE.RGBGroup(name: "one", [
				ASE.RGB(0, 0, 1.0),
				ASE.RGB(0, 1.0, 0),
				ASE.RGB(1.0, 0, 0),
			]),
			ASE.RGBGroup(name: "two is the second one", [
				ASE.RGB(0.5, 0, 1),
				ASE.RGB(0, 0.8, 0.3),
				ASE.RGB(0.1, 0.3, 1.0),
				ASE.RGB(000, 000, 000),
				ASE.RGB(153, 000, 000),
				ASE.RGB(102, 085, 085),
				ASE.RGB(221, 017, 017),
			]),
		]
	)
}()

private var model = PaletteModel(_display)

struct ColorTooltipView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ColorTooltipView(color: try! ASE.Color(name: "red", model: .RGB, colorComponents: [1, 0, 0]))
		}
	}
}

struct ColorView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			HStack {
				ColorView(color: try! ASE.RGB(1.0, 0, 1.0).color())
					.frame(width: 26, height: 26)
				ColorView(color: try! ASE.RGB(0.0, 1.0, 1.0).color())
					.frame(width: 26, height: 26)
				ColorView(color: try! ASE.RGB(1.0, 1.0, 0.0).color())
					.frame(width: 26, height: 26)
			}
			.preferredColorScheme(.dark)

			HStack {
				ColorView(color: try! ASE.RGB(1.0, 0, 1.0).color())
					.frame(width: 26, height: 26)
				ColorView(color: try! ASE.RGB(0.0, 1.0, 1.0).color())
					.frame(width: 26, height: 26)
				ColorView(color: try! ASE.RGB(1.0, 1.0, 0.0).color())
					.frame(width: 26, height: 26)
			}
			.preferredColorScheme(.light)
		}
		.padding(4)
	}
}

struct PaletteView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			PaletteView(paletteModel: model)
				.preferredColorScheme(.dark)
			PaletteView(paletteModel: model)
				.preferredColorScheme(.light)
		}
		.frame(height: 250)
	}
}

#endif
