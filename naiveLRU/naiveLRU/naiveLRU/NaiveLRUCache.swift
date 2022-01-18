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
// 2、用串行队列再封一层，把所有需要上锁的行为，都通过队列串行化
// 但可能需要调整代码，以确保一些行为进队列后依旧可以保证是紧挨着直行的，而不会被其他线程插入的任务打断
// 站在考察候选人的立场来看，如果候选人可以把LRU理解和实现都搞清楚，基本上可以认为数据结构基础是没有问题的

class NaiveLRUCache<NaiveLRUCacheKey: Hashable, NaiveLRUCacheValue>: BaseCache {
    
    typealias ValueNodeType = CacheListNode<NaiveLRUCacheKey, NaiveLRUCacheValue>
    
    private var valueMap: [NaiveLRUCacheKey: ValueNodeType] = [:]
    private var list: DLinkedList<ValueNodeType>

    init() {
        
        let default_capacity: Int = 5
        list = DLinkedList<ValueNodeType>()
        
        super.init(default_capacity)
    }
    
    init(capacity: Int) {
        
        list = DLinkedList<ValueNodeType>()
        super.init(capacity)
    }
    
    var count: Int {
        return valueMap.count
    }
    
    public func setValue(_ value: NaiveLRUCacheValue, forKey key: NaiveLRUCacheKey) {
        
        if cache_size <= 0 {
            return
        }
        
        lock.lock()
        
        if let node = valueMap[key] {
            //有缓存，更新value
            node.val = value
            
            //移除旧缓存，放到最新
            list.removeNode(node)
            list.appendNode(node)
            
        } else {
            //无缓存，增加node
            let n = CacheListNode<NaiveLRUCacheKey, NaiveLRUCacheValue>(key, value)
            valueMap[key] = n
            list.appendNode(n)
        }
        
        lock.unlock()
        
        //检查是否超出容量，则移除最旧的缓存
        clean()
    }

    public func value(forKey key: NaiveLRUCacheKey) -> NaiveLRUCacheValue? {
     
        lock.lock()
        defer { lock.unlock() }
        
        if let v:CacheListNode = valueMap[key] {
            
            //移除缓存然后再放到最新
            list.removeNode(v)
            list.appendNode(v)
            
            return v.val
        }
        
        return nil
    }
    
    @discardableResult
    public func removeValue(forKey key: NaiveLRUCacheKey) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        guard let v:CacheListNode = valueMap.removeValue(forKey: key) else {
            
            return false
        }
        
        list.removeNode(v)
        
        return true
    }
    
    private func clean() {
        
        lock.lock()
        defer { lock.unlock() }
        
        while count > cache_size, let h = list.head {
            //删除最旧缓存
            list.removeNode(h)
            valueMap.removeValue(forKey: h.key)
        }
    }
}
