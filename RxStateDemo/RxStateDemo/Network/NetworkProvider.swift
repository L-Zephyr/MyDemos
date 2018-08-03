//
//  NetworkProvider.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/3/14.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Result

enum NetworkError: Error {
    case error
}

// MARK: - NetworkProvider

class NetworkProvider<Target: TargetType>: MoyaProvider<Target> {
    
    // MARK: - Public

    // 返回测试数据
    @discardableResult
    override func request(_ target: Target,
                               callbackQueue: DispatchQueue? = .none,
                               progress: ProgressBlock? = .none,
                               completion: @escaping Completion) -> Cancellable {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            if let callbackQueue = callbackQueue {
                callbackQueue.async {
                    completion(self.testResponse())
                }
            } else {
                DispatchQueue.main.async {
                    completion(self.testResponse())
                }
            }
        }
        return AnyCancellable()
    }
    
    func testResponse() -> Result<Moya.Response, MoyaError> {
        var newsList: [MsgItem] = []
        for index in 0...10 {
            newsList.append(MsgItem(title: "MsgItem Item", index: index))
        }
        
        if let data = try? JSONEncoder().encode(newsList) {
            let response = Moya.Response(statusCode: 200, data: data)
            return Result(value: response)
        } else {
            return Result(error: MoyaError.underlying(NetworkError.error, nil))
        }
    }
}

struct AnyCancellable: Cancellable {
    var isCancelled: Bool = false
    
    init() {
        
    }
    
    func cancel() {
        
    }
}
