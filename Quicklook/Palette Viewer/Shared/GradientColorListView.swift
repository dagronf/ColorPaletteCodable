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
		Table(gradient.stops) {
			TableColumn("") { stop in
				GradientColorSwatch(color: stop.color)
					.frame(width: 26, height: 26)
					.draggable(stop.color)
//					.onDrag {
//						guard let c = stop.color.nsColor else {
//							return NSItemProvider()
//						}
//						return NSItemProvider(item: c, typeIdentifier: UTType.systemColor.identifier)
//					}
			}
			.width(30)
			.alignment(.center)

			TableColumn("Pos") { stop in
				Text(String(format: "%0.03f", stop.position))
					.font(.callout)
					.textSelection(.enabled)
					.monospacedDigit()
			}
			.width(40)

			TableColumn("CS") { stop in
				Text(stop.color.colorSpace.rawValue)
					.font(.callout)
			}
			.width(40)

			TableColumn("Components") { stop in
				Text(stop.color.componentsString())
					.font(.callout)
					.textSelection(.enabled)
					.monospacedDigit()
					.gridCellAnchor(.leading)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
	}
}

struct GradientColorSwatch: View {
	let color: SwiftUI.Color

	init(color: PAL.Color) {
		self.color = color.SwiftUIColor ?? .primary
	}

	init(color: SwiftUI.Color) {
		self.color = color
	}

	var body: some View {
		GeometryReader { geo in
			ZStack {
				Path { path in
					path.move(to: .zero)
					path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
					path.addLine(to: CGPoint(x: 0, y: geo.size.height))
				}
				.fill(Color.secondary)
				.mask {
					RoundedRectangle(cornerRadius: 4)
				}
				RoundedRectangle(cornerRadius: 4)
					.fill(color)
				RoundedRectangle(cornerRadius: 4)
					.stroke(.secondary)
			}
		}
	}
}

struct GradientColorSwatch_Previews: PreviewProvider {
	static var previews: some View {
		Grid {
			GridRow {
				GradientColorSwatch(color: PAL.Color.red)
					.frame(width: 26, height: 26)
				GradientColorSwatch(color: PAL.Color.green)
					.frame(width: 26, height: 26)
				GradientColorSwatch(color: PAL.Color.blue)
					.frame(width: 26, height: 26)
			}
			GridRow {
				GradientColorSwatch(color: try! PAL.Color.red.withAlpha(0.4))
					.frame(width: 26, height: 26)
				GradientColorSwatch(color: try! PAL.Color.green.withAlpha(0.4))
					.frame(width: 26, height: 26)
				GradientColorSwatch(color: try! PAL.Color.blue.withAlpha(0.4))
					.frame(width: 26, height: 26)
			}
		}
		.padding(8)
	}
}


struct GradientColorListView_Previews: PreviewProvider {
	
	static let gradient1: PAL.Gradient = {
		var g = PAL.Gradient(
			colorPositions: [
				(position: 0.0, color: try! PAL.Color.green.withAlpha(0.5)),
				(position: 0.4, color: PAL.Color.yellow),
				(position: 0.7, color: PAL.Color.blue),
				(position: 1.0, color: PAL.Color.white),
			],
			name: "Simple"
		)
		g.transparencyStops = [
			PAL.Gradient.TransparencyStop(position: 0, value: 1, midpoint: 0.5),
			PAL.Gradient.TransparencyStop(position: 0.5, value: 0, midpoint: 0.5),
			PAL.Gradient.TransparencyStop(position: 1, value: 1, midpoint: 0.5)
		]
		return g
	}()
	static var previews: some View {
		GradientColorListView(gradient: Self.gradient1)
			.frame(width: 400)
			.padding(4)
	}
}

//////

struct GradientTransparencyStopsListView: View {
	let gradient: PAL.Gradient

	var tmap: [PAL.Gradient.TransparencyStop] { gradient.transparencyMap }

	var body: some View {
		Group {
			if gradient.hasTransparency {
				Table(tmap) {
					TableColumn("Value") { stop in
						GradientColorSwatch(color: Color.red.opacity(stop.value))
							.frame(width: 26, height: 26)
					}
					.width(40)
					.alignment(.center)

					TableColumn("Position") { stop in
						Text(String(format: "%0.03f", stop.position))
							.font(.callout)
							.textSelection(.enabled)
							.monospacedDigit()
					}
					.width(60)

					TableColumn("Opacity") { stop in
						Text(String(format: "%0.03f", stop.value))
							.font(.callout)
							.textSelection(.enabled)
							.monospacedDigit()
					}
					.width(60)
				}
			}
			else {
				EmptyView()
			}
		}
	}
}

struct GradientTransparencyStopsListView_Previews: PreviewProvider {

	static let gradient1: PAL.Gradient = {
		var g = PAL.Gradient(
			colorPositions: [
				(position: 0.0, color: try! PAL.Color.green.withAlpha(0.5)),
				(position: 0.4, color: PAL.Color.yellow),
				(position: 0.7, color: PAL.Color.blue),
				(position: 1.0, color: PAL.Color.white),
			],
			name: "Simple"
		)
		g.transparencyStops = [
			PAL.Gradient.TransparencyStop(position: 0, value: 1, midpoint: 0.5),
			PAL.Gradient.TransparencyStop(position: 0.2, value: 0.3, midpoint: 0.5),
			PAL.Gradient.TransparencyStop(position: 0.5, value: 0, midpoint: 0.5),
			PAL.Gradient.TransparencyStop(position: 1, value: 1, midpoint: 0.5)
		]
		return g
	}()
	static var previews: some View {
		GradientTransparencyStopsListView(gradient: Self.gradient1)
			.frame(width: 400)
			.padding(4)
	}
}
