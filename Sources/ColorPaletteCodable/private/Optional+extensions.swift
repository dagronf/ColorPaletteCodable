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

/// Perform a block if an optional is able to be unwrapped
/// - Parameters:
///   - item: The optional item
///   - block: The block to call, passing the unwrapped value
/// - Returns: The wrapped value
@inlinable func unwrapping<T, R>(_ item: T?, _ block: (T) -> R?) -> R? {
	guard let item = item else { return nil }
	return block(item)
}

@inlinable func unwrapping<T, U, R>(_ item1: T?, _ item2: U?, _ block: (T, U) -> R?) -> R? {
	guard let item1 = item1, let item2 = item2 else { return nil }
	return block(item1, item2)
}

extension Optional {
	@inlinable func unwrapping<R>(_ block: (Wrapped) -> R?) -> R? {
		if let value = self { return block(value) }
		return nil
	}

	/// Is the wrapped value nil?
	@inlinable @inline(__always) func isEmpty() -> Bool { self == nil }
	/// Is the wrapped value not nil?
	@inlinable @inline(__always) func isNotEmpty() -> Bool { self != nil }
}
