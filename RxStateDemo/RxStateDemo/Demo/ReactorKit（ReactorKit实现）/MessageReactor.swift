//
//  MessageReactor.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/4/5.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import ReactorKit
import RxSwift

class MessageReactor: Reactor {
    /// Action用来表示用户的操作
    enum Action {
        case request
        case removeItem(IndexPath)
    }
    
    /// Mutation用来表示状态变更的操作，Mutation必须是同步的，它的作用仅仅是修改State
    enum Mutation {
        case setMessageSections([MessageTableSectionModel])
        case setLoadingState(ViewLoadingStatus)
        case removeItem(IndexPath)
    }
    
    /// 保存这个页面全部的状态变量
    struct State {
        var msgSections: [MessageTableSectionModel] = []
        var loadingState: ViewLoadingStatus = .normal
    }
    
    let initialState = State()
    let service: MessageServiceType
    
    init(service: MessageServiceType) {
        self.service = service
    }
    
    // MARK: - Mutation
    
    /// 将用户所执行的Action转换成Mutation并应用到当前的状态上，这个方法可以带有副作用，所有与网络请求和异步任务相关的操作都应该放在这里
    func mutate(action: MessageReactor.Action) -> Observable<MessageReactor.Mutation> {
        switch action {
        case .request:
            // 网络请求结束后将得到的数据封装成Mutation并应用到当前的状态之上
            return Observable.merge(.just(Mutation.setLoadingState(.loading)), // 页面状态变为loading
                                    service.request().map { Mutation.setMessageSections($0) })
        case .removeItem(let index):
            return .just(Mutation.removeItem(index))
        }
    }
    
    // MARK: - Reduce
    
    /// 根据当前的状态和mutation计算下一个状态，由于mutation是不带任何副作用的，所有reduce一定要定义成纯函数
    func reduce(state: MessageReactor.State, mutation: MessageReactor.Mutation) -> MessageReactor.State {
        var state = state
        
        switch mutation {
        case .setMessageSections(let list):
            state.msgSections = list
            state.loadingState = .normal // 隐藏加载态
        case .setLoadingState(let loading):
            state.loadingState = loading
        case .removeItem(let index):
            state.msgSections[index.section].items.remove(at: index.row)
        }
        
        return state
    }
    
    // MARK: - Transform
    
    // 用户的操作会经过 Action -> Mutation -> State 的转换过程，这其中的每一步都可以通过transform来自定义，transform方法有三个：

    func transform(action: Observable<MessageReactor.Action>) -> Observable<MessageReactor.Action> {
        return action
    }
    
    func transform(mutation: Observable<MessageReactor.Mutation>) -> Observable<MessageReactor.Mutation> {
        return mutation
    }
    
    func transform(state: Observable<MessageReactor.State>) -> Observable<MessageReactor.State> {
        return state
    }
}
