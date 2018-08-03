//
//  ViewModel.swift
//  RxDemo
//
//  Created by LZephyr on 2018/3/13.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public protocol StateType { }

// 无状态
public struct NoneState: StateType {
    var none: String = ""
}

public protocol StoreType: class, ReactiveCompatible {
    associatedtype State: StateType
    
    init(state: State) // 使用一个State来初始化
    
    var state: State { get }
    
    var rxState: Observable<State> { get }
}

// Store基类
public class Store<ConcreteState>: StoreType where ConcreteState: StateType {
    public typealias State = ConcreteState
    
    public let disposeBag = DisposeBag()
    
    /// 接受一个State来初始化
    required public init(state: State) {
        self.state = state
        self._state = BehaviorSubject(value: state)
        
        #if DEBUG
            StateChangeRecorder.shared.record(state, on: self)
        #endif
    }
    
    /// 状态变量，一个只读类型的变量
    public private(set) var state: State
    
    /// 状态变量对应的可观察对象，当状态发生改变时`rxState`会发送相应的事件
    public var rxState: Observable<State> {
        return _state.asObservable()
    }
    
    /// 强制更新状态，`rxState`所有的观察者都会收到一个next事件
    public func forceUpdateState() {
        _state.onNext(state)
    }
    
    /// 在一个闭包中更新状态变量，当闭包返回后一次性应用所有的更新，用于更新状态变量
    public func performStateUpdate(_ updater: (inout State) -> Void) {
        updater(&self.state)
        
        #if DEBUG
        StateChangeRecorder.shared.record(state, on: self) // 记录状态的变更
        #endif
        
        forceUpdateState()
    }
    
    private var _state: BehaviorSubject<State>
}
