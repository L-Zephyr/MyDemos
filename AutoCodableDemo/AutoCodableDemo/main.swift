//
//  main.swift
//  AutoCodableDemo
//
//  Created by LZephyr on 2018/4/14.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

let json = """
{
    "my_name": "LZephyr",
    "boy": 1,
    "array": []
}
"""

print("<1> Decoding:\n")
do {
    let model = try JSONDecoder().decode(Person.self, from: json.data(using: .utf8)!)
    print(model)
} catch {
    print(error)
}

print("\n<2> Encoding:\n")
do {
    let person = Person(myName: "LZephyr", boy: true, married: false, array: [], ignored: 2)
    let data = try JSONEncoder().encode(person)
    if let json = String(data: data, encoding: .utf8) {
        print(json)
    }
} catch {
    print(error)
}
