//
//  NormalPathSearch.swift
//  PuzzleProject
//
//  Created by 范祎楠 on 2016/12/8.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

class NormalPathSearch: PuzzlePathSearcher {
  
  private var puzzleNode: PuzzleNode!
  private weak var puzzleView: PuzzleView!
  private var avoidIndexList: Set<Int> = Set<Int>() {
    didSet{
      print("avoidIndexList \(avoidIndexList.description)")
    }
  }
  private var completionFloor = 0 //当前正在完成的层。自动完成是先完成上方一排和左边一排，逐步向右下方完成，比如开始时一个4x4的，完成第一层之后变为一个3x3
  private var completedIndexList: Set<Int> = Set<Int>() //已完成的块

  func search(with startPuzzleNode: PuzzleNode, with targetPuzzleNode: PuzzleNode) -> [SwapPath] {

    self.puzzleNode = startPuzzleNode.copy()
    
    clearCompletionData()
    completionFloor = -1
    
    var swapPaths: [SwapPath] = []
    completeBlockWith(swapPaths: &swapPaths)
      
    return swapPaths
  }
  
  
  /**
   清空完成拼图所记录的数据
   */
  private func clearCompletionData() {
    
    completionFloor = 0
    completedIndexList.removeAll()
    avoidIndexList.removeAll()
    
  }
  
  /**
   完成给出indexlist的拼图部分
   
   - parameter indexList: 完成拼图的顺序
   */
  private func completeBlockWith(_ indexList: [Int] = [], swapPaths: inout [SwapPath]) {
    
    if indexList.isEmpty {
      
      completionFloor += 1
      let prepareIndexList = getPrepareIndexListWith(completionFloor: completionFloor)
      
      //当prepareIndexList.isEmpty表示没有要归位的块，即拼图完成
      if prepareIndexList.isEmpty {
        return
      }
      
      completeBlockWith(prepareIndexList, swapPaths: &swapPaths)
      
      return
    }
    
    
    let currentSwapPathList = calculateAutoCompletePathWith(indexList[0])
    
    updatePuzzleInfo(with: currentSwapPathList)

    avoidIndexList.insert(indexList[0])
    
    swapPaths += currentSwapPathList
    completeBlockWith(Array(indexList[1..<indexList.count]), swapPaths: &swapPaths)
    
  }
  
  /**
   计算本次需要归位的index
   
   - returns: getPrepareIndexList
   */
  private func getPrepareIndexListWith(completionFloor: Int) -> [Int]{
    
    if puzzleNode.order - 1 <= completionFloor {
      return []
    }
    
    var prepareIndexList: [Int] = []
    
    let  midPosition = Position(row: completionFloor, col: completionFloor)
    
    prepareIndexList += [puzzleNode.getIndex(at: midPosition)]
    
    for i in 1..<puzzleNode.order - completionFloor {
      
      prepareIndexList += [puzzleNode.getIndex(at: Position(row: midPosition.row, col: midPosition.col + i))]
      
    }
    
    for i in 1..<puzzleNode.order - completionFloor {
      
      prepareIndexList += [puzzleNode.getIndex(at: Position(row: midPosition.row + i, col: midPosition.col))]
      
    }
    
    return prepareIndexList
  }
  
  private func calculateAutoCompletePathWith(_ index: Int) -> [SwapPath]{
    
    print("*************************** index \(index)")
    
    //已经在完成的位置上
    if puzzleNode.indices[index] == index {
      return []
    }
    
    puzzleNode.makePreviousPositionEmpty()
    let indexInUI = puzzleNode.indices.index(of: index)!
    
    let path = getPathForMoveWith(fromIndex: indexInUI, toIndex: index)
    
    guard path.isEmpty else{
      return path
    }
    
    if puzzleNode.getPosition(at: index).col == puzzleNode.order - 1 {
      
      var swapPathList: [SwapPath] = []
      let beforeIndex = index + puzzleNode.order
      swapPathList += getPathForMoveWith(fromIndex: indexInUI, toIndex: beforeIndex)
      avoidIndexList.insert(beforeIndex)
      swapPathList += getBlankPathWith(toIndex: puzzleNode.order * (completionFloor + 1) + completionFloor, avoidIndexList: avoidIndexList)!
      
      swapPathList += getPathForMoveWith(serialItemIndices: [Int](completionFloor..<puzzleNode.order).map({$0 + completionFloor * puzzleNode.order}) + [beforeIndex])
      
      swapPathList += getPathForMoveWith(serialItemIndices: [beforeIndex - 1, beforeIndex - puzzleNode.order - 1])
      
      swapPathList += getPathForMoveWith(serialItemIndices: ([Int](0..<puzzleNode.order - 1 - completionFloor).map({$0 + completionFloor * puzzleNode.order + completionFloor})).reversed())
      swapPathList += getPathForMoveWith(serialItemIndices: ([puzzleNode.order + completionFloor * puzzleNode.order + completionFloor]))
      
      avoidIndexList.remove(beforeIndex)
      
      return swapPathList
      
    } else if index == puzzleNode.order * (puzzleNode.order - 1) + completionFloor {
      
      var swapPathList: [SwapPath] = []
      let beforeIndex = index + 1
      swapPathList += getPathForMoveWith(fromIndex: indexInUI, toIndex: beforeIndex)
      avoidIndexList.insert(beforeIndex)
      swapPathList += getBlankPathWith(toIndex: puzzleNode.order * (completionFloor + 2) - 1, avoidIndexList: avoidIndexList)!
      
      swapPathList += getPathForMoveWith(serialItemIndices: [Int](completionFloor..<puzzleNode.order).map({$0 + completionFloor * puzzleNode.order}).reversed())
      swapPathList += getPathForMoveWith(serialItemIndices: [Int]((completionFloor + 1)..<puzzleNode.order).map({$0 * puzzleNode.order + completionFloor}))
      
      swapPathList += getPathForMoveWith(serialItemIndices: [beforeIndex])
      
      swapPathList += getPathForMoveWith(serialItemIndices: [beforeIndex - puzzleNode.order, beforeIndex - puzzleNode.order - 1])
      
      swapPathList += getPathForMoveWith(serialItemIndices: [Int]((completionFloor)..<puzzleNode.order - 2).map({$0 * puzzleNode.order + completionFloor}).reversed())
      swapPathList += getPathForMoveWith(serialItemIndices: [Int](completionFloor + 1..<puzzleNode.order).map({$0 + completionFloor * puzzleNode.order}))
      swapPathList += getPathForMoveWith(serialItemIndices: [puzzleNode.order * (completionFloor + 2) - 1])
      
      avoidIndexList.remove(beforeIndex)
      
      return swapPathList
      
    } else {
      
      return []
      
    }
    
  }
  
  /**
   获取任意一个非空白块移动的路径
   
   - parameter fromIndex: 起始index
   - parameter toIndex:   结束index
   
   - returns: 路径
   */
  private func getPathForMoveWith(fromIndex: Int, toIndex: Int) -> [SwapPath] {
    
    var swapPathList: [SwapPath] = []
    
    //把目标块移动到需要移动到的位置，但是无法移动，需要先移动空块
    let targetPathList = puzzleNode.getPath(from: fromIndex, to: toIndex, with: avoidIndexList)!
    
    let saveBlankIndex = puzzleNode.blankIndex
    
    for path in targetPathList {
      //把空块移动到targetPathList的路径上，以便目标块移动
      print("tagetblockpath \(path)")
      
      var currentAvoidIndexList = avoidIndexList
      currentAvoidIndexList.insert(path.fromIndex)
      
      guard isHavePath(path.toIndex, avoidIndexList: currentAvoidIndexList) else {
        puzzleNode.blankIndex = saveBlankIndex
        return []
      }
      
      let moveBlankPath = getBlankPathWith(toIndex: path.toIndex, avoidIndexList: currentAvoidIndexList)
      
      swapPathList += moveBlankPath!
      swapPathList += [SwapPath(fromIndex: path.toIndex, toIndex: path.fromIndex)]
      puzzleNode.blankIndex = path.fromIndex
      
    }
    
    return swapPathList
    
  }
  
  /**
   移动一系列连续的块，自动和空白块交换
   
   - parameter serialItemIndices: 块的index
   
   - returns: 移动路径
   */
  private func getPathForMoveWith(serialItemIndices: [Int]) -> [SwapPath] {
    
    var swapPathList: [SwapPath] = []
    
    for index in serialItemIndices {
      
      swapPathList += [SwapPath(fromIndex: index, toIndex: puzzleNode.blankIndex)]
      
      puzzleNode.blankIndex = index
    }
    
    return swapPathList
  }

  func getBlankPathWith(toIndex: Int, avoidIndexList: Set<Int>) -> [SwapPath]? {
    
    let fromIndex = puzzleNode.blankIndex
    puzzleNode.makePreviousPositionEmpty()
    
    let path = puzzleNode.getPath(from: fromIndex, to: toIndex, with: avoidIndexList)
    puzzleNode.blankIndex = toIndex
    
    return path
    
  }

  /**
   判断目的块是否被不能移动的块包围住
   
   - parameter toIndex:        目的块
   - parameter avoidIndexList: 不能移动的块
   
   - returns: 是否可达目的块
   */
  private func isHavePath(_ toIndex: Int, avoidIndexList: Set<Int>) -> Bool {
    
    let adjacentPositions = puzzleNode.getAdjacentPositions(at: puzzleNode.getPosition(at: toIndex))
    
    if puzzleNode.blankIndex == toIndex {
      return true
    }
    
    for position in adjacentPositions {
      if !avoidIndexList.contains(puzzleNode.getIndex(at: position)) {
        
        return true
      }
    }
    
    return false
  }
  
  private func updatePuzzleInfo(with swapPaths: [SwapPath]) {
    
    for swapPath in swapPaths {
      
      (puzzleNode.indices[swapPath.fromIndex], puzzleNode.indices[swapPath.toIndex]) = (puzzleNode.indices[swapPath.toIndex], puzzleNode.indices[swapPath.fromIndex])

    }
    
    puzzleNode.blankIndex = puzzleNode.indices.index(of: puzzleNode.blankNumber)!
  }
  
  /**
   分步完成拼图
   */
//  func autoCompleteOneStep() {
//    
//    var targetIndex = 0
//    
//    let prepareIndexList = getPrepareIndexListWith(completionFloor: completionFloor)
//    
//    //已经完成的直接跳过
//    
//    for (i, indexOfPuzzle) in prepareIndexList.enumerated() {
//      
//      if indexOfPuzzle != puzzleNode.indices.index(of: indexOfPuzzle) {
//        targetIndex = indexOfPuzzle
//        break
//      }
//      
//      completedIndexList.insert(indexOfPuzzle)
//      
//      if i == prepareIndexList.count - 1 {
//        
//        completionFloor += 1
//        return
//        
//      }
//      
//    }
//    
//    avoidIndexList = completedIndexList
//    
//    //start to calculatePath
//    let swapPathList = calculateAutoCompletePathWith(targetIndex)
//    
//    puzzleView?.moveItem(withSwapPathList: swapPathList, durationPerStep: 0.5)
//    
//    completedIndexList.insert(targetIndex)
//    
//    for (i, indexOfPuzzle) in prepareIndexList.enumerated() {
//      
//      if !completedIndexList.contains(indexOfPuzzle) {
//        
//        break
//        
//      }
//      
//      if i == prepareIndexList.count - 1 {
//        
//        completionFloor += 1
//        
//        if puzzleNode.order - 1 <= completionFloor {
//          
//          clearCompletionData()
//          
//        }
//      }
//    }
//  }
}
