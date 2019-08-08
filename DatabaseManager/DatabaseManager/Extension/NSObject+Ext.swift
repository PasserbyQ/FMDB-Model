
//
//  NSObject+Ext.swift
//  DatabaseManager
//
//  Created by yu qin on 2019/8/8.
//  Copyright © 2019 yu qin. All rights reserved.
//

import Foundation

public extension NSObject{
    class var nameOfClass: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    var nameOfClass: String{
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}
