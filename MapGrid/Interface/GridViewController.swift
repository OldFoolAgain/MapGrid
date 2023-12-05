//Copyright © 2023 Charles Kerr. All rights reserved.

import Foundation
import AppKit

class GridViewController : NSViewController {
    
    //===========================================================
    override var nibName: NSNib.Name? {
        return "GridView"
    }
    //===========================================================
    
    @IBOutlet weak var  diamondDisplay:DiamondView!
    @objc dynamic var tileID  = 0
    @objc dynamic var altitude = 0
    @objc dynamic var lleftAlt = 0 {
        didSet {
            diamondDisplay.needsDisplay = true
        }
    }
    @objc dynamic var lAlt = 0 {
        didSet {
            diamondDisplay.needsDisplay = true
        }
    }
    @objc dynamic var lrightAlt = 0 {
        didSet {
            diamondDisplay.needsDisplay = true
        }
    }
    
}
