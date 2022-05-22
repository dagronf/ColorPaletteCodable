//
//  UTType+extensions.swift
//  Quicklook-ASE
//
//  Created by Darren Ford on 16/5/2022.
//

import Foundation
import UniformTypeIdentifiers

// Extracted using mdls :-
// % mdls -name kMDItemContentType control.ase
// kMDItemContentType = "dyn.ah62d4rv4ge80c65f"
//

extension UTType {
	//static let ase = UTType("dyn.ah62d4rv4ge80c65f")!
	static let ase = UTType("com.adobe.ase")!

	/// NSColorList UTType
	static let clr = UTType("com.apple.color-file")!
}
