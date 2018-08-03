//
//  ReduxMessageReducer.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/4/5.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import ReSwift

/// Reducer是一个纯函数，接收一个Action和当前的状态，计算下一个状态
/// 纯函数没有外部依赖，也不会产生任何副作用，所以不能在Reducer中进行网络请求和异步任务
func reduxMessageReducer(action: Action, state: ReduxMessageState?) -> ReduxMessageState {
    var state = state ?? ReduxMessageState()
    
    switch action {
    case let setMessage as ActionSetMessage:
        state.newsList = setMessage.news
    case let loading as ActionChangeLoading:
        state.loadingState = loading.loadingState
    case let remove as ActionRemoveMessage:
        state.newsList.remove(at: remove.index)
    default:
        break
    }
    
    return state
}
