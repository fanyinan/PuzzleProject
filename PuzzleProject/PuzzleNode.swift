//
//  swift
//  PuzzleProject
//
//  Created by 范祎楠 on 2016/12/8.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import Foundation

class PuzzleNode {
  
  private var previousPosition: Position = Position(row: -1, col: -1)//记录随机排序时移动之前的位置

  var indices: [Int]
  var blankIndex: Int
  var blankNumber: Int
  var order: Int
  var parentStatus: PuzzleNode? = nil
  var swapPath: SwapPath? = nil
  
  var gValue = 0
  var fValue = 0

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
  
  
  func numberOfItem() -> Int {
    
    return order * order
  }
  
  func getPosition(at index: Int) -> Position {
    
    let row = index / order
    let col = index - (order * row)
    
    return Position(row: row, col: col)
  }
  
  func getAdjacentPositions(at position: Position) -> [Position]{
    
    var adjacentPositions: [Position] = []
    
    if position.row + 1 >= 0 && position.row + 1 < order {
      adjacentPositions += [Position(row: position.row + 1, col: position.col)]
    }
    
    if position.row - 1 >= 0 && position.row - 1 < order {
      adjacentPositions += [Position(row: position.row - 1, col: position.col)]
    }
    
    if position.col + 1 >= 0 && position.col + 1 < order {
      adjacentPositions += [Position(row: position.row , col: position.col + 1)]
    }
    
    if position.col - 1 >= 0 && position.col - 1 < order {
      adjacentPositions += [Position(row: position.row , col: position.col - 1)]
    }
    
    return adjacentPositions
  }
  
  func getIndex(at position: Position) -> Int {
    
    let index = position.row * order + position.col
    
    return index
  }
  
  func swap(from fromPosition: Position, to toPosition: Position) -> SwapPath {
    
    let fromIndex = getIndex(at: fromPosition)
    let toIndex = getIndex(at: toPosition)
    
    return SwapPath(fromIndex: fromIndex, toIndex: toIndex)
  }
  
  /**
   获得移动块所需的路径
   
   - parameter fromIndex: 起始位置，UI上index
   - parameter toIndex:   目的位置，UI上的index
   - parameter avoidIndexList: 不可被移动的块
   
   - returns: 移动路径
   */
  func getPath(from fromIndex: Int, to toIndex: Int, with avoidIndexList: Set<Int>) -> [SwapPath]? {
    
    if fromIndex == toIndex {
      return []
    }
    
    let fromPosition = getPosition(at: fromIndex)
    let toPosition = getPosition(at: toIndex)
    
    //获得相邻的position
    var adjacentPositions = getAdjacentPositions(at: fromPosition)
    //过滤掉移动过来的position
    adjacentPositions = adjacentPositions.filter({!$0.equal(toPosition: previousPosition)})
    
    //过滤掉不会被移动的index的position
    for avoidIndex in avoidIndexList {
      adjacentPositions = adjacentPositions.filter({!$0.equal(toPosition: getPosition(at: avoidIndex))})
    }
    
    //按照blankindex与toindex的距离排序
    adjacentPositions = adjacentPositions.sorted(by: {$0.getDistance(to: toPosition) < $1.getDistance(to: toPosition)})
    
    //如果有多个相邻position且前两个距离toindex的距离相同
    if adjacentPositions.count > 1 && adjacentPositions[0].getDistance(to: toPosition) == adjacentPositions[1].getDistance(to: toPosition) {
      
      //获得toindex的相邻position
      var toIndexAdjacentPositions = getAdjacentPositions(at: toPosition)
      
      for avoidIndex in avoidIndexList {
        toIndexAdjacentPositions = toIndexAdjacentPositions.filter({!$0.equal(toPosition: getPosition(at: avoidIndex))})
      }
      
      //如果toindex的可移动的position只有一个，就按照之前两个距离相同的position距离该position的距离排序；否则有死循环情况
      if toIndexAdjacentPositions.count == 1 {
        
        adjacentPositions = adjacentPositions.sorted(by: {$0.getDistance(to: toIndexAdjacentPositions[0]) < $1.getDistance(to: toIndexAdjacentPositions[0])})
      }
      
    }
    
    //深度优先遍历
    for adjacentPosition in adjacentPositions {
      
      let currentPath = swap(from: fromPosition, to: adjacentPosition)
      
      //保存，用于下一次过滤掉这个位置，避免往回走
      previousPosition = fromPosition
      
      let nextPathList = getPath(from: currentPath.toIndex, to: toIndex, with: avoidIndexList)
      
      if nextPathList == nil {
        
        continue
      }
      
      let finalPathList = [currentPath] + nextPathList!
      
      return finalPathList
    }
    
    return nil
    
  }
  
  func makePreviousPositionEmpty() {
    previousPosition = Position(row: -1, col: -1)
  }
  
  func printList() {
    print("------------------------")
    var text = ""
    for i in 0..<numberOfItem() {
      
      text += indices[i] > 9 ? "\(indices[i]) " : " \(indices[i]) "
      
      if (i + 1) % order == 0 {
        print(text)
        text = ""
      }
      
    }
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
