//Copyright © 2023 Charles Kerr. All rights reserved.

import Foundation
// ===========================================================================
// UOPEntryInformation
// We make all of the entries unsigned 64, to prevent casting when we use the data
// We choose unsigned as the first entry is unsigned
// ===========================================================================
// ===========================================================================
struct UOPEntryInformation {
    public static let RECORDSIZE = 22
    public var fileOffset: UInt64 = 0
    public var headerLength: UInt64 = 0
    public var compressedLength:UInt64 = 0
    public var decompressedLength:UInt64 = 0
    public var isCompressed: Bool = false
}
// ===========================================================================
extension UOPEntryInformation {
    // ===========================================================================
    init(data:Data){
        self.init()
        guard data.count >= UOPEntryInformation.RECORDSIZE else {
            return  // We could throw here, something to think about
        }
        fileOffset = data.withUnsafeBytes { ptr in
            ptr.loadUnaligned(fromByteOffset: 0, as: UInt64.self)
        }
        headerLength = data.withUnsafeBytes { ptr in
            UInt64(truncatingIfNeeded: ptr.loadUnaligned(fromByteOffset: 8, as: UInt32.self))
        }
        compressedLength = data.withUnsafeBytes { ptr in
            UInt64(truncatingIfNeeded: ptr.loadUnaligned(fromByteOffset: 12, as: UInt32.self))
        }
        decompressedLength = data.withUnsafeBytes { ptr in
            UInt64(truncatingIfNeeded: ptr.loadUnaligned(fromByteOffset: 16, as: UInt32.self))
        }
        isCompressed = data.withUnsafeBytes { ptr in
            ptr.loadUnaligned(fromByteOffset: 20, as: UInt16.self) != 0
        }
    }
    
    // ===========================================================================
    public  var data:Data {
        var rvalue = fileOffset.data
        rvalue.append( UInt32(truncatingIfNeeded: headerLength).data)
        rvalue.append( UInt32(truncatingIfNeeded: compressedLength).data)
        rvalue.append( UInt32(truncatingIfNeeded: decompressedLength).data)
        rvalue.append( (isCompressed ? UInt16(1):UInt16(0)).data)
        return rvalue
    }
    
    // ===========================================================================
    public var isValid:Bool {
        return self.fileOffset != 0 && self.decompressedLength != 0
    }
}

// ===========================================================================
// UOPTableEntry
// ===========================================================================

// ===========================================================================
struct UOPTableEntry {
    public static let RECORDSIZE = 34
    public var hash :UInt64 = 0
    public var dataHash :Int = 0
    public var entryInfo: UOPEntryInformation = UOPEntryInformation()
}

extension UOPTableEntry {
    // ===========================================================================
    init(data:Data) {
        self.init()
        guard data.count >= UOPTableEntry.RECORDSIZE else {
            return
        }
        hash = data.withUnsafeBytes { ptr in
            ptr.loadUnaligned(fromByteOffset: 20, as: UInt64.self)
        }
        dataHash = data.withUnsafeBytes { ptr in
            Int(truncatingIfNeeded:  ptr.loadUnaligned(fromByteOffset: 28, as: UInt32.self))
        }
        entryInfo = UOPEntryInformation(data: data[data.startIndex..<data.startIndex+UOPEntryInformation.RECORDSIZE])
    }
    // ===========================================================================
    public var data:Data {
        var rvalue = hash.data
        rvalue.append(UInt32(truncatingIfNeeded: dataHash).data)
        rvalue.append(entryInfo.data)
        return rvalue
    }
    // ===========================================================================
    public var isValid:Bool {
        return entryInfo.isValid
    }
}
// ===========================================================================
// UOPTableHeader
// ===========================================================================
struct UOPTableHeader {
    public static let RECORDSIZE = 12
    public var numberEntries: Int = 0
    public var nextTable: UInt64 = 0
}
// ===========================================================================
extension UOPTableHeader {
    // ===========================================================================
    init(data:Data) {
        self.init()
        guard data.count >= UOPTableHeader.RECORDSIZE else {
            return
        }
        numberEntries = data.withUnsafeBytes { ptr in
            Int(truncatingIfNeeded: ptr.loadUnaligned(fromByteOffset: 0, as: UInt32.self))
        }
        nextTable = data.withUnsafeBytes { ptr in
            ptr.loadUnaligned(fromByteOffset: 4, as: UInt64.self)
        }
    }
    
    // ===========================================================================
    public  var data:Data {
        var rvalue = UInt32(truncatingIfNeeded: numberEntries).data
        rvalue.append(nextTable.data)
        return rvalue
    }
}

