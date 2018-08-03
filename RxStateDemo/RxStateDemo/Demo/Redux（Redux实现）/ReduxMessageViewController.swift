//
//  ReduxMessageViewController.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/4/4.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift

class ReduxMessageViewController: UIViewController, StoreSubscriber {
    
    let disposeBag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刷新", style: .plain, target: self, action: #selector(refreshButtonPressed))
        
        // 让当前的VC订阅messageStore
        messageStore.subscribe(self)

        // 使用ActionCreator来做网络请求
        messageStore.dispatch(reduxMessageRequest)
    }
    
    @objc func refreshButtonPressed() {
        messageStore.dispatch(reduxMessageRequest)
    }
    
    // MARK: - StoreSubscriber
    
    /// 任何Action引起数据改变后都会调用这个方法通知View更新
    func newState(state: ReduxMessageState) {
        // 加载状态
        if state.loadingState == .loading {
            self.startLoading()
        } else if state.loadingState == .normal {
            self.stopLoading()
        }
        
        // 列表数据
        tableView.reloadData()
    }
}

extension ReduxMessageViewController: UITableViewDataSource {
    
    /// View不会直接修改Model的数据，而是通过向Store发送Action的形式间接的去修改
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 发送一个修改数据的action
            messageStore.dispatch(ActionRemoveMessage(index: indexPath.row))
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageStore.state.newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        let news = messageStore.state.newsList[indexPath.row]
        cell?.textLabel?.text = "\(news.title) \(news.index)"
        
        return cell!
    }
}

extension ReduxMessageViewController: UITableViewDelegate {
    
}
