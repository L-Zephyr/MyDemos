
//  MessageViewModel.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/5/25.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - MessageViewModelState

struct MessageState: StateType {
    var msgList: [MsgItem] = [] // 原始数据
    var loadingState: ViewLoadingStatus = .normal
}

// MARK: - Rx Getter

extension Reactive where Base: MessageViewModel {
    var sections: Driver<[MessageTableSectionModel]> {
        return base.rxState
            .map({ (state) -> [MessageTableSectionModel] in
                return [
                    MessageTableSectionModel(items: state.msgList.map { MessageTableCellModel.news($0) }, index: 0)
                ]
            })
            .asDriver(onErrorJustReturn: [])
    }
    
    var loadingState: Driver<ViewLoadingStatus> {
        return base.rxState
            .map { $0.loadingState }
            .asDriver(onErrorJustReturn: .normal)
    }
}

// MARK: - MessageViewModelViewModel

class MessageViewModel: Store<MessageState> {
    required public init(state: MessageState) {
        super.init(state: state)
    }
    
    func request() {
        /// 通过performStateUpdate直接更新状态
        performStateUpdate { $0.loadingState = .loading }
        
        MessageProvider.rx
            .request(.news)
            .map([MsgItem].self)
            .subscribe(onSuccess: { (items) in
                self.performStateUpdate {
                    $0.msgList = items
                    $0.loadingState = .normal
                }
            }, onError: { error in
                self.performStateUpdate {
                    $0.loadingState = .normal
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func remove(at index: Int) {
        performStateUpdate {
            $0.msgList.remove(at: index)
        }
    }
}
