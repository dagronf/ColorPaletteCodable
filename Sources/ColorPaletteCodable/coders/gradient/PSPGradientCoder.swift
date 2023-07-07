//
//  File.swift
//  
//
//  Created by Darren Ford on 6/7/2023.
//

import Foundation

public extension PAL.Gradients.Coder {
	/// A coder for PSP gradients
	struct PSP: PAL_GradientsCoder {
		/// The coder's file format
		public static let fileExtension = "pspgradient"
		public init() {}
	}
}

public extension PAL.Gradients.Coder.PSP {
	func encode(_ gradients: PAL.Gradients) throws -> Data {
		throw PAL.CommonError.notImplemented
	}
}

public extension PAL.Gradients.Coder.PSP {
	/// Create a palette from the contents of the input stream
	/// - Parameter inputStream: The input stream containing the encoded palette
	/// - Returns: A palette
	///
	/// Note that the psppalette scheme appears to be equal to v3 of the grd format
	func decode(from inputStream: InputStream) throws -> PAL.Gradients {
		return try PAL.Gradients.Coder.GRD().decode(from: inputStream)
	}
}
