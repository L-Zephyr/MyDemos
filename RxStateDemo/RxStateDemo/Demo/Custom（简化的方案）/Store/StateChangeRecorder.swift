//
//  StateChangeRecorder.swift
//  RxDemo
//
//  Created by LZephyr on 2018/4/8.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation

class StateChangeRecorder {
    
    // MARK: - Public
    
    static let shared = StateChangeRecorder()
    
    /// 开启/关闭Recorder
    var enableInDebug: Bool = false
    
    /// 记录一个状态值的变更
    func record(_ state: Any, on viewModel: Any) {
        if !enableInDebug {
            return
        }
        
        objc_sync_enter(self)
        
        let stateMirror = Mirror(reflecting: state)
        let vmMirror = Mirror(reflecting: viewModel)
        
        let vmType = String(describing: vmMirror.subjectType)
        let stateType = String(describing: stateMirror.subjectType)
        
        //
        if let oldValue = states[vmType] {
            let changes = differents(new: state, old: oldValue)
            for change in changes {
                if change.value.count <= 100 {
                    print("ℹ️ [\(stateType)] in [\(vmType)] change property [\(change.name)] to '\(change.value)'")
                } else {
                    let s = change.value
                    print("ℹ️ [\(stateType)] in [\(vmType)] change property [\(change.name)] to '\(change.value[...s.index(s.startIndex, offsetBy: 100)])...'")
                }
            }
        }
        states[vmType] = state
        objc_sync_exit(self)
    }
    
    fileprivate init() { }
    
    fileprivate var states: [String: Any] = [:] // 保存所有状态值
}

fileprivate extension StateChangeRecorder {
    /// 传入新老状态值，计算出发生改变的部分
    func differents(new newState: Any, old oldState: Any) -> [(name: String, value: String)] {
        let newPairs = Mirror(reflecting: newState).pairs
        let oldPairs = Mirror(reflecting: oldState).pairs
        
        var diffs = [(name: String, value: String)]()
        
        for (key, oldValue) in oldPairs {
            if let newValue = newPairs[key] {
                if newValue != oldValue {
                    diffs.append((key, newValue))
                }
            }
        }
        
        return diffs
    }
}

fileprivate extension Mirror {
    /// 将Mirror.Children转换成键值对的形式返回
    var pairs: [String: String] {
        var result = [String: String]()
        for pair in self.children {
            if let key = pair.label {
                result[key] = String(describing: pair.value)
            }
        }
        return result
    }
}
