//Copyright © 2023 Charles Kerr. All rights reserved.

import Foundation
import AppKit

// ============================================================================
class Map : NSObject {
    static let UOPBASEHASHFORMAT = "build/map%ilegacymul/"
    static let UOPHASHFORMAT = "%0.8u.dat"
    static let MAPSIZES = [[7168,4096],[7168,4096],[2304,1600],[2560,2048],[1448,1448],[1280,4096]]
    static let BLOCKSIZE = 196
    static let UOPBLOCKSIZEINBLOCKS = 4096
    
    @objc dynamic var mapHeight = 0
    @objc dynamic var mapWidth = 0
    @objc dynamic var mapData = Data()
    
    var mapOffsets = [Int:UOPEntryInformation]()
}

// ============================================================================
extension Map {
    @objc dynamic var isValid:Bool {
        return !mapData.isEmpty && !mapOffsets.isEmpty
    }

    // ============================================================================
   static override func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        var keypaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case "mapHeight":
            keypaths.insert("mapData")
        case "mapWidth":
            keypaths.insert("mapData")
        case "isValid":
            keypaths.insert("mapData")
        default:
            break
        }
        return keypaths
    }
    // ============================================================================
    convenience init(mapURL url:URL, mapNumber number:Int) {
        self.init()
        loadMap(mapURL: url,mapNumber: number)
    }
    // ============================================================================
    func loadMap(mapURL:URL, mapNumber:Int) {
        guard mapURL.validUOP else {
            return
        }
        mapHeight = Map.MAPSIZES[mapNumber][1]
        mapWidth =  Map.MAPSIZES[mapNumber][0]
        let base = String(format: Map.UOPBASEHASHFORMAT, mapNumber) + Map.UOPHASHFORMAT
        mapData = Data()
        mapOffsets = [Int:UOPEntryInformation]()
        do {
            mapOffsets = mapURL.gatherUOPOffsets(formatString: base, maxIndex: 300)
            mapData = try Data(contentsOf: mapURL)
        }
        catch {
            // Do something?
        }
    }
    // ============================================================================
    func gotoLocation(forX xloc:Int,Y yloc:Int) {
        guard xloc >= 0 && yloc >= 0 && xloc < mapWidth && yloc < mapHeight && self.isValid else {
            return 
        }
    }
    //============================================================================
    func calculateXY(forBlock blockNumber:Int) -> (Int,Int) {
        let yloc =  (blockNumber%(mapHeight/8)) * 8
        let xloc =  (blockNumber / (mapHeight/8)) * 8
        return (xloc,yloc)
    }
    // ============================================================================
    func calculateBlockNumber(forX xloc:Int, Y yloc:Int) -> (Int,Int,Int) {
        let blockNumber =  ((xloc/8) * (mapHeight/8)) + (yloc/8)
        // what offset into this are we ?
        let (xStart,yStart) = calculateXY(forBlock: blockNumber)
        return (blockNumber,xloc - xStart,yloc - yStart)

    }
    // ============================================================================
    func calculateUopBlock(forX xloc:Int, Y yloc:Int) -> (Int,Int,Int,Int) {
        // How many blocks are in a uop block?
        
        let (blockWeWant,xOffset,yOffset) = calculateBlockNumber(forX: xloc, Y: yloc)
        let uopBlock = blockWeWant / Map.UOPBLOCKSIZEINBLOCKS
        let uopBlockOffset = blockWeWant % Map.UOPBLOCKSIZEINBLOCKS
        
        return (uopBlock,uopBlockOffset,xOffset,yOffset)
    }

    //==================================================================================
    // For a given col/row, returns the tile id and altitude for that location
    func mapInfo(forX xloc:Int,Y yloc:Int) -> (Int,Int) {
        let (uopBlock,uopBlockOffset,xOffset,yOffset) = calculateUopBlock(forX: xloc, Y: yloc)
        // We could guard if the uopBlock exceeds our offsets, in theory shouldn't happen, unless we have the map height incorrect
        
        let offset = Int(truncatingIfNeeded: mapOffsets[uopBlock]!.fileOffset+mapOffsets[uopBlock]!.headerLength + UInt64(Map.BLOCKSIZE * uopBlockOffset + 4 +  ( 8 * 3 * yOffset) + (3 * xOffset)))
        
        let tileId = mapData.withUnsafeBytes { Int($0.loadUnaligned(fromByteOffset: offset, as: UInt16.self))}
        let altitude = mapData.withUnsafeBytes { Int($0.loadUnaligned(fromByteOffset: offset+2, as: Int8.self))}
        return (tileId,altitude)
    }
    
    //==================================================================================
    func neededTileIDAndAltitudes(forX xloc:Int, Y yloc:Int) -> [Int] {

        // Get the information for the given coordinate
        var (tileid,baseAlt) = mapInfo(forX: xloc, Y: yloc)
        var rvalue = [Int].init(repeating: baseAlt, count: 5)
        rvalue[0] = tileid
        // Now we need the other altidues
        if (yloc+1 < mapHeight) {
           (_,baseAlt) = mapInfo(forX: xloc, Y: yloc+1)
            rvalue[2] = baseAlt
        }
        
        if (yloc+1 < mapHeight && xloc+1 < mapWidth) {
            (_,baseAlt) = mapInfo(forX: xloc+1, Y: yloc+1)
             rvalue[3] = baseAlt
        }
        if ( xloc+1 < mapWidth) {
            (_,baseAlt) = mapInfo(forX: xloc+1, Y: yloc)
             rvalue[4] = baseAlt
        }
        return rvalue
    }
}
