//
//  ReduxMessageActions.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/4/5.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import ReSwift

/// 由于Reducer是纯函数，所以无法直接处理像网络请求这样带有副作用的操作，ReSwift建议采用ActionCreator来做网络请求
func reduxMessageRequest(state: ReduxMessageState, store: ReSwift.Store<ReduxMessageState>) -> Action? {
    MessageProvider.request(.news) { (result) in
        switch result {
        case .success(let response):
            if let list = try? response.map([MsgItem].self) {
                messageStore.dispatch(ActionSetMessage(news: list))
                messageStore.dispatch(ActionChangeLoading(loadingState: .normal))
            }
        case .failure(_):
            break
        }
    }
    
    // 可以返回一个Action同时做一些操作，比如播放加载动画
    return ActionChangeLoading(loadingState: .loading)
}

/// 设置数据的Action
struct ActionSetMessage: Action {
    var news: [MsgItem] = []
}

/// 移除数据的Action
struct ActionRemoveMessage: Action {
    var index: Int
}

/// 改变视图的加载状态
struct ActionChangeLoading: Action {
    var loadingState: ViewLoadingStatus
}
