//Copyright © 2023 Charles Kerr. All rights reserved.

import Foundation
import AppKit

class BaseView : NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.autoresizesSubviews = true
        self.autoresizingMask = [.height,.width]
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
       
    }
    
    override var isOpaque: Bool {
        return true
    }
}
