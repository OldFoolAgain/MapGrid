//Copyright © 2023 Charles Kerr. All rights reserved.

import Foundation
import ImageIO

// ===========================================================================
// URL Extensions
// ===========================================================================
// ===============================================================================
extension URL {
    
    public var validUOP: Bool {
        let signature = 0x0050594D
        guard let handle = try? FileHandle(forReadingFrom: self) else {
            return false
        }
        guard let data = try?handle.read(upToCount: 4) else {
            return false
        }
        return data.withUnsafeBytes({ ptr in
            ptr.loadUnaligned(as: UInt32.self)
        }) == signature
    }
    
    // ===============================================================================
    var uopTableEntry:[UInt64:UOPTableEntry]{
        let signature = 0x0050594D
        var offset = [UInt64:UOPTableEntry]()
    
        guard self.exist else {
            return [UInt64:UOPTableEntry]()
        }
        guard let handle = try? FileHandle(forReadingFrom: self) else {
            return [UInt64:UOPTableEntry]()
        }
        defer { try? handle.close()}
        // We have the file open
        guard let data = try?handle.read(upToCount: 4) else {
            return [UInt64:UOPTableEntry]()
        }
        guard data.withUnsafeBytes({ ptr in ptr.loadUnaligned(as: UInt32.self) }) == signature else {
            return [UInt64:UOPTableEntry]()
        }
        // It is a valid uop file, get the first entry
        do {
            try  handle.seek(toOffset: 12)
            guard let offsetdata = try handle.read(upToCount: 8) else {
                return [UInt64:UOPTableEntry]()
            }
            let firstOffset = offsetdata.withUnsafeBytes({ ptr in
                ptr.loadUnaligned(as: UInt64.self)
            })
            
            var tableHeader = UOPTableHeader() ;
            tableHeader.nextTable = firstOffset
            while (tableHeader.nextTable != 0) {
                try handle.seek(toOffset: tableHeader.nextTable)
                tableHeader = UOPTableHeader(data: try handle.read(upToCount: UOPTableHeader.RECORDSIZE)!)
                for _ in 0..<tableHeader.numberEntries {
                    let entry = UOPTableEntry(data:try handle.read(upToCount: UOPTableEntry.RECORDSIZE)!)
                    if (entry.isValid) {
                        offset[entry.hash] = entry
                    }
                }
            }
            return offset
        }
        catch {
            return [UInt64:UOPTableEntry]()
        }
    }
    // =================================================================================================
    // Gather uop offsets based on hash
    // =================================================================================================
    //=====================================================================================================
    func gatherUOPOffsets(formatString:String,maxIndex:Int) -> [Int:UOPEntryInformation] {
        guard self.exist else {
            return [Int:UOPEntryInformation]()
        }
        let hashoffset = self.uopTableEntry
        // Make the hashes we are interested in
        var rvalue = [Int:UOPEntryInformation]()
        for index in 0..<maxIndex {
            let hash = hashLittle2(hashstring: String(format: formatString, index))
            if (hashoffset.keys.contains(hash)) {
                rvalue[index] = hashoffset[hash]!.entryInfo
            }
        }
        return rvalue
    }


}
