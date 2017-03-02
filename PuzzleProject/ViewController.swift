//
//  ViewController.swift
//  PuzzleProject
//
//  Created by 范祎楠 on 15/10/20.
//  Copyright © 2015年 范祎楠. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  var puzzleView: PuzzleView!
  var randomButton: UIButton!
  var resetButton: UIButton!
  var autoCompleteButton: UIButton!

  var slider: UISlider!
  var currentColumn: Int = 3
  
  var priorityQueue: PriorityQueue<Int>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initView()
    
    priorityQueue = PriorityQueue(compare: { (a, b) -> ComparisonResult in
      
      if a == b {
        return .orderedSame
      }
      
      return a < b ? .orderedAscending : .orderedDescending
      
    })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func initView() {
 
    navigationController?.isNavigationBarHidden = true
    initPuzzle()
    
    randomButton = UIButton(frame: CGRect(x: 10, y: 50, width: 80, height: 30))
    randomButton.backgroundColor = UIColor.red
    randomButton.setTitle("random", for: UIControlState())
    randomButton.addTarget(self, action: #selector(ViewController.randomPuzzle), for: .touchUpInside)
    view.addSubview(randomButton)
    
    resetButton = UIButton(frame: CGRect(x: 100, y: 50, width: 80, height: 30))
    resetButton.backgroundColor = UIColor.orange
    resetButton.setTitle("reset", for: UIControlState())
    resetButton.addTarget(self, action: #selector(ViewController.reset), for: .touchUpInside)
    view.addSubview(resetButton)
    
    autoCompleteButton = UIButton(frame: CGRect(x: 190, y: 50, width: 80, height: 30))
    autoCompleteButton.backgroundColor = UIColor.orange
    autoCompleteButton.setTitle("complete", for: UIControlState())
    autoCompleteButton.addTarget(self, action: #selector(ViewController.autoComplete), for: .touchUpInside)
    view.addSubview(autoCompleteButton)
    
    slider = UISlider(frame: CGRect(x: 10, y: 500, width: view.frame.width - 20, height: 10))
    slider.addTarget(self, action: #selector(ViewController.changeColumn(_:)), for: .valueChanged)
    slider.value = Float(currentColumn) / 10
    view.addSubview(slider)
    
    
  }
  
  func randomPuzzle() {
    puzzleView.startRandom()
    
    //100, 10, 90, 9, 8, 89, 88, 7, 6, 5, 4
//    priorityQueue.enQueue(element: 100)
//    priorityQueue.enQueue(element: 10)
//    priorityQueue.enQueue(element: 90)
//    priorityQueue.enQueue(element: 9)
//    priorityQueue.enQueue(element: 8)
//    priorityQueue.enQueue(element: 89)
//    priorityQueue.enQueue(element: 88)
//    priorityQueue.enQueue(element: 7)
//    priorityQueue.enQueue(element: 6)
//    priorityQueue.enQueue(element: 5)
//    priorityQueue.enQueue(element: 4)
//    priorityQueue.enQueue(element: 87)
//    priorityQueue.enQueue(element: 86)
//    priorityQueue.enQueue(element: 85)
//    priorityQueue.enQueue(element: 84)
//    
//    priorityQueue.deQueue()
//    priorityQueue.deQueue()
//    priorityQueue.deQueue()
//    priorityQueue.deQueue()
//    priorityQueue.deQueue()
//    priorityQueue.deQueue()
//    priorityQueue.deQueue()
//    priorityQueue.deQueue()
//    priorityQueue.deQueue()

  }
  
  func reset() {
    puzzleView.removeFromSuperview()
    initPuzzle()

  }
  
  func autoComplete() {
//    puzzleView.autoCompleteOneStep()
    puzzleView.autoCompleteAll()

  }
  
  func initPuzzle() {
    if puzzleView != nil {
      puzzleView.removeFromSuperview()
    }
    puzzleView = PuzzleView(frame: CGRect(x: 10, y: 100, width: view.frame.width - 20, height: view.frame.width - 20), puzzleColumn: 5, image: UIImage(named: "image0")!, puzzleIndexList: [4,7,13,2,8,5,16,6,1,3,14,0,24,11,9,22,19,15,12,18,20,17,10,21,23])

    puzzleView.test = true
    view.addSubview(puzzleView)
  }
  
  func changeColumn(_ sender: UISlider) {
    let value = Int(sender.value / 0.1)
    
    if value != currentColumn && value > 1{
      
      currentColumn = value

      puzzleView.removeFromSuperview()
      initPuzzle()
      view.addSubview(puzzleView)
      
    }
  }
}

