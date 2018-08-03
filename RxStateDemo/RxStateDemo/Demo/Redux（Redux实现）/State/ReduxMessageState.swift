//
//  ReduxMessageState.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/4/5.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import ReSwift

enum ViewLoadingStatus {
    case normal
    case loading
}

/*
 Redux所推崇的是统一管理应用的状态，应用有一个根状态对象，各个页面的状态以树的形式组织在一起：
 
               AppState
            /      |    \
           /       |     \
 LoginState   Page1State  ...
 
 每个State都有相应的Reducer，改变状态时必须dispatch一个action，然后通过reducer计算出新的状态
 */

struct ReduxMessageState: ReSwift.StateType {
    var newsList: [MsgItem] = []
    var loadingState: ViewLoadingStatus = .normal
}
