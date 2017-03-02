//
//  AStarSearcher.swift
//  PuzzleProject
//
//  Created by 范祎楠 on 2016/12/12.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import Foundation

class AStarSearcher: PuzzlePathSearcher {
  
  var open: PriorityQueue<PuzzleNode>!
  var close: Set<String> = []
  
  func search(with startPuzzleNode: PuzzleNode, with targetPuzzleNode: PuzzleNode) -> [SwapPath] {
    
    startPuzzleNode.parentStatus = nil
    
    open = PriorityQueue<PuzzleNode> { (a, b) -> ComparisonResult in
      
      guard a.fValue != b.fValue else { return .orderedSame }
      
      return a.fValue > b.fValue ? .orderedAscending : .orderedDescending
    }
    
    open.removeAll()
    close.removeAll()
    
    open.enQueue(element: startPuzzleNode)
    
    var count = 0
    
    while let currentStatus = open.deQueue() {
      
//      print("--------\(count)---------------")
//      
//      print("open: \(open.data[0..<min(10, open.data.count)].map({"\($0.fValue)"}).joined(separator: ", "))")
//      print("current: \(currentStatus.indices)")
      count += 1
      
      guard !close.contains(currentStatus.identifier) else { continue }
      
      if currentStatus == targetPuzzleNode {
        
        let path = currentStatus.createPath()
        
//        path.forEach({print($0.indices)})
        
        print(path.count)
        print(count)
        return path
      }
      
      close.insert(currentStatus.identifier)
      
      for node in currentStatus.childNodes {
        
        node.gValue = currentStatus.gValue + 1
        node.hValue = node.estimate()
        node.fValue = node.hValue + node.gValue
        
//        print("child: \(node.indices) \(node.fValue)")
        open.enQueue(element: node)
      }
    }
    
    return []
  }
  
}
