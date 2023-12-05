//Copyright © 2023 Charles Kerr. All rights reserved.

import Foundation
import AppKit

class OpenMapController :NSWindowController {
    override var windowNibName: NSNib.Name? {
        return "OpenMapWindow"
    }
    
    @objc dynamic var mapURL:URL?
    @objc dynamic var mapNumber:Int = 0
}
//===========================================================================================
extension OpenMapController {
    
    //===========================================================================================
    @IBAction func selectFile(_ sender:Any?) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        panel.prompt = "Set UO Map File"
        panel.title = "Select UO Map File"
        panel.beginSheetModal(for: self.window!.contentView!.window!) { response in
            if response == .OK {
                self.mapURL = panel.url
            }
        }
    }
    //===========================================================================================
    @IBAction func setMapFile(_ sender:NSButton!) {
        self.window!.sheetParent!.endSheet(self.window!, returnCode: .OK)
    }
    //===========================================================================================
    @IBAction func cancelSelection( _ sender: NSButton!) {
        self.window!.sheetParent!.endSheet(self.window!, returnCode: .cancel)
    }
    
}
