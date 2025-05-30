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

extension Collection {
	/// Returns true if the collection is NOT empty
	@inlinable @inline(__always) var isNotEmpty: Bool { self.isEmpty == false }

	/// Count how many items in the collection satisfy the condition
	/// - Parameter condition: The condition block
	/// - Returns: The number of blocks that satify the condition
	///
	/// A Swift 5 compatible version of `count(where: {})` in Swift 6
	@inlinable public func countWhere(_ condition: (Element) throws -> Bool) rethrows -> Int {
		try self.reduce(0) { partialResult, element in
			partialResult + (try condition(element) ? 1 : 0)
		}
	}
}
