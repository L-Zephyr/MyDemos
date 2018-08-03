
//  MessageViewController.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/5/25.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MessageViewController: UIViewController, View {
    
    @IBOutlet weak var tableView: UITableView!
    
    let dataSource = RxTableViewSectionedAnimatedDataSource<MessageTableSectionModel>(configureCell: { dataSource, tableView, indexPath, item in
        return item.cell(in: tableView)
    }, canEditRowAtIndexPath: { _, _ in true })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刷新", style: .plain, target: nil, action: nil)
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .bottom)
        
        // 1. 初始化ViewModel
        self.viewModel = MessageViewModel(state: MessageState())
        
        // 2. 开始网络请求
        self.viewModel?.request()
    }
    
    // Rx事件绑定
    func doBinding(_ vm: MessageViewModel) {
        // 绑定tableView数据源
        vm.rx.sections
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        // 绑定加载状态
        vm.rx.loadingState
            .drive(onNext: { [weak self] state in
                switch state {
                case .loading:
                    self?.startLoading()
                case .normal:
                    self?.stopLoading()
                }
            })
            .disposed(by: self.disposeBag)
        
        // 绑定删除事件
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] index in
                self?.viewModel?.remove(at: index.row)
            })
            .disposed(by: self.disposeBag)
        
        // 绑定刷新事件
        self.navigationItem.rightBarButtonItem?.rx
            .tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel?.request()
            })
            .disposed(by: self.disposeBag)
        
    }
}
