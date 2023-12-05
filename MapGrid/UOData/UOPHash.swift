//Copyright © 2023 Charles Kerr. All rights reserved.

import Foundation

// ===========================================================================
// Hash routines
// ===========================================================================

//=====================================================================================================
public func hashLittle2(hashstring:String) -> UInt64 {
    
    guard let stringdata = hashstring.data(using: .ascii) else {
        return 0
    }
    
    var a = UInt32(0)
    var b = UInt32(0)
    var c = UInt32(0)
    
    var k = 0
    
    var length = UInt32(stringdata.count)
    
    c = UInt32(0xDEADBEEF) + length
    a = c
    b = c
    
    while length > 12 {
        a = a &+ UInt32(stringdata[k])
        a = a &+ (UInt32(stringdata[k+1]) << 8)
        a = a &+ (UInt32(stringdata[k+2]) << 16)
        a = a &+ (UInt32(stringdata[k+3]) << 24)
        b = b &+ UInt32(stringdata[k+4])
        b = b &+ (UInt32(stringdata[k+5]) << 8)
        b = b &+ (UInt32(stringdata[k+6]) << 16)
        b = b &+ (UInt32(stringdata[k+7]) << 24)
        c = c &+ UInt32(stringdata[k+8])
        c = c &+ (UInt32(stringdata[k+9]) << 8)
        c = c &+ (UInt32(stringdata[k+10]) << 16)
        c = c &+ (UInt32(stringdata[k+11]) << 24)
        
        a = a &- c
        a = a ^ ((c<<4) | (c>>28))
        c = c &+ b
        
        b = b &- a
        b = b ^ ( (a<<6) | (a>>26))
        a = a &+ c
        
        c = c &- b
        c = c ^ ( (b<<8) | (b>>24))
        b = b &+ a

        a = a &- c
        a = a ^ ((c<<16) | (c>>16))
        c = c &+ b

        b = b &- a
        b = b ^ ( (a<<19) | (a>>13))
        a = a &+ c

        c = c &- b
        c = c ^ ( (b<<4) | (b>>28))
        b = b &+ a
        
        length -= 12
        k += 12
    }
    if (length != 0){
        switch (length) {
            case 12:
                c = c &+ (UInt32(stringdata[k+11]) << 24)
                fallthrough
            case 11:
                c = c &+ (UInt32(stringdata[k+10]) << 16)
                fallthrough
            case 10:
                c = c &+ (UInt32(stringdata[k+9]) << 8)
                fallthrough
            case 9:
                c = c &+ UInt32(stringdata[k+8])
                fallthrough
            case 8:
                b = b &+ (UInt32(stringdata[k+7]) << 24)
                fallthrough
            case 7:
                b = b &+ (UInt32(stringdata[k+6]) << 16)
                fallthrough
            case 6:
                b = b &+ (UInt32(stringdata[k+5]) << 8)
                fallthrough
            case 5:
                b = b &+ UInt32(stringdata[k+4])
                fallthrough
            case 4:
                a = a &+ (UInt32(stringdata[k+3]) << 24)
                fallthrough
            case 3:
                a = a &+ (UInt32(stringdata[k+2]) << 16)
                fallthrough
            case 2:
                a = a &+ (UInt32(stringdata[k+1]) << 8)
                fallthrough
            case 1:
                a = a &+ UInt32(stringdata[k])
                c ^= b
                c = c &- ( ( b << 14) | ( b >> 18 ))
                a ^= c
                a = a &- ( ( c<<11 ) | ( c>>21 ))
                b ^= a
                b = b &- ( ( a<<25 ) | ( a>>7) )
                c ^= b
                c = c &- ( ( b<<16 ) | ( b>>16 ))
                a ^= c
                a = a &- ( (c << 4)  | (c >> 28) )
                b ^= a;
                b = b &- ( (a << 14) | (a >> 18) )
                c ^= b;
                c =  c &- ( (b << 24) | (b >> 8) )

            default:
                break
        }
    }
    return (UInt64(b)<<32) | (UInt64(c))
}

//=====================================================================================================
public func hashAdler32(data:Data) -> UInt32 {
    var a = UInt32(1)
    var b = UInt32(0)
    for entry in data {
        a = (a + UInt32(entry)) % 0xFFF1
        b = ( b + a ) & 0xFFF1
    }
    return (b<<16) | a
}
