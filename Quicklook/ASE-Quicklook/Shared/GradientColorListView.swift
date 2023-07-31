//
//  GradientColorListView.swift
//  Palette Viewer
//
//  Created by Darren Ford on 31/7/2023.
//

import SwiftUI
import UniformTypeIdentifiers
import ColorPaletteCodable

struct GradientColorListView: View {
	let gradient: PAL.Gradient

	var body: some View {
		VStack {
			Text("􀦳 Color Positions")
				.font(.title2).fontWeight(.heavy)
				.truncationMode(.tail)
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(4)
				.background(Rectangle().fill(.background))

			Grid(verticalSpacing: 4) {
				GridRow {
					Text("Color")
						.bold()
					Text("Pos")
						.gridCellAnchor(.leading)
						.bold()
					Text("Name")
						.gridCellAnchor(.leading)
						.bold()
				}
				ForEach(gradient.stops) { stop in
					Rectangle()
						.foregroundColor( Color.secondary.opacity(0.3) )
						.frame(height: 0.5)
					GridRow {
						ZStack {
							Path { path in
								path.move(to: .zero)
								path.addLine(to: CGPoint(x: 26, y: 26))
								path.addLine(to: CGPoint(x: 0, y: 26))
							}
							.fill(Color.secondary)
							.mask {
								RoundedRectangle(cornerRadius: 4)
							}
							RoundedRectangle(cornerRadius: 4)
								.fill(stop.color.SwiftUIColor ?? .clear)
							RoundedRectangle(cornerRadius: 4)
								.stroke(.secondary)
						}
						.frame(width: 26, height: 26)
						.onDrag {
							guard let c = stop.color.nsColor else {
								return NSItemProvider()
							}
							return NSItemProvider(item: c, typeIdentifier: UTType.nsColor.identifier)
						}
						Text(String(format: "%0.04f", stop.position))
							.monospacedDigit()
							.gridCellAnchor(.leading)
						Text("\(stop.color.name)")
							.gridCellAnchor(.leading)
							.frame(maxWidth: .infinity)
					}
				}
				RoundedRectangle(cornerRadius: 1)
					.foregroundColor( Color.secondary.opacity(0.3) )
					.frame(height: 0.5)
			}
			.padding(4)
		}
	}
}

struct GradientColorListView_Previews: PreviewProvider {
	
	static let gradient1: PAL.Gradient = {
		var g = PAL.Gradient(name: "Simple", colorPositions: [
			(position: 0.0, color: try! PAL.Color.green.withAlpha(0.5)),
			(position: 0.4, color: PAL.Color.yellow),
			(position: 0.7, color: PAL.Color.blue),
			(position: 1.0, color: PAL.Color.white),
		])
		g.transparencyStops = [
			PAL.Gradient.TransparencyStop(position: 0, value: 1, midpoint: 0.5),
			PAL.Gradient.TransparencyStop(position: 0.5, value: 0, midpoint: 0.5),
			PAL.Gradient.TransparencyStop(position: 1, value: 1, midpoint: 0.5)
		]
		return g
	}()
	static var previews: some View {
		GradientColorListView(gradient: Self.gradient1)
			.frame(width: 250)
			.padding(4)
	}
}
