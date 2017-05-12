//
//  PriorityQueue.swift
//  PuzzleProject
//
//  Created by 范祎楠 on 2016/12/12.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import Foundation

class PriorityQueue<T> {
  
  var data: [T] = []
  var compare: ((T, T) -> ComparisonResult)
  var isEmpty: Bool { return data.isEmpty }
  
  init(compare: @escaping ((T, T) -> ComparisonResult)) {
    self.compare = compare
  }
  
  func enQueue(element: T) {
    
    heapInsert(with: element)
    
//    print(data.map({"\($0)"}).joined(separator: ", "))
    
  }
  
  func deQueue() -> T? {
    
    guard let heapRootNode = data.first else { return nil }
    data[0] = data.last!
    data = [T](data.dropLast(1))
    
    adjustHeapForRootNode()
    
//    print(data.map({"\($0)"}).joined(separator: ", "))
    
    return heapRootNode
  }
 
  func removeAll() {
    data.removeAll()
  }
  
  private func heapInsert(with element: T) {
    
    data += [element]

    adjustHeapForLastItem()
  }
  
  private func adjustHeapForLastItem() {
  
    var targetNodeIndex = data.count - 1
    let targetValue = data[targetNodeIndex]
    
    while targetNodeIndex > 0 {
      
      let parentNodeIndex = (targetNodeIndex - 1) / 2
      
      guard compare(data[parentNodeIndex], targetValue) == .orderedAscending else {
        
        break
      }
      
      data[targetNodeIndex] = data[parentNodeIndex]
      targetNodeIndex = parentNodeIndex
      
    }
    
    data[targetNodeIndex] = targetValue
    
  }
  
  private func adjustHeapForRootNode() {
    
    guard data.count > 1 else { return }
    
    var targetNodeIndex = 0
    let targetNodeValue = data[targetNodeIndex]
    
    while targetNodeIndex < data.count {
      
      var maxChildNodeIndex: Int = 0
      
      let leftChildIndex = targetNodeIndex * 2 + 1
      
      if leftChildIndex < data.count {
        
        maxChildNodeIndex = leftChildIndex
        
      } else {
        
        break
      }
      
      let rightChildIndex = targetNodeIndex * 2 + 2
      
      if rightChildIndex < data.count && compare(data[maxChildNodeIndex], data[rightChildIndex]) == .orderedAscending {
        
        maxChildNodeIndex = rightChildIndex
        
      }
      
      guard compare(targetNodeValue, data[maxChildNodeIndex]) == .orderedAscending else {
        break
      }
      
      data[targetNodeIndex] = data[maxChildNodeIndex]
      
      targetNodeIndex = maxChildNodeIndex

    }
    
    data[targetNodeIndex] = targetNodeValue
    
  }
}
