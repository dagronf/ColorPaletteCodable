//
//  GradientTransparencyView.swift
//  ASE-Quicklook
//
//  Created by Darren Ford on 9/7/2023.
//

import Foundation
import SwiftUI
import Charts
import ColorPaletteCodable

struct Pair<T, U>: Identifiable {
	let id: UUID = UUID()

	let a: T
	let b: U
	init(_ a: T, _ b: U) {
		self.a = a
		self.b = b
	}
}

//struct GradientSnapshotView: View {
//	let gradient: PAL.Gradient
//
//}



struct GradientTransparencyView: View {
	let gradient: PAL.Gradient

	// Transparency information as a gradient
	let mappedTransparency: PAL.Gradient?

	// The gradient without any transparency information
	let flatGradient: PAL.Gradient

	// Does the gradient contain transparency?
	let hasTransparency: Bool

	internal init(gradient: PAL.Gradient) {
		self.gradient = gradient
		self.flatGradient = gradient.withoutTransparency()

		// The transparency gradient, mapped to red
		self.mappedTransparency = gradient.transparencyGradient(try! PAL.Color(cgColor: NSColor.systemRed.cgColor))
		self.hasTransparency = gradient.hasTransparency
	}


	var body: some View {
		VStack(spacing: 20) {
				Text("􀪫 Gradient")
					.font(.title2).fontWeight(.heavy)
					.truncationMode(.tail)
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(4)
					.background(Rectangle().fill(.background))

				GradientComponentView(gradient: gradient)
					.frame(height: 84)
					.padding(2)

			if gradient.hasTransparency {

				Text("􀪫 Components")
					.font(.title2).fontWeight(.heavy)
					.truncationMode(.tail)
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(4)
					.background(Rectangle().fill(.background))

				if let m = mappedTransparency {
					// Gradient has transparency. Display breakdown
					VStack(spacing: 12) {

						Chart(m.mappedTransparency) { item in
							LineMark(
								x: .value("position", item.position),
								y: .value("opacity", item.value)
							)
							.interpolationMethod(.linear)
							.foregroundStyle(Color.red)
							.lineStyle(.init(lineWidth: 2, lineCap: .round, lineJoin: .bevel))
						}
						.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))

						.chartXScale(domain: [0.0, 1.0])
						.chartYScale(domain: [0.0, 1.0])
						.chartXAxis(content: {
							AxisMarks(values: m.mappedTransparency.map { $0.position }) {
								AxisGridLine()
							}
						})
						.chartYAxis(content: {
							AxisMarks(values: [0.0, 0.5, 1.0]) {
								AxisGridLine()
							}
						})
						.frame(height: 48)

						GradientComponentView(gradient: m)
							.frame(height: 24)
							.padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3))

						GradientComponentView(gradient: flatGradient)
							.frame(height: 24)
							.padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3))
					}
				}
			}
		}
	}
}

struct GradientTransparency_Previews: PreviewProvider {
	static let gradient1: PAL.Gradient = {
		var g = PAL.Gradient(name: "Simple", colorPositions: [
			(position: 0.0, color: PAL.Color.green),
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
		GradientTransparencyView(gradient: Self.gradient1)
			.frame(width: 250)
			.padding()
	}
}
