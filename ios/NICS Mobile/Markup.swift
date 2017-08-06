//
//  Markup.swift
//  SCOUT Mobile
//
//  Created by Andrew Rangel on 7/31/17.
//  Copyright © 2017 MIT Lincoln Labs. All rights reserved.
//

import UIKit

@objc class PolyLineBezierPath:UIBezierPath {
    var startPoint:CGPoint = CGPoint(x: 0, y: 0)
    
    override func move(to point: CGPoint) {
        super.move(to: point)
        startPoint = point
    }
}
