//
//  UTType+extensions.swift
//  Quicklook-ASE
//
//  Created by Darren Ford on 16/5/2022.
//

#if os(macOS)

import Foundation
import UniformTypeIdentifiers

// Extracted using mdls :-
// % mdls -name kMDItemContentType control.ase
// kMDItemContentType = "dyn.ah62d4rv4ge80c65f"
//

extension UTType {
	//static let ase = UTType("dyn.ah62d4rv4ge80c65f")!
	static let ase = UTType("com.adobe.ase")!

	static let aco = UTType("com.adobe.aco")!

	/// NSColorList UTType
	static let clr = UTType("com.apple.color-file")!

	/// NSColor UTType
	static let nsColor = UTType("com.apple.cocoa.pasteboard.color")!
}

#endif
