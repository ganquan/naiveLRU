//
//  naiveLRUTests.swift
//  naiveLRUTests
//
//  Created by Quan Gan on 2022/1/13.
//

import XCTest
@testable import naiveLRU

class naiveLRUTests: XCTestCase {
    
    func testLRU() {
        let cache = NaiveLRUCache<Int, Int>(capacity: 3)
        cache.setValue(0, forKey: 0)
        cache.setValue(1, forKey: 1)
        cache.setValue(2, forKey: 2)
        XCTAssertEqual(cache.count, 3)
        
        cache.setValue(4, forKey: 4)
        XCTAssertEqual(cache.count, 3)
        
        XCTAssertEqual(cache.value(forKey: 1), 1)
        
        //before setValue, cache should be 2,4,1
        cache.setValue(5, forKey: 5)
        //after setValue, cache should be 4, 1, 5
  
        XCTAssertEqual(cache.count, 3)
        XCTAssertEqual(cache.value(forKey: 4), 4)
        XCTAssertEqual(cache.value(forKey: 1), 1)
        XCTAssertEqual(cache.value(forKey: 5), 5)
        
        XCTAssertNil(cache.value(forKey: 0))
        XCTAssertNil(cache.value(forKey: 2))
        XCTAssertNil(cache.value(forKey: 3))
    }
    

    func testCacheSizeLimit() {
        let cache = NaiveLRUCache<Int, Int>(capacity: 2)
        cache.setValue(0, forKey: 0)
        XCTAssertNotNil(cache.value(forKey: 0))
        
        cache.setValue(1, forKey: 1)
        cache.setValue(2, forKey: 2)
        XCTAssertNil(cache.value(forKey: 0))
        XCTAssertNotNil(cache.value(forKey: 1))
        XCTAssertNotNil(cache.value(forKey: 2))
        XCTAssertEqual(cache.count, 2)
    }
    
    
    func testReplaceValue() {
        let cache = NaiveLRUCache<Int, Int>()
        cache.setValue(0, forKey: 0)
        XCTAssertEqual(cache.value(forKey: 0), 0)

        cache.setValue(1, forKey: 1)
        XCTAssertEqual(cache.value(forKey: 1), 1)

        cache.setValue(2, forKey: 0)
        XCTAssertEqual(cache.value(forKey: 0), 2)
        XCTAssertEqual(cache.value(forKey: 1), 1)
    }
    
    func testRemoveValue() {
        let cache = NaiveLRUCache<Int, Int>(capacity: 2)
        cache.setValue(0, forKey: 0)
        cache.setValue(1, forKey: 1)
        XCTAssertEqual(cache.removeValue(forKey: 0), true)
        XCTAssertEqual(cache.count, 1)
    }
}
