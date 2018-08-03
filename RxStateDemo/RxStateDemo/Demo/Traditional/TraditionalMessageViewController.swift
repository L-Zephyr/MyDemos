//
//  TraditionalMessageViewController.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/5/24.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import UIKit

class TraditionalMessageViewController: UIViewController {
    
    var msgList: [MsgItem] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刷新",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(refreshButtonPressed))
        
        request()
    }
    
    @objc func refreshButtonPressed() {
        request()
    }
    
    func request() {
        // 1. 开始请求前播放loading动画
        self.startLoading()
        
        MessageProvider.request(.news) { (result) in
            switch result {
            case .success(let response):
                if let list = try? response.map([MsgItem].self) {
                    // 2. 请求结束后更新model
                    self.msgList = list
                }
            case .failure(_):
                break
            }
            
            // 3. model更新后同步更新UI
            self.stopLoading()
            self.tableView.reloadData()
        }
    }
}

extension TraditionalMessageViewController: UITableViewDelegate {
    
}

extension TraditionalMessageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        let news = msgList[indexPath.row]
        cell?.textLabel?.text = "\(news.title) \(news.index)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 1. 更新数据源
            self.msgList.remove(at: indexPath.row)
            
            // 2. 刷新UI
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
