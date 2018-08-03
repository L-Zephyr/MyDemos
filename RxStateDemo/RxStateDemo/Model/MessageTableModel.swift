//
//  MessageTableModel.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/4/5.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import RxDataSources

/// 定义一个用来描述所有Cell的枚举类型
enum MessageTableCellModel {
    case news(MsgItem)
    // ...
}

extension MessageTableCellModel: IdentifiableType, Equatable {
    var identity: String {
        switch self {
        case .news(let item):
            return "\(item.title)\(item.index)"
        }
    }
    
    static func ==(_ lhs: MessageTableCellModel, _ rhs: MessageTableCellModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension MessageTableCellModel {
    func cell(in tableView: UITableView) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        switch self {
        case .news(let msg):
            cell?.textLabel?.text = "\(msg.title) \(msg.index)"
        }
        
        return cell!
    }
}

/// SectionModel用来表示Table中的Section，每个Section中的Cell保存在items中
struct MessageTableSectionModel {
    var items: [MessageTableCellModel]
    var index: Int
}

extension MessageTableSectionModel: SectionModelType, AnimatableSectionModelType {
    init(original: MessageTableSectionModel, items: [MessageTableCellModel]) {
        self.items = items
        self.index = 0
    }
    
    var identity: Int {
        return index
    }
}
