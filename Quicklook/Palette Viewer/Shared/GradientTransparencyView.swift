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
		let gradient = (try? gradient.normalized()) ?? gradient

		self.gradient = gradient
		self.flatGradient = try! gradient.removingTransparency()

		// The transparency gradient, mapped to red
		self.mappedTransparency = try! gradient.createTransparencyGradient(try! PAL.Color(color: NSColor.systemRed))
		self.hasTransparency = gradient.hasTransparency
	}

	var body: some View {
		VStack(spacing: 8) {
			if gradient.hasTransparency, let m = mappedTransparency {
				VStack(spacing: 12) {
					
					Chart(m.transparencyMap) { item in
						LineMark(
							x: .value("position", item.position),
							y: .value("opacity", item.value)
						)
						.interpolationMethod(.linear)
						.foregroundStyle(Color.red)
						.lineStyle(.init(lineWidth: 2, lineCap: .round, lineJoin: .bevel))
					}
					.padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
					.chartXScale(domain: [0.0, 1.0])
					.chartYScale(domain: [0.0, 1.0])
					.chartXAxis(content: {
						AxisMarks(values: m.transparencyMap.map { $0.position }) {
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
						.padding(EdgeInsets(top: 0, leading: -4, bottom: 0, trailing: -4))
				}
				.padding(4)
			}
			else {
				Text("No transparency")
					.frame(maxWidth: .infinity)
					.padding(8)
			}
		}
	}
}

struct GradientTransparency_Previews: PreviewProvider {
	static let gradient1: PAL.Gradient = {
		var g = PAL.Gradient(
			colorPositions: [
				(position: 0.0, color: PAL.Color.green),
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

		PAL.Gradients.Coder.GGR()

		return g
	}()
	static let gradient2: PAL.Gradient = {
		PAL.Gradient(
			colorPositions: [
				(position: 0.0, color: PAL.Color.green),
				(position: 0.4, color: PAL.Color.yellow),
				(position: 0.7, color: PAL.Color.blue),
				(position: 1.0, color: PAL.Color.white),
			],
			name: "Simple"
		)
	}()
	static var previews: some View {
		VStack {
			GradientTransparencyView(gradient: Self.gradient1)
				.frame(width: 250)
				.padding()
			GradientTransparencyView(gradient: Self.gradient2)
				.frame(width: 250)
				.padding()
			
		}
	}
}
