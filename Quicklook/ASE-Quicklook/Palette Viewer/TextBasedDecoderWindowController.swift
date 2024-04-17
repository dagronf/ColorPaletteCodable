//
//  TextBasedDecoderWindowController.swift
//  Palette Viewer
//
//  Created by Darren Ford on 16/4/2024.
//

import Cocoa
import SwiftUI
import UniformTypeIdentifiers

import ColorPaletteCodable

class TextBasedDecoderWindowController: NSWindowController {

	private lazy var vc = NSHostingController(rootView: TextBasedDecodingView())

	convenience init() {
		self.init(windowNibName: "TextBasedDecoderWindowController")
	}

	override func windowDidLoad() {
		super.windowDidLoad()
		self.contentViewController = vc
	}

}

class CoderItem: Identifiable, Hashable, Equatable, ObservableObject {
	let id: String
	let coder: PAL_PaletteCoder
	@Published var disabled: Bool = true

	init(coder: PAL_PaletteCoder) {
		self.id = coder.name
		self.coder = coder
	}

	func hash(into hasher: inout Hasher) { hasher.combine(id) }
	static func == (lhs: CoderItem, rhs: CoderItem) -> Bool { lhs.id == rhs.id }
}

private var coders: [CoderItem] = PAL.Palette.TextBasedCoders
	.map { CoderItem(coder: $0) }
	.sorted { a, b in a.id < b.id }

struct TextBasedDecodingView: View {

	@State var selection: CoderItem = coders.first!
	@State var text: String = 
	"""
	363732, Black olive
	53d8fb, Vivid sky blue
	66c3ff, Maya blue
	dce1e9, Alice Blue
	d4afb9, Orchid pink
	"""
	@State var isValidCoding: Bool = true

	let model = PaletteModel(nil)

	var body: some View {
		HSplitView {
			HStack(spacing: 0) {
				MacTextEditorView(text: $text)
					.frame(minWidth: 200)
				List(coders, id: \.self, selection: $selection) { item in
					Text(item.coder.name)
						.selectionDisabled(item.disabled)
						.foregroundColor(item.disabled ? Color(NSColor.disabledControlTextColor) : Color(NSColor.textColor))
				}
				.frame(width: 200)
			}
			.layoutPriority(1)

			Group {
				if isValidCoding {
					VStack {
						PaletteView(title: nil, paletteModel: model)
						Button("Open as palette") {
							self.openAsDocument()
						}
						.padding()
					}
				}
				else {
					Text("Unable to decode")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
				}
			}
			.frame(minWidth: 200)
		}
		.onChange(of: text) { _, newValue in
			self.updatePalette(newValue)
		}
		.onChange(of: selection) { _, _ in
			updateCoder()
		}
		.onAppear {
			self.updatePalette(text)
		}
		.frame(minWidth: 500, minHeight: 200)
	}

	func updateCoder() {
		let d = text.data(using: .utf8) ?? Data()

		usingStreamData(d) { s in
			model.palette = try? selection.coder.decode(from: s)
			isValidCoding = model.palette != nil
		}
	}

	func updatePalette(_ text: String) {
		let d = text.data(using: .utf8) ?? Data()

		coders.forEach { coder in
			usingStreamData(d) { s in
				coder.disabled = {
					let palette = try? coder.coder.decode(from: s)
					if let p = palette {
						return p.allColors().count == 0
					}
					return true
				}()
			}
		}
		updateCoder()
	}

	func openAsDocument() {
		guard
			let extn = selection.coder.fileExtension.first,
			let uti = UTType(filenameExtension: extn)
		else {
			fatalError()
		}

		do {
			let doc = try NSDocumentController.shared.makeUntitledDocument(ofType: uti.identifier)
			guard let fullDoc = doc as? Document else { fatalError() }

			fullDoc.currentPalette = model.palette
			NSDocumentController.shared.addDocument(doc)

			doc.makeWindowControllers()
			doc.showWindows()
			doc.updateChangeCount(.changeDone)
		}
		catch {
			Swift.print(error)
		}
	}
}


#Preview("TextBasedDecodingView") {
	TextBasedDecodingView()
}
