//
//  Position.swift
//  PuzzleProject
//
//  Created by 范祎楠 on 2016/12/7.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import UIKit

struct Position {
  var row: Int
  var col: Int
  
  func equal(toPosition position: Position) -> Bool {
    if self.row == position.row && self.col == position.col {
      return true
    }
    return  false
  }
  
  func getDistance(to position: Position) -> CGFloat {
    
    let vDistance = abs(row - position.row)
    let hDistance = abs(col - position.col)
    
    return sqrt(CGFloat(vDistance) * CGFloat(vDistance) + CGFloat(hDistance) * CGFloat(hDistance))
    
  }
  
  func getManhattanDistance(to position: Position) -> Int {

    let vDistance = abs(row - position.row)
    let hDistance = abs(col - position.col)
    
    return vDistance + hDistance
  }

}
