//
//  CacheProtocol.swift
//  naiveLRU
//
//  Created by Quan Gan on 2022/1/17.
//

import Foundation

protocol CacheProtocol {
    
    var cache_size: Int { get set }
    var lock: NSLock { get }
    
}


