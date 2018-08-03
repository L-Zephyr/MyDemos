//
//  Moya+Extension.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/3/20.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import Moya
import RxSwift

extension TargetType {
    var baseURL: URL {
        return URL(string: "https://news.maxjia.com")!
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return nil
    }
}

extension Response {
    func mapJSON(keyPath: String) throws -> Any {
        let json = try self.mapJSON()
        
        if let json = json as? [String: Any], let part = json[keyPath] {
            return part
        }
        throw MoyaError.jsonMapping(self)
    }
}
