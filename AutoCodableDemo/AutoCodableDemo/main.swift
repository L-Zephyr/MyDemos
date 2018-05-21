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

print("\n<3> Enum:\n")
do {
    // case1
    let model1 = ConcreteType.option1("enum codable")
    let data1 = try JSONEncoder().encode(model1)
    print("Encode result: \(String(data: data1, encoding: .utf8) ?? "Error")")
    
    let decoded1 = try JSONDecoder().decode(ConcreteType.self, from: data1)
    print("Decode result: \(decoded1)\n")
    
    // case2
    let model2 = ConcreteType.option2(School(name: "my_school"))
    let data2 = try JSONEncoder().encode(model2)
    print("Encode result: \(String(data: data2, encoding: .utf8) ?? "Error")")
    
    let decoded2 = try JSONDecoder().decode(ConcreteType.self, from: data2)
    print("Decode result: \(decoded2)\n")
    
    // case3
    let model3 = ConcreteType.option3("option3", School(name: "school"), 18)
    let data3 = try JSONEncoder().encode(model3)
    print("Encode result: \(String(data: data3, encoding: .utf8) ?? "Error")")
    
    let decoded3 = try JSONDecoder().decode(ConcreteType.self, from: data3)
    print("Decode result: \(decoded3)\n")
} catch {
    print(error)
}
