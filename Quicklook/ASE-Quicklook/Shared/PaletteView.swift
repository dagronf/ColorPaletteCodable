//
//  PaletteView.swift
//  ASE-Quicklook
//
//  Created by Darren Ford on 22/5/2022.
//

#if os(macOS)

import SwiftUI
import DSFAppearanceManager
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

			ColorGroup(color: colors)

			Divider()
				.padding(EdgeInsets(top: 4, leading: 8, bottom: -4, trailing: 8))
		}
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

#endif

#endif



////////


struct ColorGroup: NSViewRepresentable {

	let color: [PAL.Color]

	func makeNSView(context: Context) -> ColorGroupView {
		ColorGroupView()
	}

	func updateNSView(_ nsView: ColorGroupView, context: Context) {
		nsView.colors = color
	}

	typealias NSViewType = ColorGroupView
}

class ColorGroupView: NSView, DSFAppearanceCacheNotifiable {
	override var isFlipped: Bool { true }
	@MainActor var colors: [PAL.Color] = [] {
		didSet {
			self.rebuild()
		}
	}
	private var layers: [CAShapeLayer] = []

	@MainActor var inset: CGSize = CGSize(width: 8, height: 8) {
		didSet {
			self.needsLayout = true
		}
	}

	@MainActor var colorSize = CGSize(width: 24, height: 24) {
		didSet {
			self.needsLayout = true
		}
	}

	@MainActor var spacing: CGFloat = 3.0 {
		didSet {
			self.needsLayout = true
		}
	}

	private var _draggingColor: NSColor?

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.wantsLayer = true

		registerForDraggedTypes([.color])

		self.rebuild()

		DSFAppearanceCache.shared.register(self)
	}

	func appearanceDidChange() {
		self.rebuild()
	}

	override func layout() {
		super.layout()
		self.relayout()
	}

	var computedHeight: CGFloat = 0

	override var intrinsicContentSize: NSSize {
		return CGSize(width: 64, height: self.computedHeight)
	}

	func rebuild() {

		let showShadows = false // colors.count <= 512

		self.layers.forEach { $0.removeFromSuperlayer() }
		self.layers = colors.map {
			let l = CAShapeLayer()
			l.masksToBounds = false
			l.path = CGPath(
				roundedRect: CGRect(origin: .zero, size: colorSize),
				cornerWidth: 4,
				cornerHeight: 4,
				transform: nil
			)

			let color = $0.cgColor
			l.fillColor = color

			self.usingEffectiveAppearance {
				l.strokeColor = NSColor.secondaryLabelColor.cgColor
			}
			l.lineWidth = 0.75

			if showShadows {
				l.shadowColor = .black
				l.shadowOffset = .init(width: 0, height: 1)
				l.shadowRadius = 2
				l.shadowOpacity = 0.6
			}

			self.layer!.addSublayer(l)
			return l
		}
		CATransaction.commit()
		self.needsLayout = true
	}

	var tooltipMapping: [NSView.ToolTipTag: Int] = [:]

	func relayout() {
		let bounds = self.bounds

		self.removeAllToolTips()
		self.tooltipMapping = [:]

		var xOffset: Double = inset.width
		var yOffset: Double = inset.height

		CATransaction.withDisabledActions {

			self.layers.enumerated().forEach { indexed in
				let rect = CGRect(x: xOffset, y: yOffset, width: self.colorSize.width, height: self.colorSize.height)
				indexed.element.frame = rect

				let tt = self.addToolTip(rect, owner: self, userData: nil)
				tooltipMapping[tt] = indexed.offset

				xOffset += self.colorSize.width + self.spacing
				if bounds.width < (xOffset + self.colorSize.width + inset.width) {
					xOffset = inset.width
					yOffset += self.colorSize.height + self.spacing
				}
			}
		}

		self.computedHeight = yOffset + self.colorSize.height + self.spacing + inset.height

		self.invalidateIntrinsicContentSize()
	}
}

extension ColorGroupView: NSDraggingSource, NSPasteboardItemDataProvider {

	func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
		return .generic
	}

	override func mouseDragged(with event: NSEvent) {
		let pasteboardItem = NSPasteboardItem()
		pasteboardItem.setDataProvider(self, forTypes: [.color])

		let mousePosition = event.locationInWindow
		let pos = self.convert(mousePosition, from: nil)
		let flipped = CGPoint(x: pos.x, y: self.bounds.height - pos.y)
		guard
			let l = self.layer?.hitTest(flipped) as? CAShapeLayer,
			let c = l.fillColor,
			let nc = NSColor(cgColor: c)
		else {
			return
		}

		self._draggingColor = nc

		let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)

		draggingItem.setDraggingFrame(
			l.frame,
			contents: self.swatchWithColor(nc, size: self.colorSize)
		)

		let draggingSession = beginDraggingSession(with: [draggingItem], event: event, source: self)
		draggingSession.animatesToStartingPositionsOnCancelOrFail = true
		draggingSession.draggingFormation = .none
	}

	override func draggingEnded(_ sender: NSDraggingInfo) {
		self._draggingColor = nil
	}

	private func swatchWithColor2(_ color: NSColor, size: NSSize) -> NSImage {
		let im = NSImage(size: size)
		im.lockFocus()
		color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
		im.unlockFocus()
		return im
	}

	private func swatchWithColor(_ color: NSColor, size: NSSize) -> NSImage {
		let im = NSImage(size: size)
		im.lockingFocus { _ in
			let pth = NSBezierPath(roundedRect: NSRect(origin: .zero, size: self.colorSize).insetBy(dx: 0.5, dy: 0.5), xRadius: 4, yRadius: 4)
			pth.lineWidth = 0.5
			color.setFill()
			pth.fill()
			self.usingEffectiveAppearance {
				NSColor.textColor.setStroke()
			}
			pth.stroke()
		}
		return im
	}

	func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType) {
		if type == .color,
			let pasteboard = pasteboard,
			let color = self._draggingColor
		{
			color.write(to: pasteboard)
		}
	}
}

extension NSImage {
	@inlinable func lockingFocus(flipped: Bool = false, _ block: (NSImage) -> Void) {
		self.lockFocusFlipped(flipped)
		defer { self.unlockFocus() }
		block(self)
	}
}

extension CATransaction {
	@inlinable static func withDisabledActions(_ block: () -> Void) -> Void {
		CATransaction.begin()
		defer { CATransaction.commit() }
		CATransaction.setDisableActions(true)
		block()
	}
}

// MARK: - Handling tooltips

extension ColorGroupView: NSViewToolTipOwner {
	func view(_ view: NSView, stringForToolTip tag: NSView.ToolTipTag, point: NSPoint, userData data: UnsafeMutableRawPointer?) -> String {
		if let colorIndex = self.tooltipMapping[tag] {
			let color = self.colors[colorIndex]
			let name = color.name.count > 0 ? color.name : "<unnamed>"
			let hexString = color.componentsString
			return "Name: \(name)\nMode: \(color.colorSpace.rawValue)\nType: \(color.colorType.rawValue)\nComponents: \(hexString)"
		}
		return ""
	}
}

