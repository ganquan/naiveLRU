//
//  list.swift
//  naiveLRU
//
//  Created by Quan Gan on 2022/1/17.
//

import Foundation

class DLinkedList<T: ListNodeProtocol>: DLinkedListProtocol {
    typealias NodeType = T
    typealias ListNodeType = T
    
    weak var head: T?
    weak var tail: T?
    
    init() {
        
    }
}

class ListNode<T>: ListNodeProtocol {
    typealias ValueType = T
    typealias NodeType = ListNode
    
    var val: T
    var prev: ListNode<T>?
    var next: ListNode<T>?
    
    init(_ value: T) {
        val = value
    }
}

class CacheListNode<KeyType, ValueType>: ListNode<ValueType> {
    
    var key: KeyType
    
    init(_ k: KeyType, _ v: ValueType) {
        key = k
        
        super.init(v)
    }
}
