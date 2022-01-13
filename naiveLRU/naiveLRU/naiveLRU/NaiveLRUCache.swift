//
//  NaiveLRUCache.swift
//  naiveLRU
//
//  Created by Quan Gan on 2022/1/13.
//

import Foundation


// LRU本质上是解决两个问题
// 1、缓存查找性能
// 2、缓存的增、删、改性能，而且要求缓存有序
// 最快的查找必然是哈希表
// 增、删、改性能最好的是双向链表
// 所以LRUCache的底层数据结构就是哈希表和双链表，结合这两个数据结构的优点解决两个问题
// LRU缓存的实现考察，其实是一个很好的综合考察题目
// 重要的两个基础数据结构都覆盖到了

// 多线层安全的话，有两个解决思路
// 1、直接用锁，这个是最容易想到的办法。但是一不小心会搞出死锁来，要小心。
// 例如 setValue(_ value: NaiveLRUCacheValue?, forKey key: NaiveLRUCacheKey) 方法中
// 如果把上锁动作提到函数进入后第一行，则会出现 guard else 中直接return的情况导致最后的unlock不能执行
// 这里如果利用defer { lock.unlock() }的方法实现锁操作成对处理，但是函数结尾的clean()就会出现死锁
// 2、用串行队列再封一层，把所有需要上锁的行为，都通过队列串行化
// 但可能需要调整代码，以确保一些行为进队列后依旧可以保证是紧挨着直行的，而不会被其他线程插入的任务打断
// 例如setValue末尾的clean操作

// 站在考察候选人的立场来看，如果候选人可以把LRU理解和实现都搞清楚，基本上可以认为数据结构基础是没有问题的

class NaiveLRUCache<NaiveLRUCacheKey: Hashable, NaiveLRUCacheValue> {
    
    private var map: [NaiveLRUCacheKey: DoubleLinkedListNode] = [:]
    private var head: DoubleLinkedListNode?
    private var tail: DoubleLinkedListNode?
    
    public var max_cache_size: UInt {
        didSet { clean() }
    }
    private var lock: NSLock
    
    init() {
        max_cache_size = 5
        lock = NSLock()
    }
    
    init(cache_size: UInt) {
        max_cache_size = cache_size
        
        lock = NSLock()
    }
    
    public func setValue(_ value: NaiveLRUCacheValue?, forKey key: NaiveLRUCacheKey) {
        
        guard value != nil else {
            removeValue(forKey: key)
            return
        }
        
        lock.lock()
        
        if let node = map[key] {
            //有缓存，更新value
            node.val = value
            
            //移除旧缓存，放到最新
            removeNode(node)
            appendNode(node)
            
        } else {
            //无缓存，增加node
            let n = DoubleLinkedListNode(value, key)
            map[key] = n
            appendNode(n)
        }
        
        lock.unlock()
        
        //检查是否超出容量，则移除最旧的缓存
        clean()
    }

    public func value(forKey key: NaiveLRUCacheKey) -> NaiveLRUCacheValue? {
     
        lock.lock()
        defer { lock.unlock() }
        
        if let v:DoubleLinkedListNode = map[key] {
            
            //移除缓存然后再放到最新
            removeNode(v)
            appendNode(v)
            
            return v.val
        }
        
        return nil
    }
    
    @discardableResult
    public func removeValue(forKey key: NaiveLRUCacheKey) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        guard let v:DoubleLinkedListNode = map.removeValue(forKey: key) else {
            
            return false
        }
        
        removeNode(v)
        
        return true
        
    }
    
    public func clearAllCache() {
        
        lock.lock()
        defer { lock.unlock() }
        
        map.removeAll()
        head = nil
        tail = nil
    }
}


extension NaiveLRUCache {
    
    var count: UInt {
        return UInt(map.count)
    }
    
    var isEmpty: Bool {
        return map.isEmpty
    }
}

extension NaiveLRUCache {
    class DoubleLinkedListNode {
        
        var val: NaiveLRUCacheValue?
        var key: NaiveLRUCacheKey
        weak var prev: DoubleLinkedListNode?
        weak var next: DoubleLinkedListNode?
        
        init(_ v: NaiveLRUCacheValue?, _ k: NaiveLRUCacheKey) {
            val = v
            key = k
            prev = nil
            next = nil
        }
        
        
        init(_ v: NaiveLRUCacheValue?, _ k: NaiveLRUCacheKey, _ p: DoubleLinkedListNode?, _ n: DoubleLinkedListNode?) {
            val = v
            key = k
            prev = p
            next = n
        }
    }
    
    public func removeNode(_ node: DoubleLinkedListNode) {
        
        if node === head {
            head = node.next
        }
        
        if node === tail {
            tail = node.prev
        }
        
        node.prev?.next = node.next
        node.next?.prev = node.prev
        
        node.prev = nil
        node.next = nil
        
    }
    
    public func appendNode(_ node: DoubleLinkedListNode) {
        
        if head == nil {
            head = node
        }
        
        node.prev = tail
        tail?.next = node
        tail = node
    }

    public func clean() {
        
        lock.lock()
        defer { lock.unlock() }
        
        while count > max_cache_size, let h = head {
            //删除最旧缓存
            removeNode(h)
            map.removeValue(forKey: h.key)
        }

    }
}
