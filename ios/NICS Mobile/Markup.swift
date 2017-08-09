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

// Causing a crash right now, but leaving the code for future cleanup
@objc class SettingsHelper:NSObject {
    func getInfo(forKey key:String) -> NSString {
        guard
            let path = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
            let keysDictionary = dict["Keys"] as? [String: Any]
            else {
                print("Please add settings bundle in order to use this app")
                return NSString(format: "")
        }
        
        if let desiredKey = keysDictionary[key] as? NSString {
            return desiredKey
        } else {
            print("coulnd't find a string for that key")
            return NSString(format: "")
        }
    }
}
