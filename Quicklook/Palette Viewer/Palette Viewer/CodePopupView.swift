//
//  CodePopupView.swift
//  Palette Viewer
//
//  Created by Darren Ford on 11/7/2023.
//

import SwiftUI
import ColorPaletteCodable

struct CodePopupView: View {
	let code: String
	var body: some View {
		VStack {
			TextEditor(text: .constant(code))
				.font(Font.system(size: 12).monospaced())
			HStack {
				Button("Copy to clipboard") {
					let cp = NSPasteboard.general
					cp.clearContents()
					cp.setString(code, forType: .string)
				}
			}
		}
		.padding(8)
		.frame(minWidth: 640, maxWidth: .infinity, minHeight: 480, maxHeight: .infinity)
	}

}

#if DEBUG

struct CodePopupView_Previews: PreviewProvider {
	static let dummyText = """
// Gradient stops definition (sunset-PhotoshopSupply.com)
let gradientStops1: [Gradient.Stop] = [
	Gradient.Stop(color: Color(red: 0.9882, green: 0.6677, blue: 0.2519, opacity: 1.0000), location: 0.0000),
	Gradient.Stop(color: Color(red: 0.9882, green: 0.8413, blue: 0.6314, opacity: 1.0000), location: 0.2808),
	Gradient.Stop(color: Color(red: 0.9804, green: 0.5882, blue: 0.5961, opacity: 1.0000), location: 0.4497),
	Gradient.Stop(color: Color(red: 0.9922, green: 0.6823, blue: 0.7647, opacity: 1.0000), location: 0.6840),
	Gradient.Stop(color: Color(red: 0.7961, green: 0.6392, blue: 0.8863, opacity: 1.0000), location: 0.8230),
	Gradient.Stop(color: Color(red: 0.1999, green: 0.5567, blue: 0.8941, opacity: 1.0000), location: 1.0000)
]
"""

	static var previews: some View {
		CodePopupView(code: Self.dummyText)
	}
}

#endif
