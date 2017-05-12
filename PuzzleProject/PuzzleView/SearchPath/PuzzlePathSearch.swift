//
//  PuzzlePathSearch.swift
//  PuzzleProject
//
//  Created by 范祎楠 on 2016/12/8.
//  Copyright © 2016年 范祎楠. All rights reserved.
//

import Foundation

protocol PuzzlePathSearcher {
  
  func search(with startPuzzleNode: PuzzleNode, with targetPuzzleNode: PuzzleNode) -> [SwapPath]
  
}
