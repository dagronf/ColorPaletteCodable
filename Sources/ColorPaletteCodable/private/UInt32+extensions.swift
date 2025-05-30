//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

extension UInt32 {
	/// Return the byte components for the value
	/// - Returns: Four byte components
	@inlinable func byteComponents() -> (UInt8, UInt8, UInt8, UInt8) {
		return (
			UInt8((self >> 24) & 0xFF),
			UInt8((self >> 16) & 0xFF),
			UInt8((self >> 8) & 0xFF),
			UInt8(self & 0xFF)
		)
	}

	/// Create a UInt32 from four bytes
	@inlinable static func fromBytes(_ c0: UInt8, _ c1: UInt8, _ c2: UInt8, _ c3: UInt8) -> UInt32 {
		UInt32(c0) << 24 | UInt32(c1) << 16 | UInt32(c2) << 8 | UInt32(c3)
	}
}
