//
//  GradientEditor.swift
//  Palette Viewer
//
//  Created by Darren Ford on 2/8/2023.
//

import SwiftUI
import ColorPaletteCodable

struct GradientEditor: View {

	struct ColorStop: Identifiable {
		let id: UUID
		@State var position: Double = 0.0
		@State var color: CGColor = .clear
		var isMovable: Bool = true
		init(position: Double, color: CGColor) {
			self.id = UUID()
			self.position = position
			self.color = color
		}
	}

	struct TransparencyStop: Identifiable {
		let id: UUID
		@State var position: Double = 0.0
		@State var value: Double = 0.0
		var isMovable: Bool = true
		init(position: Double, value: Double) {
			self.id = UUID()
			self.position = position
			self.value = value
		}
	}

	var color: SwiftUI.Gradient {
		let st = colorStops.compactMap { stop in
			Gradient.Stop(color: Color(cgColor: stop.color), location: stop.position)
		}
		return SwiftUI.Gradient(stops: st)
	}

	var transparency: SwiftUI.Gradient {
		let stops = transparencyStops.map { stop in
			SwiftUI.Gradient.Stop(color: Color(.sRGB, white: 0, opacity: stop.value), location: CGFloat(stop.position))
		}
		return SwiftUI.Gradient(stops: stops)
	}

	let circleSize = 30.0

	@Binding var colorStops: [ColorStop]
	@Binding var transparencyStops: [TransparencyStop]
	@State var selectedStop: UUID?

	init(colorStops: Binding<[ColorStop]>, transparencyStops: Binding<[TransparencyStop]>) {
		self._colorStops = colorStops
		self._transparencyStops = transparencyStops
	}

	var body: some View {
		VStack(spacing: 4) {

			GeometryReader { geo in
				RoundedRectangle(cornerRadius: 4)
					.fill(.tertiary)
					.frame(height: 16)
					.padding([.leading, .trailing], 8)
					.offset(y: 7)
				ForEach(transparencyStops) { stop in
					ColorCircleView(id: stop.id, color: .white.opacity(stop.value), selected: $selectedStop)
						.frame(width: circleSize, height: circleSize)
						.offset(x: (geo.size.width - circleSize) * stop.position)
						.gesture(DragGesture().onChanged({ value in
							if stop.isMovable {
								stop.position = min(1, max(0, value.location.x / geo.size.width))
							}
						}))
				}
			}
			.frame(height: circleSize)

			ZStack {
				CheckerboardView(
					dimension: 4,
					color0: NSColor.textColor.cgColor.copy(alpha: 0.1),
					color1: NSColor.textColor.cgColor.copy(alpha: 0.3)
				)
				.cornerRadius(8)

				RoundedRectangle(cornerRadius: 8)
					.fill(
						LinearGradient(
							gradient: color,
							startPoint: .leading,
							endPoint: .trailing
						)
					)
					.mask {
						LinearGradient(
							gradient: transparency,
							startPoint: .leading,
							endPoint: .trailing
						)
					}

				RoundedRectangle(cornerRadius: 8)
					.stroke(.primary, lineWidth: 0.5)
			}
			.padding([.leading, .trailing], circleSize / 3.0)
			.frame(height: 80)

			GeometryReader { geo in
				RoundedRectangle(cornerRadius: 4)
					.fill(.tertiary)
					.frame(height: 16)
					.padding([.leading, .trailing], 8)
					.offset(y: 7)
				ForEach(colorStops) { stop in
					ColorCircleView(id: stop.id, color: Color(cgColor: stop.color), selected: $selectedStop)
						.frame(width: circleSize, height: circleSize)
						.offset(x: (geo.size.width - circleSize) * stop.position)
				}
			}
			.frame(height: circleSize)
		}
//		.onChange(of: colorStops) { newValue in
//			//updateGradient()
//		}
		.onAppear {
			//updateGradient()
		}
		.padding(20)
	}

//	func updateGradient() {
//		color = gradient.SwiftUIGradient()!
//		transparency = gradient.SwiftUITransparencyGradient()
//	}
}

struct GradientEditor_Previews: PreviewProvider {

	static let gr1 = PAL.Gradient(
		name: "Simple",
		stops: [
			PAL.Gradient.Stop(position: 0.0, color: PAL.Color.red),
			PAL.Gradient.Stop(position: 0.7, color: PAL.Color.green),
			PAL.Gradient.Stop(position: 1.0, color: PAL.Color.blue),
		],
		transparencyStops: [
			PAL.Gradient.TransparencyStop(position: 0, value: 1),
			PAL.Gradient.TransparencyStop(position: 0.2, value: 0.1),
			PAL.Gradient.TransparencyStop(position: 0.3, value: 0.3),
			PAL.Gradient.TransparencyStop(position: 1, value: 1),
		]
	)

	static var previews: some View {
		GradientEditor(
			colorStops: .constant([
				GradientEditor.ColorStop(position: 0, color: CGColor(red: 1, green: 0, blue: 0, alpha: 1)),
				GradientEditor.ColorStop(position: 1, color: CGColor(red: 0, green: 0, blue: 1, alpha: 1)),
			]),
			transparencyStops: .constant([
				GradientEditor.TransparencyStop(position: 0, value: 1),
				GradientEditor.TransparencyStop(position: 1, value: 1),
			])
		)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

///


struct ColorCircleView: View {
	let id: UUID
	let color: Color
	@Binding var selected: UUID?

	var isSelected: Bool { selected == self.id }

	var body: some View {
		ZStack {
			Circle()
				.fill(.background)
			Circle()
				.fill(.clear)
				.background(
					CheckerboardView(
						dimension: 4,
						color0: NSColor.textColor.cgColor.copy(alpha: 0.1),
						color1: NSColor.textColor.cgColor.copy(alpha: 0.3)
					)
					.mask(Circle())
				)
			Circle()
				.fill(color)
				.padding(0.5)
			Circle()
				.strokeBorder(Color.white, lineWidth: isSelected ? 4 : 2)
			Circle()
				.stroke(.background, lineWidth: 0.5)
				.padding(0)
			Circle()
				.stroke(.background, lineWidth: 0.5)
				.padding(isSelected ? 4 : 2)
		}
	}
}

struct ColorCircleView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			HStack {
				ColorCircleView(id: UUID(), color: .red, selected: .constant(nil)).frame(width: 30, height: 30)
				ColorCircleView(id: UUID(), color: .green, selected: .constant(nil)).frame(width: 30, height: 30)
				ColorCircleView(id: UUID(), color: .blue, selected: .constant(nil)).frame(width: 30, height: 30)
				ColorCircleView(id: UUID(), color: .white, selected: .constant(nil)).frame(width: 30, height: 30)
				ColorCircleView(id: UUID(), color: .black, selected: .constant(nil)).frame(width: 30, height: 30)
			}
			HStack {
				let c1 = UUID()
				ColorCircleView(id: c1, color: .red, selected: .constant(c1)).frame(width: 30, height: 30)
				ColorCircleView(id: c1, color: .green, selected: .constant(c1)).frame(width: 30, height: 30)
				ColorCircleView(id: c1, color: .blue, selected: .constant(c1)).frame(width: 30, height: 30)
				ColorCircleView(id: c1, color: .white, selected: .constant(c1)).frame(width: 30, height: 30)
				ColorCircleView(id: c1, color: .black, selected: .constant(c1)).frame(width: 30, height: 30)
			}
		}
	}
}
