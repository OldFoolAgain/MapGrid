//Copyright © 2023 Charles Kerr. All rights reserved.

import Foundation
import AppKit

class DiamondView : BaseView {
    
    @IBOutlet var myController:GridViewController!
}

extension DiamondView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Now, we need to add our drawing
        // Save our context
        NSGraphicsContext.saveGraphicsState()
        let path = NSBezierPath()
        let bounds = self.bounds
        NSBezierPath.fill(bounds)
        let startX = bounds.width/2.0
        let startY = bounds.height/2.0 - 22.0
        path.move(to: NSPoint(x: startX, y:startY))
        path.line(to: NSPoint(x: startX - 22.0, y: startY + 22.0 + ( CGFloat(myController!.lleftAlt) * 4.0)))
        path.line(to: NSPoint(x: startX , y: startY + 44.0 + ( CGFloat(myController!.lAlt) * 4.0)))
        path.line(to: NSPoint(x: startX + 22.0 , y: startY + 22.0 + ( CGFloat(myController!.lrightAlt) * 4.0)))
        path.line(to: NSPoint(x: startX  , y: startY ))

 
        NSColor.red.setStroke()
        path.stroke()
        
        NSGraphicsContext.restoreGraphicsState()
    }
}
