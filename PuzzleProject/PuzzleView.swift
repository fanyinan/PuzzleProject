//
//  PuzzleView.swift
//  PuzzleProject
//
//  Created by 范祎楠 on 15/10/20.
//  Copyright © 2015年 范祎楠. All rights reserved.
//

import UIKit

@objc protocol PuzzleViewDelegate: NSObjectProtocol {
  @objc optional func randomDidFinish(_ puzzleView: PuzzleView)
  @objc optional func puzzleView(_ puzzleView: PuzzleView, didMoveWithPuzzleIndexList: [Int])
}

class PuzzleView: UIView {
  
  enum MoveDirect {
    case hor
    case ver
  }
  
  //下面两个属性是对应的
  /******************************************************************************
  *  保存基本信息
  ******************************************************************************/
  private var puzzleItemList: [UIImageView] = [] //imageviews，顺序为初始时的顺序，且始终为初始顺序，不会因UI上位置的改变而改变
  
  private var originImage: UIImage? //原始图片
  private var puzzleItemWidth:CGFloat = 0 //拼图块的宽度
  private var isAutoMoving = false//标识是否正在自动移动，（随机和完成）
  private(set) var puzzleNode: PuzzleNode
  private var randomer = Randomer()
  private var normalPathSearch = NormalPathSearch()
  private var search = AStarSearcher()
  private var path: [PuzzleNode] = []
  /******************************************************************************
  *  滑动块相关成员变量
  ******************************************************************************/
  
  private var canMove = false //标识点击当前块是否可被移动
  private var moveDirect: MoveDirect! //移动的方向
  private var tapItem: UIImageView! //被移动的块
  private var tapIndex: Int! //被点击的块在图上的index
  private var blankItem: UIImageView! //空白块
  private var minBorder: CGFloat = 0 //水平方向移动则为x值， 垂直方向移动则为y值
  private var maxBorder: CGFloat = 0 //同上
  private var beginTouchOrigin: CGPoint! //开始点击的点的位置
  private var moveItems: [UIImageView] = [] //需要移动的块
  private var tapItemBeginFrame: CGRect! //被点击块移动前的frame
  private var itemBeginFrameList: [CGRect] = [] //所有需要移动的块移动前的frame
  private var moveItemFromIndexList: [Int] = [] //所有需要移动的块移动前在图上的index
  private var moveItemToIndexList: [Int] = [] //所有需要移动的块移动后在图上的index
  
  /******************************************************************************
  *  可配置成员变量
  ******************************************************************************/
  
  private var swapNum = 10 //随机移动次数
  private var minSpace: CGFloat = 3 //间距
  private var canRandom = false //传入初始序列时不允许随机
  
  weak var delegate: PuzzleViewDelegate?
  
  var test = false //测试用
  var successBlock: (([Int]) -> ())?
  var movenable = true { //是否允许移动块
    didSet{
      isUserInteractionEnabled = movenable
    }
  }
  
  init(frame: CGRect, puzzleColumn: Int, image: UIImage?, puzzleIndexList: [Int]? = nil, successBlock: (([Int]) -> ())? = nil) {
    
    puzzleNode = PuzzleNode(indices: puzzleIndexList ?? [Int](0..<puzzleColumn * puzzleColumn), blankNumber: puzzleColumn * puzzleColumn - 1, order: puzzleColumn)
    
    self.originImage = image
    self.successBlock = successBlock
    
    canRandom = puzzleIndexList == nil
    
    super.init(frame: frame)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    
    layoutPuzzle()
    puzzleItemList[puzzleNode.blankNumber].isHidden = true
    
  }
  
  /******************************************************************************
   *   About UI method
   ******************************************************************************/
   //MARK: - About UI method
  
  private func layoutPuzzle() {
    
    if originImage == nil {
      return
    }
    
    let images = cutImageToPuzzle(originImage!)
    
    for i in 0..<puzzleNode.numberOfItem() {
      
      //背景
      let bgImageView = UIImageView(frame: getPuzzleFrame(withIndex: i))
      bgImageView.contentMode = .scaleAspectFill
      bgImageView.image = images[i]
      bgImageView.alpha = 0.2
      addSubview(bgImageView)
    }
    
    for i in 0..<puzzleNode.numberOfItem() {
      
      //拼图
      let index = puzzleNode.indices.index(of: i)! //real index
      let puzzleItem = UIImageView(frame: getPuzzleFrame(withIndex: index))
      puzzleItem.contentMode = .scaleAspectFill
      addSubview(puzzleItem)
      
      //若为测试则显示数字，方便调试
      if test {
        
        puzzleItem.backgroundColor = UIColor.randomColor()
        
        let label = UILabel(frame: puzzleItem.bounds)
        label.text = "\(i)"
        label.textAlignment = .center
        puzzleItem.addSubview(label)
        
      } else {
        
        puzzleItem.image = images[i]
        
      }
      
      puzzleItemList += [puzzleItem]
    }
  }
  
  /**
   裁剪图片
   
   - parameter image: 原图
   
   - returns: 九宫格图片
   */
  private func cutImageToPuzzle(_ image: UIImage) -> [UIImage] {
    
    //旋转图片，如果图片的Orientation不是Up的话，图片会是旋转了的图片
    let fixOrientationImage = fixOrientation(image)
    
    //裁剪成正方形
    let fixOrientationImageRef = fixOrientationImage.cgImage
    let imageWidthMin = min(fixOrientationImage.size.width, fixOrientationImage.size.height)
    let imageWidthMax = max(fixOrientationImage.size.width, fixOrientationImage.size.height)
    let cutDownLength = (imageWidthMax - imageWidthMin) / 2
    let x = fixOrientationImage.size.width > fixOrientationImage.size.height ? cutDownLength : 0
    let y = fixOrientationImage.size.height > fixOrientationImage.size.width ? cutDownLength : 0
    
    let imageRef = fixOrientationImageRef!.cropping(to: CGRect(x: y, y: x, width: imageWidthMin, height: imageWidthMin))
    let imageSqure = UIImage(cgImage: imageRef!)
    
    //分割图片
    let imageItemRef = imageSqure.cgImage
    
    var puzzleItem: [UIImage] = []
    for i in 0..<puzzleNode.numberOfItem() {
      let frameToCut = getPuzzleFrame(withIndex: i, withOriginWith: imageSqure.size.width)
      let imageRef = imageItemRef!.cropping(to: frameToCut)
      let imageItem = UIImage(cgImage: imageRef!)
      
      puzzleItem += [imageItem]
    }
    
    return puzzleItem
  }
  
  /**
   旋转图片
   
   - parameter image: 原图
   
   - returns: 旋转后的图片
   */
  func fixOrientation(_ image: UIImage) -> UIImage {
    
    //    if image.imageOrientation == UIImageOrientation.Up {
    //      return image
    //    }
    var transform = CGAffineTransform.identity
    typealias o = UIImageOrientation
    let width = image.size.width
    let height = image.size.height
    
    switch (image.imageOrientation) {
    case o.down, o.downMirrored:
      transform = transform.translatedBy(x: width, y: height)
      transform = transform.rotated(by: CGFloat(M_PI))
    case o.left, o.leftMirrored:
      transform = transform.translatedBy(x: width, y: 0)
      transform = transform.rotated(by: CGFloat(M_PI_2))
    case o.right, o.rightMirrored:
      transform = transform.translatedBy(x: 0, y: height)
      transform = transform.rotated(by: CGFloat(-M_PI_2))
    default: // o.Up, o.UpMirrored:
      break
    }
    
    switch (image.imageOrientation) {
    case o.upMirrored, o.downMirrored:
      transform = transform.translatedBy(x: width, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    case o.leftMirrored, o.rightMirrored:
      transform = transform.translatedBy(x: height, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    default: // o.Up, o.Down, o.Left, o.Right
      break
    }
    let cgimage = image.cgImage
    
    let ctx = CGContext(data: nil, width: Int(width), height: Int(height),
      bitsPerComponent: cgimage!.bitsPerComponent, bytesPerRow: 0,
      space: cgimage!.colorSpace!,
      bitmapInfo: cgimage!.bitmapInfo.rawValue)
    
    ctx!.concatenate(transform)
    
    switch (image.imageOrientation) {
    case o.left, o.leftMirrored, o.right, o.rightMirrored:
      ctx!.draw(cgimage!, in: CGRect(x: 0, y: 0, width: height, height: width))
    default:
      ctx!.draw(cgimage!, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    let cgimg = ctx!.makeImage()
    let img = UIImage(cgImage: cgimg!, scale: 1, orientation: .left)
    return img
    
  }
  
  /**
   获取index块在图上的的frame
   
   - parameter index:      图上index
   - parameter originWith: 总宽度
   
   - returns: frame
   */
  private func getPuzzleFrame(withIndex index: Int, withOriginWith originWith: CGFloat? = nil) -> CGRect{
    
    let width = originWith ?? frame.width
    puzzleItemWidth = (width - CGFloat(puzzleNode.order - 1) * minSpace) / CGFloat(puzzleNode.order)
    let x =  (puzzleItemWidth + minSpace) * CGFloat(index % puzzleNode.order)
    let row = index / puzzleNode.order
    let y = (puzzleItemWidth + minSpace) * CGFloat(row)
    
    return CGRect(x: x, y: y, width: puzzleItemWidth, height: puzzleItemWidth)
  }
  
  /**
   移动一堆块
   
   - parameter targetIndex: 当前位置序号
   - parameter toIndex:     结束位置序号
   */
  private func move(_ duration: TimeInterval, targetIndexList: [Int], toIndexList: [Int], finishCompletion: (()->())? = nil) {
    UIView.animate(withDuration: duration, animations: { () -> Void in
      
      //修改ui
      for index in 0..<targetIndexList.count {
        
        self.puzzleItemList[self.puzzleNode.indices[targetIndexList[index]]].frame = self.getPuzzleFrame(withIndex: toIndexList[index])
        
      }
      
      //两个数组元素相同
      if targetIndexList[0] == toIndexList[0] {
        return
      }
      
      let newBlankPostionIndex = targetIndexList.filter({!toIndexList.contains($0)})[0]
      let oldBlankPostionIndex = toIndexList.filter({!targetIndexList.contains($0)})[0]
      
      self.puzzleItemList[self.puzzleNode.indices[oldBlankPostionIndex]].frame = self.getPuzzleFrame(withIndex: newBlankPostionIndex)
      
      //修改puzzleIndexList
      
      let tmp = self.puzzleNode.indices[oldBlankPostionIndex]
      
      if let tapIndex = self.tapIndex, tapIndex < self.puzzleNode.blankIndex {
        
        for index in (0..<targetIndexList.count).reversed() {
          
          self.puzzleNode.indices[toIndexList[index]] = self.puzzleNode.indices[targetIndexList[index]]
          
        }
      } else {
        
        for index in 0..<targetIndexList.count {
          
          self.puzzleNode.indices[toIndexList[index]] = self.puzzleNode.indices[targetIndexList[index]]
          
        }
      }
      
      self.puzzleNode.indices[newBlankPostionIndex] = tmp
      
      self.puzzleNode.blankIndex = self.puzzleNode.indices.index(of: self.puzzleNode.blankNumber)!
      
      }, completion: { (finish) -> Void in
        
        finishCompletion?()
    }) 
  }
  
  /**
   自动移动
   
   - parameter pathList: 移动路径
   */
  private func moveItem(withSwapPathList pathList: [SwapPath], durationPerStep: TimeInterval = 0.05, completionHandle: (()->Void)? = nil) {
    
    if pathList.isEmpty {
      isAutoMoving = false
      delegate?.randomDidFinish?(self)
      completionHandle?()
      return
    }
    
    func moveCompletion() {
      moveItem(withSwapPathList: Array(pathList[1..<pathList.count]), durationPerStep: durationPerStep, completionHandle: completionHandle)
    }
    
    if pathList[0].toIndex != puzzleNode.blankIndex && pathList[0].fromIndex != puzzleNode.blankIndex {
      
      print("\(pathList[0]) have no blankIndex \(puzzleNode.blankIndex)")
      assert(false)
      return
    }
    
    move(durationPerStep, targetIndexList: [pathList[0].toIndex], toIndexList: [pathList[0].fromIndex], finishCompletion: moveCompletion)
    
  }
  
  /**
   获取坐标所在的块的index
   
   - parameter point: 坐标点
   
   - returns: index
   */
  private func getIndex(withPoint point: CGPoint) -> Int{
    
    var row = Int(point.y / puzzleItemWidth)
    var col = Int(point.x / puzzleItemWidth)
    
    row = min(puzzleNode.order - 1, max(0, row))
    col = min(puzzleNode.order - 1, max(0, col))
    
    let index = puzzleNode.getIndex(at: Position(row: row, col: col))
    
    return index
  }
  
  /**
   随机排序
   */
  func startRandom() {
    
    if !canRandom {
      return
    }
    
    if isAutoMoving {
      return
    }
    
    isAutoMoving = true
    
    let swapPathList = randomer.randomPuzzlePath(with: puzzleNode)
    //把空白块移动到右下脚
    
    moveItem(withSwapPathList: swapPathList)
    
  }
  
  /******************************************************************************
   *  auto completion method
   ******************************************************************************/
   //MARK: - auto completion method
  
  
  /**
   直接完成全部拼图
   */
  func autoCompleteAll() {
    
    guard !isAutoMoving else {
      return
    }
    
    isAutoMoving = true
    
    let startTime = CACurrentMediaTime()
    let path = search.search(with: puzzleNode, with: PuzzleNode(indices: [Int](0..<puzzleNode.order * puzzleNode.order), blankNumber: puzzleNode.order * puzzleNode.order - 1, order: puzzleNode.order))
//
    print("A*--------------------------\(CACurrentMediaTime() - startTime)--------------------------")
    print("--------------------------path count: \(path.count)--------------------------")

    
    let startTime2 = CACurrentMediaTime()

    let path2 = normalPathSearch.search(with: puzzleNode, with: PuzzleNode(indices: [Int](0..<puzzleNode.order * puzzleNode.order), blankNumber: puzzleNode.order * puzzleNode.order - 1, order: puzzleNode.order))

    print("normal--------------------------\((CACurrentMediaTime() - startTime2))--------------------------")
    print("--------------------------path count: \(path2.count)--------------------------")

    moveItem(withSwapPathList: path2, durationPerStep: 0.1)

  }
  
  /******************************************************************************
   *  manual move method
   ******************************************************************************/
   //MARK: - manual move method
   
   /**
   得到可以被移动的块
   */
  private func getMoveItem(){
    
    let tapPosition = puzzleNode.getPosition(at: tapIndex)
    let blankPosition = puzzleNode.getPosition(at: puzzleNode.blankIndex)
    
    moveItemFromIndexList = []
    
    if tapPosition.row == blankPosition.row {
      if tapPosition.col < blankPosition.col {
        moveItemFromIndexList = [Int](tapIndex..<puzzleNode.blankIndex)
        moveItemToIndexList = moveItemFromIndexList.map({$0 + 1})
      }
      
      if tapPosition.col > blankPosition.col {
        moveItemFromIndexList = [Int](puzzleNode.blankIndex + 1...tapIndex)
        moveItemToIndexList = moveItemFromIndexList.map({$0 - 1})
        
      }
    }
    
    if tapPosition.col == blankPosition.col {
      if tapPosition.row < blankPosition.row {
        for i in 0..<blankPosition.row - tapPosition.row {
          moveItemFromIndexList += [(tapIndex + i * puzzleNode.order)]
          moveItemToIndexList = moveItemFromIndexList.map({$0 + puzzleNode.order})
          
        }
      }
      
      if tapPosition.row > blankPosition.row {
        for i in 0..<tapPosition.row - blankPosition.row {
          moveItemFromIndexList += [(puzzleNode.blankIndex + (i + 1) * puzzleNode.order)]
          moveItemToIndexList = moveItemFromIndexList.map({$0 - puzzleNode.order})
          
        }
      }
    }
    
    moveItems = moveItemFromIndexList.map({puzzleItemList[puzzleNode.indices[$0]]})
    itemBeginFrameList = moveItems.map({$0.frame})
  }
  
  /**
   判断是否可移动、移动方向、获取需要移动的块
   */
  private func getMoveProperty() {
    
    getMoveItem()
    canMove = !moveItems.isEmpty
    
    if canMove {
      //计算被点击块可以移动的范围
      if puzzleNode.getPosition(at: tapIndex).col == puzzleNode.getPosition(at: puzzleNode.blankIndex).col {
        moveDirect = .ver
        
        minBorder = tapIndex > puzzleNode.blankIndex ? tapItem.frame.minY - tapItem.frame.width - minSpace: tapItem.frame.minY
        maxBorder = tapIndex > puzzleNode.blankIndex ? tapItem.frame.maxY - tapItem.frame.width : tapItem.frame.maxY + minSpace
        
      }
      
      if puzzleNode.getPosition(at: tapIndex).row == puzzleNode.getPosition(at: puzzleNode.blankIndex).row {
        moveDirect = .hor
        
        minBorder = tapIndex > puzzleNode.blankIndex ? tapItem.frame.minX - tapItem.frame.width  - minSpace: tapItem.frame.minX
        maxBorder = tapIndex > puzzleNode.blankIndex ? tapItem.frame.maxX - tapItem.frame.width : tapItem.frame.maxX + minSpace
        
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    if let _touch = touches.first {
      
      //记录点击时的坐标
      beginTouchOrigin = _touch.location(in: self)
      //当前点击的在位置上的序号
      tapIndex = getIndex(withPoint: beginTouchOrigin)
      
      if tapIndex == puzzleNode.blankIndex {
        return
      }
      //当前点击的Item
      tapItem = puzzleItemList[puzzleNode.indices[tapIndex]]
      blankItem = puzzleItemList[puzzleNode.indices[puzzleNode.blankIndex]]
      //记录点击item的初始位置，不然之后会改变
      tapItemBeginFrame = tapItem.frame
      //获取移动item所需属性
      getMoveProperty()
      
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    if !canMove {
      return
    }
    //通过计算被点击的块移动的距离来改变所有需要移动的块的位置
    if let _touch = touches.first {
      let point = _touch.location(in: self)
      
      if moveDirect == .hor {
        var endX = tapItemBeginFrame.minX + (point.x - beginTouchOrigin.x)
        endX = endX < minBorder ? minBorder : endX
        endX = endX > maxBorder ? maxBorder : endX
        
        let changeX = endX - tapItemBeginFrame.minX
        
        for (index, item) in moveItems.enumerated() {
          item.frame.origin = CGPoint(x: itemBeginFrameList[index].minX + changeX, y: tapItem.frame.origin.y)
          
        }
      }
      
      if moveDirect == .ver {
        var endY = tapItemBeginFrame.minY + (point.y - beginTouchOrigin.y)
        endY = endY < minBorder ? minBorder : endY
        endY = endY > maxBorder ? maxBorder : endY
        
        let changeY = endY - tapItemBeginFrame.minY
        
        for (index, item) in moveItems.enumerated() {
          item.frame.origin = CGPoint(x: tapItem.frame.origin.x, y: itemBeginFrameList[index].minY + changeY)
          
        }
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    if !canMove {
      return
    }
    
    var isMoved = false
    
    //判断items的位置是否被移动过
    isMoved = ((moveDirect == .hor && ((tapItem.center.x < maxBorder) == (tapIndex > puzzleNode.blankIndex))) || (moveDirect == .ver && ((tapItem.center.y < maxBorder) == (tapIndex > puzzleNode.blankIndex))))
    
    move(0.1, targetIndexList: moveItemFromIndexList, toIndexList: isMoved == true ? moveItemToIndexList : moveItemFromIndexList) { () -> () in
      
      self.puzzleNode.printList()
      self.canMove = false
      
      self.delegate?.puzzleView?(self, didMoveWithPuzzleIndexList: self.puzzleNode.indices)
      
      if self.puzzleNode.indices == [Int](0..<9) {
        self.successBlock?(self.puzzleNode.indices)
      }
    }
  }
}
