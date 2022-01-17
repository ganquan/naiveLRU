//
//  LFUTest.swift
//  naiveLRUTests
//
//  Created by Quan Gan on 2022/1/13.
//

import XCTest

class LFUTest: XCTestCase {
    
    func testCacheSizeLimit() {
        let cache = NaiveLFUCache<Int, Int>(capacity : 2)
        cache.setValue(0, forKey: 0)
        XCTAssertEqual(cache.value(forKey: 0), 0)
        
        cache.setValue(1, forKey: 1)
        cache.setValue(2, forKey: 2)
        XCTAssertEqual(cache.count, 2)
        XCTAssertNil(cache.value(forKey: 1))
        
        cache.setValue(3, forKey: 3)
        cache.setValue(4, forKey: 4)
        cache.setValue(5, forKey: 5)
        XCTAssertEqual(cache.count, 2)
        
        XCTAssertNil(cache.value(forKey: 1))
        XCTAssertNil(cache.value(forKey: 2))
        XCTAssertNil(cache.value(forKey: 3))
        XCTAssertNil(cache.value(forKey: 4))
        
        XCTAssertEqual(cache.value(forKey: 5), 5)
        XCTAssertEqual(cache.value(forKey: 0), 0)
        XCTAssertEqual(cache.count, 2)
    }
    
    func testZeroSize() {
        let cache = NaiveLFUCache<Int, Int>(capacity : 0)
        cache.setValue(0, forKey: 0)
        XCTAssertNil(cache.value(forKey: 0))
    }
    
    func testReplaceValue() {
        let cache = NaiveLFUCache<Int, Int>()
        cache.setValue(0, forKey: 0)
        XCTAssertEqual(cache.value(forKey: 0), 0)

        cache.setValue(1, forKey: 1)
        XCTAssertEqual(cache.value(forKey: 1), 1)

        cache.setValue(2, forKey: 0)
        XCTAssertEqual(cache.value(forKey: 0), 2)
        XCTAssertEqual(cache.value(forKey: 1), 1)
        XCTAssertEqual(cache.count, 2)
    }
    
    
    func testClean() {
        let cache = NaiveLFUCache<Int, Int>()
        cache.setValue(0, forKey: 0)
        cache.setValue(1, forKey: 1)
        cache.setValue(2, forKey: 2)
        cache.setValue(3, forKey: 3)
        cache.setValue(4, forKey: 4)
        
        XCTAssertEqual(cache.value(forKey: 2), 2)
        XCTAssertEqual(cache.value(forKey: 3), 3)
        XCTAssertEqual(cache.value(forKey: 4), 4)
        
        XCTAssertEqual(cache.value(forKey: 3), 3)
        XCTAssertEqual(cache.value(forKey: 4), 4)
        
        //before
        //freq 1: 0, 1
        //freq 2: 2
        //freq 3: 3, 4
        cache.setValue(5, forKey: 5)
        //after
        //freq 1: 5, 1
        //freq 2: 2
        //freq 3: 3, 4
        
        cache.setValue(6, forKey: 6)
        cache.setValue(7, forKey: 7)
        cache.setValue(8, forKey: 8)
        //after
        //freq 1: 7, 8
        //freq 2: 2
        //freq 3: 3, 4
        
        XCTAssertEqual(cache.count, 5)
        
        
        XCTAssertNil(cache.value(forKey: 6))
        XCTAssertEqual(cache.value(forKey: 7), 7)
        XCTAssertEqual(cache.value(forKey: 8), 8)
        //after
        //freq 1:
        //freq 2: 2, 7, 8
        //freq 3: 3, 4
        
        XCTAssertEqual(cache.value(forKey: 2), 2)
        XCTAssertEqual(cache.value(forKey: 7), 7)
        XCTAssertEqual(cache.value(forKey: 8), 8)
        //after
        //freq 1:
        //freq 2:
        //freq 3: 3, 4, 2, 7, 8
        
        cache.setValue(9, forKey: 9)
        //expect
        //freq 1: 9
        //freq 2:
        //freq 3: 4, 2, 7, 8
        //then key == 3 should be nil
        XCTAssertNil(cache.value(forKey: 3))
        XCTAssertEqual(cache.count, 5)
        
        XCTAssertEqual(cache.value(forKey: 9), 9)
        XCTAssertEqual(cache.value(forKey: 9), 9)
        XCTAssertEqual(cache.value(forKey: 9), 9)
        //after
        //freq 1:
        //freq 2:
        //freq 3: 4, 2, 7, 8, 9
        
        cache.setValue(10, forKey: 10)
        //after
        //freq 1: 10
        //freq 2:
        //freq 3: 2, 7, 8, 9
        XCTAssertNil(cache.value(forKey: 4))
        
        XCTAssertEqual(cache.value(forKey: 10), 10)
        XCTAssertEqual(cache.value(forKey: 2), 2)
        XCTAssertEqual(cache.value(forKey: 7), 7)
        XCTAssertEqual(cache.value(forKey: 8), 8)
        XCTAssertEqual(cache.value(forKey: 9), 9)
        //after
        //freq 1:
        //freq 2: 10
        //freq 3:
        //freq 4: 2, 7, 8, 9
        
        XCTAssertEqual(cache.value(forKey: 10), 10)
        XCTAssertEqual(cache.value(forKey: 10), 10)
        //after
        //freq 1:
        //freq 2:
        //freq 3:
        //freq 4: 2, 7, 8, 9, 10
        
        XCTAssertEqual(cache.value(forKey: 7), 7)
        XCTAssertEqual(cache.value(forKey: 8), 8)
        XCTAssertEqual(cache.value(forKey: 9), 9)
        //after
        //freq 1:
        //freq 2:
        //freq 3:
        //freq 4: 2, 10, 7, 8, 9
        
        cache.setValue(11, forKey: 11)
        //after
        //freq 1: 11
        //freq 2:
        //freq 3:
        //freq 4: 10, 7, 8, 9
        
        cache.setValue(12, forKey: 12)
        //after
        //freq 1: 12
        //freq 2:
        //freq 3:
        //freq 4: 10, 7, 8, 9
        
        
        XCTAssertEqual(cache.count, 5)
        XCTAssertNil(cache.value(forKey: 11))
        XCTAssertEqual(cache.value(forKey: 10), 10)
        XCTAssertEqual(cache.value(forKey: 7), 7)
        XCTAssertEqual(cache.value(forKey: 8), 8)
        XCTAssertEqual(cache.value(forKey: 9), 9)
        XCTAssertEqual(cache.value(forKey: 12), 12)
        //after
        //freq 1:
        //freq 2: 12
        //freq 3:
        //freq 4:
        //freq 5: 10, 7, 8, 9
    }
}
