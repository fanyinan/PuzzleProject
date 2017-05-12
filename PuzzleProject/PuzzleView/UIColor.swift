//
//  MuColor.swift
//  MuMu
//
//  Created by 范祎楠 on 15/4/9.
//  Copyright (c) 2015年 范祎楠. All rights reserved.
//

import UIKit

extension UIColor {
  
  /**
  随机颜色
  
  - returns: 颜色
  */
  class func randomColor() -> UIColor{
    
    let hue = CGFloat(arc4random() % 256) / 256.0
    let saturation = CGFloat(arc4random() % 128) / 256.0 + 0.5
    let brightness : CGFloat = CGFloat(arc4random() % 128) / 256.0 + 0.5
    
    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
  }
  
}
