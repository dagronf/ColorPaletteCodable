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
		ScrollView {
			Grid(verticalSpacing: 4) {
				GridRow {
					Text("Color")
						.bold()
					Text("Pos")
						.help("Position")
						.gridCellAnchor(.leading)
						.bold()
					Text("CS")
						.help("Colorspace")
						.gridCellAnchor(.leading)
						.bold()
					Text("Components")
						.help("Color components")
						.gridCellAnchor(.leading)
						.bold()
				}
				ForEach(gradient.stops) { stop in
					Rectangle()
						.foregroundColor( Color.secondary.opacity(0.3) )
						.frame(height: 0.5)
					GridRow {
						GradientColorSwatch(color: stop.color)
							.frame(width: 26, height: 26)
							.onDrag {
								guard let c = stop.color.nsColor else {
									return NSItemProvider()
								}
								return NSItemProvider(item: c, typeIdentifier: UTType.nsColor.identifier)
							}
						Text(String(format: "%0.03f", stop.position))
							.font(.callout)
							.textSelection(.enabled)
							.monospacedDigit()
							.gridCellAnchor(.leading)
						Text(stop.color.colorSpace.rawValue)
							.font(.callout)
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
		.frame(maxHeight: 300)
		.padding(4)
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
				ScrollView {
					Grid(verticalSpacing: 4) {
						GridRow {
							Text("Value").bold()
							Text("Position").bold()
							Text("Opacity").bold()
							Text("")
						}
						ForEach(tmap) { stop in
							Rectangle()
								.foregroundColor( Color.secondary.opacity(0.3) )
								.frame(height: 0.5)
							GridRow {
								GradientColorSwatch(color: Color.red.opacity(stop.value))
									.frame(width: 26, height: 26)
								Text(String(format: "%0.03f", stop.position))
									.font(.callout)
									.textSelection(.enabled)
									.monospacedDigit()
									.gridCellAnchor(.leading)
								Text(String(format: "%0.03f", stop.value))
									.font(.callout)
									.textSelection(.enabled)
									.monospacedDigit()
									.gridCellAnchor(.leading)
								Text("")
									.frame(maxWidth: .infinity)
							}
						}
					}
				}
				.frame(maxHeight: 300)
			}
			else {
				EmptyView()
			}
		}
		.padding(4)
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
