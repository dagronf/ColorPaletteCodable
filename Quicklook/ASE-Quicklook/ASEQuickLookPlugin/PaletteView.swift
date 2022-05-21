//
//  PaletteView.swift
//  ASE-Quicklook
//
//  Created by Darren Ford on 22/5/2022.
//

import SwiftUI
import ASEPalette
import SwiftUIFlowLayout

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
		VStack(alignment: .leading, spacing: 0)
		{
			HStack(spacing: 4) {
				Text("􀐠")
					.foregroundColor(Color(NSColor.disabledControlTextColor.cgColor))
					.font(.title3)
					.fontWeight(.semibold)
				Text(name)
					.font(.title3)
					.fontWeight(.semibold)
			}
			.padding(4)
			FlowLayout(mode: .scrollable,
						  items: colors,
						  itemSpacing: 1)
			{ item in
				ZStack {
					RoundedRectangle(cornerRadius: 4)
						.fill(Color(cgColor: item.cgColor ?? .clear))
						.shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 0.5)
					RoundedRectangle(cornerRadius: 4)
						.stroke(Color(NSColor.disabledControlTextColor.cgColor), lineWidth: 1)
				}
				.frame(width: 26, height: 26)
			}
			.padding(EdgeInsets(top: 0, leading: 26, bottom: 4, trailing: 4))

			Divider()
				.padding(EdgeInsets(top: 4, leading: 6, bottom: -4, trailing: 6))
		}
	}
}

extension View {
	  public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
			let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
			return clipShape(roundedRect)
				  .overlay(roundedRect.strokeBorder(content, lineWidth: width))
	  }
 }

#if DEBUG

let _display: ASE.Palette = {
	return try! ASE.Palette(
		rgbColors: [
			ASE.RGB(1.0, 0, 0),
			ASE.RGB(0, 1.0, 0),
			ASE.RGB(0, 0, 1.0)
		],
		groups: [
			ASE.RGBGroup(name: "one", [
				ASE.RGB(0, 0, 1.0),
				ASE.RGB(0, 1.0, 0),
				ASE.RGB(1.0, 0, 0)
			]),
			ASE.RGBGroup(name: "two is the second one", [
				ASE.RGB(0.5, 0, 1),
				ASE.RGB(0, 0.8, 0.3),
				ASE.RGB(0.1, 0.3, 1.0),
				ASE.RGB(000, 000, 000),
				ASE.RGB(153, 000, 000),
				ASE.RGB(102, 085, 085),
				ASE.RGB(221, 017, 017),
			])
		]
	)
}()

private var model = PaletteModel(_display)

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
