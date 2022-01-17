//
//  Cache.swift
//  naiveLRU
//
//  Created by Quan Gan on 2022/1/17.
//

import Foundation

class BaseCache: CacheProtocol{
    
    var cache_size: Int
    internal var lock: NSLock
    
    init(_ capacity: Int) {
        cache_size = capacity
        lock = NSLock()
    }
}
