//
//  ListTest.swift
//  naiveLRUTests
//
//  Created by Quan Gan on 2022/1/13.
//

import XCTest

class ListTest: XCTestCase {

    func testList() {
        
        
        let list = DLinkedList<ListNode<Int>>()

        let node1 = ListNode<Int>(1)
        let node2 = ListNode<Int>(2)
        let node3 = ListNode<Int>(3)
        list.appendNode(node1)
        list.appendNode(node2)
        list.appendNode(node3)
        
        XCTAssert(list.isEmpty == false)
        
        list.removeNode(node1)
        
        XCTAssert(list.isEmpty == false)
        
        list.removeNode(node2)
        list.removeNode(node3)
        
        XCTAssert(list.isEmpty == true)
        
    }

}
