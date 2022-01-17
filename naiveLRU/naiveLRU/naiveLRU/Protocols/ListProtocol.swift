//
//  List.swift
//  naiveLRU
//
//  Created by Quan Gan on 2022/1/13.
//

import Foundation

protocol ListNodeProtocol: AnyObject {
    associatedtype ValueType
    associatedtype NodeType: ListNodeProtocol
    
    var val: ValueType { get set }
    var prev: NodeType? { get set }
    var next: NodeType? { get set }
}

protocol DLinkedListProtocol: AnyObject {
    associatedtype ListNodeType: ListNodeProtocol
    
    var head: ListNodeType? { get set }
    var tail: ListNodeType? { get set }
    
    var isEmpty: Bool {get}
    
    func appendNode(_ node: ListNodeType?)
    func removeNode(_ node: ListNodeType?)
}

extension DLinkedListProtocol {
    
    var isEmpty: Bool {
        get {
            return (head == nil && tail == nil)
        }
    }
    
    func appendNode(_ node: ListNodeType?) {
        if head == nil {
            head = node
        }
        
        node?.prev = tail as? Self.ListNodeType.NodeType
        tail?.next = node as? Self.ListNodeType.NodeType
        tail = node
    }
    
    func removeNode(_ node: ListNodeType?) {
        
        if node === head {
            head = node?.next as? Self.ListNodeType
        }
        
        if node === tail {
            tail = node?.prev as? Self.ListNodeType
        }
        
        node?.prev?.next = node?.next as? Self.ListNodeType.NodeType.NodeType
        node?.next?.prev = node?.prev as? Self.ListNodeType.NodeType.NodeType
        
        node?.prev = nil
        node?.next = nil
    }
}



