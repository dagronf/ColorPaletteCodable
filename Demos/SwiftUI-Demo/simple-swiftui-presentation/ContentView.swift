//
//  ContentView.swift
//  SwiftUI-Demo
//
//  Created by Darren Ford on 17/6/2024.
//

import SwiftUI
import ColorPaletteCodable

func paletteAsset(named name: String) -> PAL.Palette {
	let assetData = NSDataAsset(name: name)!.data
	let u = URL(string: name)!
	return try! PAL.LoadPalette(assetData, for: u.pathExtension)
}

let palette1 = paletteAsset(named: "pear36.hex")
let palette2 = paletteAsset(named: "equinox-8.pal")
let palette3 = paletteAsset(named: "slso8.gpl")
let palette4 = paletteAsset(named: "moderna-24.pal")

let allPalettes = [palette1, palette2, palette3, palette4]

struct ContentView: View {
	var body: some View {
		ScrollView {
			VStack {
				ForEach(allPalettes) { palette in
					RoundedRectangle(cornerRadius: 8)
						.fill(
							LinearGradient(
								gradient: try! palette.SwiftUIGradient(style: .stepped),
								startPoint: .leading,
								endPoint: .trailing
							)
						)
						.frame(height: 48)

					RoundedRectangle(cornerRadius: 8)
						.fill(
							LinearGradient(
								gradient: try! palette.SwiftUIGradient(),
								startPoint: .leading,
								endPoint: .trailing
							)
						)
						.frame(height: 48)

					HStack(spacing: 1) {
						ForEach(palette.colors) { color in
							Rectangle()
								.fill(color.SwiftUIColor ?? .black)
								.frame(height: 24)
						}
					}

					Divider()
				}
			}
			.padding()
		}
	}
}

#Preview {
	ContentView()
}
