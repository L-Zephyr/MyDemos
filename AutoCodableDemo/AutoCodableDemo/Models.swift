//
//  Model.swift
//  AutoCodableDemo
//
//  Created by LZephyr on 2018/4/14.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

protocol AutoCodable: Codable { }

struct Person: AutoCodable {
    // sourcery: key = "my_name"
    var myName: String
    
    var boy: Bool
    
    // sourcery: default = false
    var married: Bool
    
    // sourcery: default = []
    var array: [School]
    
    // sourcery: skip
    var ignored: Int = 2
}

struct School: AutoCodable {
    var name: String
}
