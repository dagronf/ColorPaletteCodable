//
//  ASEPreviewProvider.swift
//
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

import Cocoa
import Quartz

class ASEPreviewProvider: QLPreviewProvider, QLPreviewingController {
    

    /*
     Use a QLPreviewProvider to provide data-based previews.
     
     To set up your extension as a data-based preview extension:

     - Modify the extension's Info.plist by setting
       <key>QLIsDataBasedPreview</key>
       <true/>
     
     - Add the supported content types to QLSupportedContentTypes array in the extension's Info.plist.

     - Change the NSExtensionPrincipalClass to this class.
       e.g.
       <key>NSExtensionPrincipalClass</key>
       <string>$(PRODUCT_MODULE_NAME).PreviewProvider</string>
     
     - Implement providePreview(for:)
     */
    
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
    
        //You can create a QLPreviewReply in several ways, depending on the format of the data you want to return.
        //To return Data of a supported content type:
        
        let contentType = UTType.ase // replace with your data type
        
        let reply = QLPreviewReply.init(dataOfContentType: contentType, contentSize: CGSize.init(width: 800, height: 800)) { (replyToUpdate : QLPreviewReply) in

            let data = Data("Hello world".utf8)
            
            //setting the stringEncoding for text and html data is optional and defaults to String.Encoding.utf8
            replyToUpdate.stringEncoding = .utf8
            
            //initialize your data here
            
            return data
        }
                
        return reply
    }
}
