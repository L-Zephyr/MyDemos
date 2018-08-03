//
//  MessageService.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/4/6.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import RxSwift

/// Service是处理具体业务逻辑的地方，Reactor相当于View和Service中的一个中间层，Reactor中会保存一个Service对象，通过它来处理业务逻辑。不仅仅是网络请求，其他的业务逻辑也在Service中完成，Reactor和Service就像原本ViewModel的功能拆分成两部分
protocol MessageServiceType {
    /// 网络请求
    func request() -> Observable<[MessageTableSectionModel]>
}

final class MessageService: MessageServiceType {
    func request() -> Observable<[MessageTableSectionModel]> {
        return MessageProvider.rx.request(.news)
            .map([MsgItem].self)
            .map({ (news) -> [MessageTableSectionModel] in
                let cellModels = news.map {
                    return MessageTableCellModel.news($0)
                }
                
                return [MessageTableSectionModel(items: cellModels, index: 0)]
            })
            .asObservable()
    }
}
