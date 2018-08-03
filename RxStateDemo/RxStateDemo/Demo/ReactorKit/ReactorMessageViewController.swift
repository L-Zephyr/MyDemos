//
//  ReactorMessageViewController.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/4/4.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import RxViewController
import RxDataSources

class ReactorMessageViewController: UIViewController, ReactorKit.View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    let dataSource = RxTableViewSectionedReloadDataSource<MessageTableSectionModel>(configureCell: { dataSource, tableView, indexPath, item in
        return item.cell(in: tableView)
    }, canEditRowAtIndexPath: { _, _ in true })
    
    @IBOutlet weak var tableView: UITableView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        reactor = MessageReactor(service: MessageService())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刷新", style: .plain, target: nil, action: nil)
        
        /*
         <1>.
            reactor变量不能在视图的内部初始化，否则它就无法接收到与视图生命周期相关的事件（比如说下面用到的self.rx.viewDidLoad）
         
         <2>.
            Reactor并没有提供类似Redux中`reactor.dispatch(action)`这样的操作，View层向Reactor传递消息完全通过`reactor.action`类型来进行。
            reactor.action是一个Subject类型，可以直接通过`reactor.action.on(.next(action))`来传递消息，但是显然ReactorKit并不建议这种方式。
            而是通过RxCocoa提供的能力，将视图层的事件流绑定到Action上，通过action的这一层限制使得代码必须通过更加**函数式**的方式来编写
         */
    }
    
    /// 在这里进行绑定
    func bind(reactor: MessageReactor) {
        loadViewIfNeeded()
        
        self.rx.viewDidAppear
            .map { _ in Reactor.Action.request } // 1. 将事件流转换成Action
            .bind(to: reactor.action) // 2. 然后绑定到reactor.action上, 在ReactorKit中所有的 UI操作 -> 事件 都是这样完成的
            .disposed(by: self.disposeBag)
        

        /// 观察保存在Reactor中的状态
        reactor.state
            .map({ $0.loadingState })
            .subscribe(onNext: { value in
                if value == .loading {
                    self.startLoading()
                } else if value == .normal {
                    self.stopLoading()
                }
            })
            .disposed(by: disposeBag)
                
        /// TableView
        reactor.state
            .map({ $0.msgSections })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        // 删除某项
        tableView.rx.itemDeleted
            .map { Reactor.Action.removeItem($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // 点击刷新
        self.navigationItem.rightBarButtonItem?.rx
            .tap
            .map { Reactor.Action.request }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
}

