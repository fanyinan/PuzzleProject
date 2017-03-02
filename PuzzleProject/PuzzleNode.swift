//
//  PuzzleNode.swift
//  PuzzleProject
//
//  Created by 范祎楠 on 2016/12/8.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import Foundation

class PuzzleNode {
  
  var indices: [Int]
  var blankIndex: Int
  var blankNumber: Int
  var order: Int
  var parentStatus: PuzzleNode? = nil
  var swapPath: SwapPath? = nil
  
  var hValue = 0
  var gValue = 0
  var fValue: Int = 0

  var childNodes: [PuzzleNode] {
    return getChildNodes()
  }

  var identifier: String {
    return indices.map({String($0)}).joined(separator: " ")
  }
  
  init(indices: [Int], blankNumber: Int, order: Int) {
    self.indices = indices
    self.blankIndex = indices.index(of: blankNumber)!
    self.blankNumber = blankNumber
    self.order = order
  }
  
  func copy() -> PuzzleNode {
    return PuzzleNode(indices: indices, blankNumber: blankNumber, order: order)
  }
  
  func getChildNodes() -> [PuzzleNode] {
    
    var childNodes: [PuzzleNode] = []
    
    for index in [blankIndex - order, blankIndex + order, blankIndex - 1, blankIndex + 1] {
      
      if let node = swap(with: index), (parentStatus == nil || node != parentStatus!) {
        
        node.parentStatus = self
        node.swapPath = SwapPath(fromIndex: index, toIndex: blankIndex)

        childNodes += [node]
      }
    }
    
    return childNodes
  }
  
  func createPath() -> [SwapPath] {
  
    var swapPaths: [SwapPath] = []
    
    if let parentStatus = parentStatus {
      
      swapPaths += parentStatus.createPath()
      
    }
    
    if let swapPath = swapPath {
      swapPaths.append(swapPath)
    }
    
    return swapPaths
  }
  
  func estimate() -> Int {
  
    var manhattanDistance = 0
    
    for i in 0..<order * order {
      
      guard i != blankIndex else { continue }
      
      let currentPiece = indices[i]
      
      manhattanDistance += Position(row: i / order, col: i % order).getManhattanDistance(to: Position(row: currentPiece / order, col: currentPiece % order))
      
    }
    
    return manhattanDistance * 5
  }
  
  private func swap(with index: Int) -> PuzzleNode? {
    
    if index >= 0 && index < order * order && !(blankIndex - 1 == index && blankIndex % order == 0) && !(blankIndex + 1 == index && blankIndex % order == order - 1) {
      
      let node = copy()
      
      node.indices[blankIndex] = node.indices[index]
      node.indices[index] = blankNumber
      
      node.blankIndex = index
      
      return node
    }
    
    return nil
  }
}

func ==(lhs: PuzzleNode, rhs: PuzzleNode) -> Bool {
  
  guard lhs.order == rhs.order else { return false }
  
  for i in 0..<lhs.order * lhs.order {
    
    if lhs.indices[i] != rhs.indices[i] {
      return false
    }
  }
  
  return true
}

func !=(lhs: PuzzleNode, rhs: PuzzleNode) -> Bool {
  return !(lhs == rhs)
}
