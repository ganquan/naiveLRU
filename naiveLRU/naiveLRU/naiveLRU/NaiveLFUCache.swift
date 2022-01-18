//
//  NaiveLFUCache.swift
//  naiveLRU
//
//  Created by Quan Gan on 2022/1/13.
//

import Foundation


// LFU比LRU多一个freq - ValueList的map
// 如果是刷题的话，不考虑多线层加锁，能够获得微量提升
// 从工程实践的角度来看，考虑应该全面一点
// 通过实现LFU、LRU
// 利用POP、泛型抽象、层次设计等思路，尽量压缩了代码
// LFU和LRU都是很不错的练手题目

extension NaiveLFUCache {
    
    class NaiveLFUCacheValueNode: CacheListNode<NaiveLFUCacheKey, NaiveLFUCacheValue> {
        
        var freq: Int = 0

        override init(_ k: NaiveLFUCacheKey, _ v: NaiveLFUCacheValue) {
            super.init(k, v)
        }
        
        public func useCount() {
            freq += 1
        }
    }
}

class NaiveLFUCache<NaiveLFUCacheKey: Hashable, NaiveLFUCacheValue>: BaseCache {
    
    typealias ValueNodeType = NaiveLFUCacheValueNode
    typealias ValueListType = DLinkedList<ValueNodeType>
    
    private var valueMap: [NaiveLFUCacheKey: ValueNodeType] = [:]       // <key, value wrap in Node with freq>
    private var freqMap: [Int: ValueListType] = [:]                     // <freq, List>
    private var minFreq = 1
    
    init() {
        let default_capacity: Int = 5
        super.init(default_capacity)
    }
    
    init(capacity: Int) {
        super.init(capacity)
    }
    
    var count: Int {
        return valueMap.count
    }
    
    private func resettleNode(_ node: ValueNodeType) {
        
        node.useCount()
        
        if node.freq <= minFreq {
            minFreq = node.freq
        }
        
        if let freqList = freqMap[node.freq] {
            freqList.appendNode(node)
        } else {
            //出现了新的频率
            let newlist = ValueListType()
            newlist.appendNode(node)
            freqMap[node.freq] = newlist
        }
    }
    
    public func setValue(_ value: NaiveLFUCacheValue, forKey key: NaiveLFUCacheKey) {
        
        if cache_size <= 0 {
            return
        }
        
        lock.lock()
        
        if let node = valueMap[key] {
            //有缓存，更新value
            node.val = value
            
            if let freqList = freqMap[node.freq] {
                freqList.removeNode(node)
                
                if freqList.isEmpty {
                    freqMap.removeValue(forKey: node.freq)
                }
            }
            
            resettleNode(node)
            
        } else {
            //无缓存，新增
            //新增之前检查容量，检查是否超出容量，否则移除最旧的缓存
            tryToRetireTheLeastUsedNode()
            
            let node = NaiveLFUCacheValueNode(key, value)
            valueMap[key] = node
            
            resettleNode(node)
        }
        
        lock.unlock()
    }
    
    public func value(forKey key: NaiveLFUCacheKey) -> NaiveLFUCacheValue? {
        
        lock.lock()
        defer { lock.unlock() }
        
        if let node = valueMap[key] {
            //存在
            //从旧频率表中移除
            if let oldFreqList = freqMap[node.freq] {
                oldFreqList.removeNode(node)
                if oldFreqList.isEmpty {
                    freqMap.removeValue(forKey: node.freq)
                }
            }
            
            resettleNode(node)
            
            return node.val
        }
        
        return nil
    }
    
    private func tryToRetireTheLeastUsedNode() {
        
        while count >= cache_size {
            //删除最少使用（频率最低）且最旧缓存
            if let list = freqMap[minFreq], !list.isEmpty, let h = list.head {
                list.removeNode(h)
                valueMap.removeValue(forKey: h.key)
                
                if list.isEmpty {
                    freqMap.removeValue(forKey: minFreq)
                }
                
            } else {
                freqMap.removeValue(forKey: minFreq)
                minFreq += 1
            }
        }
    }
}
