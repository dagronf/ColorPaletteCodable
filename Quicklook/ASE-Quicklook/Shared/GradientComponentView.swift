//
//  GradientComponentView.swift
//  Palette Viewer
//
//  Created by Darren Ford on 10/7/2023.
//

import Foundation
import SwiftUI
import ColorPaletteCodable

struct GradientComponentView: View {
	let gradient: PAL.Gradient
	let circleSize: Double = 12

	internal init(gradient: PAL.Gradient) {
		self.gradient = gradient
	}

	var body: some View {
		VStack(spacing: 3) {
			ZStack {
				CheckerboardView(
					dimension: 8,
					color0: NSColor.textColor.cgColor.copy(alpha: 0.1),
					color1: NSColor.textColor.cgColor.copy(alpha: 0.3)
				)
				.cornerRadius(4)

				RoundedRectangle(cornerRadius: 4)
					.fill(
						LinearGradient(
							gradient: gradient.SwiftUIGradient()!,
							startPoint: .leading,
							endPoint: .trailing
						)
					)
					.mask {
						LinearGradient(
							gradient: gradient.SwiftUITransparencyGradient(),
							startPoint: .leading,
							endPoint: .trailing
						)
					}
				RoundedRectangle(cornerRadius: 4)
					.strokeBorder(Color.gray, lineWidth: 0.5)
			}
			.padding(EdgeInsets(top: 0, leading: circleSize / 2.5, bottom: 0, trailing: circleSize / 2.5))

			ZStack {
				RoundedRectangle(cornerRadius: 3)
					.fill(Color.primary.opacity(0.2))
					.padding(1)
					.padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
					.offset(y: circleSize / 5.5)
				Group {
					GeometryReader { geo in
						ForEach(gradient.stops) { stop in
							ZStack {
								Circle()
									.fill(stop.color.SwiftUIColor ?? .clear)
								Circle()
									.strokeBorder(Color.gray, lineWidth: 0.5)
							}
							.help("Color: \(stop.color.printable), Position: \(stop.position)")
							.frame(width: circleSize, height: circleSize)
							.offset(x: (geo.size.width - circleSize) * stop.position)
						}
					}
				}
			}
			.frame(height: 8)
		}
	}
}

struct GradientComponent_Previews: PreviewProvider {
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
		GradientComponentView(gradient: Self.gradient1)
			.frame(width: 250, height: 64)
			.padding()
	}
}
