//
//  AppDelegate.swift
//  MapGrid
//
//  Created by Charles Kerr on 12/4/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow!
    
    @IBOutlet var mapObject:Map!        // Our map data!
    
    @IBOutlet var openDialog:OpenMapController!  // Selection for the map
    
    
    @IBOutlet var gridController: GridViewController!  // Controller for the grid window
    @IBOutlet var gridHolder :NSView! // Where we put the grid view

    @objc dynamic var mapURL:URL?
    
    @objc dynamic var xLoc = 0
    @objc dynamic var yLoc = 0
    @objc dynamic var mapNumber = 0
    //====================================================================================
    @IBAction func openDocument(_ button: NSButton!) {
        if (self.window.makeFirstResponder(button)) {
            self.window.beginCriticalSheet(openDialog.window!) { response in
                if (response == .cancel) {
                    // We want to reset the url/number in our dialog
                    self.openDialog.mapURL = self.mapURL
                    self.openDialog.mapNumber = self.mapNumber
                }
                else {
                    self.mapURL = self.openDialog.mapURL
                    self.mapNumber = self.openDialog.mapNumber
                    // We should load the map here!!!!!!!!!
                    self.mapObject.loadMap(mapURL: self.mapURL!, mapNumber: self.mapNumber)
                    self.xLoc = 0
                    self.yLoc = 0
                    self.gotoLocation(nil)
                    /*
                     Lets see if we are really getting the altitude correctly, lets try to see if any are positive
                     
                     */
                    var cancel = false
                    for x in 0..<self.mapObject.mapWidth {
                        for y in 0..<self.mapObject.mapHeight {
                            let (tileid,altitude) = self.mapObject.mapInfo(forX: x, Y: y)
                            if (altitude >= 4) {
                                Swift.print("TileID: \(tileid) X: \(x) Y: \(y) Altitude: \(altitude)")
                                
                                cancel = true
                                break;
                            }
                        }
                        if (cancel){
                            break
                        }
                    }
                }
            }
        }
        
     }
    
    //====================================================================================
    @IBAction func gotoLocation(_ sender:NSButton!){
        if (self.window.makeFirstResponder(sender)) {
            let info = mapObject.neededTileIDAndAltitudes(forX: xLoc, Y: yLoc)
            gridController.tileID = info[0]
            gridController.altitude = info[1]
            gridController.lleftAlt = info[2]
            gridController.lAlt = info[3]
            gridController.lrightAlt = info[4]
           
        }
    }
    //====================================================================================
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    //====================================================================================
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        gridController.view.frame = gridHolder.bounds
        gridHolder.addSubview(gridController.view)
        
        
    }
    
    //====================================================================================
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    //====================================================================================
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    
}

