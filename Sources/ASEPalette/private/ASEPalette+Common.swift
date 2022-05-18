//
//  ASEPalette+Common.swift
//
//  Created by Darren Ford on 16/5/2022.
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

// Common definitions

import Foundation

/// Common namespace for all ASEPalette types
public class ASE {}

// Logger
let ase_log = OSLogger(subsystem: Bundle.main.bundleIdentifier!, category: "ASEPalette")

internal class Common {
	// Two 'zero' bytes in succession
	internal static let DataTwoZeros = Data([0, 0])

	// ASE file header
	internal static let HEADER_DATA = Data([65, 83, 69, 70])
	// ASE group start tag
	internal static let GROUP_START: UInt16 = 0xC001
	// ASE group end tag
	internal static let GROUP_END: UInt16 = 0xC002
	// ASE color start tag
	internal static let BLOCK_COLOR: UInt16 = 0x0001
}
