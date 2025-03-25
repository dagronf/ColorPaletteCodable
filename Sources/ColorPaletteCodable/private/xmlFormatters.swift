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

/// Decimal formatter for XML output
///
/// Note that XML _expects_ the decimal separator to be '.', which means we have to force the separator
/// so that locales that use ',' as the decimal separator don't produce a garbled XML content
/// See [Issue 19](https://github.com/dagronf/QRCode/issues/19)
internal let _xmlFloatFormatter: NumberFormatter = {
	let f = NumberFormatter()
	f.decimalSeparator = "."
	f.usesGroupingSeparator = false
	#if os(macOS)
	f.hasThousandSeparators = false
	#endif
	f.maximumFractionDigits = 6
	f.minimumFractionDigits = 0
	return f
}()

/// Convert a floating point value to a xml-safe string format (requiring '.' as decimal separator)
/// - Parameter value: The value to convert
/// - Returns: A string representation
internal func _XMLD<T: BinaryFloatingPoint>(_ value: T) -> String {
	_xmlFloatFormatter.string(from: NSNumber(floatLiteral: Double(value)))!
}
