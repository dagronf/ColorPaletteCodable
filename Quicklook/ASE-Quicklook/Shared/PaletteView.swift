//
//  PaletteView.swift
//  ASE-Quicklook
//
//  Created by Darren Ford on 22/5/2022.
//

#if os(macOS)

import SwiftUI
import SwiftUIFlowLayout
import UniformTypeIdentifiers

import ColorPaletteCodable

class PaletteModel: ObservableObject {
	@Published var palette: PAL.Palette?
	init(_ palette: PAL.Palette?) {
		self.palette = palette
	}
}

struct PaletteView: View {
	@ObservedObject var paletteModel: PaletteModel

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			if let name = paletteModel.palette?.name, name.count > 0 {
				Text("􀦳 \(name)")
					.font(.title2).fontWeight(.heavy)
					.padding(4)
			}
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
}

struct GroupingView: View {
	let name: String
	let colors: [PAL.Color]
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
	let color: PAL.Color
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 4)
				.fill(Color(cgColor: color.cgColor ?? .clear))
				.shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 0.5)
			RoundedRectangle(cornerRadius: 4)
				.stroke(Color(NSColor.disabledControlTextColor.cgColor), lineWidth: 1)
		}
		.help("Name: \(color.name)\nMode: \(color.colorSpace.rawValue)\nType: \(color.colorType.rawValue)")
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
	let color: PAL.Color
	var body: some View {
		HStack {
			ColorView(color: color)
				.frame(width: 20, height: 20)
			VStack(alignment: .leading, spacing: 1) {
				Text("Name: \(color.name)").font(.caption2)
				Text("Mode: \(color.colorSpace.rawValue)").font(.caption2)
				Text("Type: \(color.colorType.rawValue)").font(.caption2)
			}
		}
		.padding(4)
	}
}

// MARK: - Previews

#if DEBUG

let _display: PAL.Palette = {
	PAL.Palette(
		name: "My Colors",
		colors: [
			PAL.Color.rgb(1.0, 0, 0),
			PAL.Color.rgb(0, 1.0, 0),
			PAL.Color.rgb(0, 0, 1.0),
		],
		groups: [
			PAL.Group(name: "one", colors: [
				PAL.Color.rgb(0, 0, 1.0),
				PAL.Color.rgb(0, 1.0, 0),
				PAL.Color.rgb(1.0, 0, 0),
			]),
			PAL.Group(name: "two is the second one", colors: [
				PAL.Color.rgb(0.5, 0, 1),
				PAL.Color.rgb(0, 0.8, 0.3),
				PAL.Color.rgb(0.1, 0.3, 1.0),
				PAL.Color.rgb(0, 0, 0),
				PAL.Color.rgb(153 / 255.0, 0, 0),
				PAL.Color.rgb(102 / 255.0, 085 / 255.0, 085 / 255.0),
				PAL.Color.rgb(221 / 255.0, 017 / 255.0, 017 / 255.0),
			]),
		]
	)
}()

private var colorSpace = PaletteModel(_display)

struct ColorTooltipView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ColorTooltipView(color: try! PAL.Color(name: "red", colorSpace: .RGB, colorComponents: [1, 0, 0]))
		}
	}
}

struct ColorView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			HStack {
				ColorView(color: PAL.Color.rgb(1.0, 0, 1.0))
					.frame(width: 26, height: 26)
				ColorView(color: PAL.Color.rgb(0.0, 1.0, 1.0))
					.frame(width: 26, height: 26)
				ColorView(color: PAL.Color.rgb(1.0, 1.0, 0.0))
					.frame(width: 26, height: 26)
			}
			.preferredColorScheme(.dark)

			HStack {
				ColorView(color: PAL.Color.rgb(1.0, 0, 1.0))
					.frame(width: 26, height: 26)
				ColorView(color: PAL.Color.rgb(0.0, 1.0, 1.0))
					.frame(width: 26, height: 26)
				ColorView(color: PAL.Color.rgb(1.0, 1.0, 0.0))
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
			PaletteView(paletteModel: colorSpace)
				.preferredColorScheme(.dark)
			PaletteView(paletteModel: colorSpace)
				.preferredColorScheme(.light)
		}
		.frame(height: 250)
	}
}

struct PALColorView_Previews: PreviewProvider {
	static var previews: some View {
		HStack {
			PAL.Color.rgb(1, 0, 0).SwiftUIColor!
				.frame(width: 25, height: 25)
			PAL.Color.rgb(1, 1, 0).SwiftUIColor!
				.frame(width: 25, height: 25)
			PAL.Color.rgb(1, 0, 1).SwiftUIColor!
				.frame(width: 25, height: 25)
		}
	}
}

#endif

#endif
