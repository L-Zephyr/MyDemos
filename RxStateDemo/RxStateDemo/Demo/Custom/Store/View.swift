//
//  View.swift
//  RxDemo
//
//  Created by LZephyr on 2018/3/14.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import RxSwift

/// 视图层协议
public protocol View: class {
    /// 用于声明该视图对应的ViewModel的类型
    associatedtype ViewModel: StoreType
    
    /// ViewModel的实例，有默认实现，视图层需要在合适的时机初始化
    var viewModel: ViewModel? { set get }
    
    /// 视图层实现这个方法，并在其中进行绑定
    func doBinding(_ vm: ViewModel)
}

// MARK: - 辅助方法

fileprivate var bagKey = "bagKey"

public extension View {
    /// DisposeBag
    var disposeBag: DisposeBag {
        set {
            objc_setAssociatedObject(self, &bagKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let bag = objc_getAssociatedObject(self, &bagKey) as? DisposeBag {
                return bag
            } else {
                let bag = DisposeBag()
                self.disposeBag = bag
                return bag
            }
        }
    }
}

// MARK: - Private

fileprivate var viewModelKey = "viewModelKey"

extension View {
    var viewModel: ViewModel? {
        set {
            objc_setAssociatedObject(self, &viewModelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let vm = newValue {
                self.doBinding(vm)
            }
        }
        
        get {
            return objc_getAssociatedObject(self, &viewModelKey) as? ViewModel
        }
    }
}
