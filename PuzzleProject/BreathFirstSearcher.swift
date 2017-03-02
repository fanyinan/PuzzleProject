//
//  BreathFirstSearcher.swift
//  PuzzleProject
//
//  Created by 范祎楠 on 2016/12/8.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import Foundation

class BreathFirstSearcher: PuzzlePathSearcher {
  
  var open: [PuzzleNode] = []
  var close: Set<String> = []

  internal func search(with startPuzzleNode: PuzzleNode, with targetPuzzleNode: PuzzleNode) -> [SwapPath] {

    open.removeAll()
    close.removeAll()
    
    open += [startPuzzleNode]
    
    var count = 0
    
    while !open.isEmpty {
      
      count += 1
      
      let currentStatus = open.removeFirst()

      guard !close.contains(currentStatus.identifier) else { continue }
      
      if currentStatus == targetPuzzleNode {
        
        let path = currentStatus.createPath()
        
        print(count)
        return path
      }
      
      close.insert(currentStatus.identifier)
      
      open += currentStatus.childNodes

    }
    
    return []
  }
}
