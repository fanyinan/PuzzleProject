//
//  Randomer.swift
//  PuzzleProject
//
//  Created by 范祎楠 on 2016/12/7.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import Foundation

class Randomer {
  
  private var previousPosition: Position = Position(row: -1, col: -1)//记录随机排序时移动之前的位置

  func randomPuzzlePath(with puzzleInfo: PuzzleInfo) -> [SwapPath]{
    
    let puzzleInfo = puzzleInfo.copy() as! PuzzleInfo
    
    let swapNum = puzzleInfo.numberOfItem() * puzzleInfo.numberOfItem()
    var swapCountList = Array<Int>(repeating: 0, count: puzzleInfo.numberOfItem())
    swapCountList[puzzleInfo.puzzleNode.blankIndex] = 1

    var pathList: [SwapPath] = []
    
    for _ in 0..<swapNum {
      
      let blankPosition = puzzleInfo.getPosition(at: puzzleInfo.puzzleNode.blankIndex)
      var adjacentPositions = puzzleInfo.getAdjacentPositions(at: blankPosition)
      
      //获得相邻块中被移动到此为止最少的块的列表，并且不能是刚刚移动过来的位置
      adjacentPositions = adjacentPositions.sorted(by: {swapCountList[puzzleInfo.getIndex(at: $0)] < swapCountList[puzzleInfo.getIndex(at: $1)]})
      
      adjacentPositions = adjacentPositions.filter({!$0.equal(toPosition: previousPosition)})
      
      adjacentPositions = adjacentPositions.filter({swapCountList[puzzleInfo.getIndex(at: adjacentPositions[0])] == swapCountList[puzzleInfo.getIndex(at: $0)]})
      
      let positionToSwap = adjacentPositions[Int(arc4random() % UInt32(adjacentPositions.count))]
      pathList += [puzzleInfo.swap(from: blankPosition, to: positionToSwap)]
      swapCountList[puzzleInfo.getIndex(at: positionToSwap)] += 1
      puzzleInfo.puzzleNode.blankIndex = puzzleInfo.getIndex(at: positionToSwap)
      
      previousPosition = blankPosition
      
    }
    
    makePreviousPositionEmpty()
    pathList += puzzleInfo.getPath(from: puzzleInfo.puzzleNode.blankIndex, to: puzzleInfo.numberOfItem() - 1, with: [])!

    swapCountList.removeAll()
    
    return pathList
  }
  
  
  func makePreviousPositionEmpty() {
    previousPosition = Position(row: -1, col: -1)
  }
}
