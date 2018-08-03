//
//  DemoListViewController.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/4/4.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DemoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        Observable.just(["普通实现",
                         "ReSwift实现",
                         "ReactorKit实现",
                         "自定义实现"])
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element)"
            }
            .disposed(by: self.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                switch indexPath.row {
                case 0:
                    let vc = TraditionalMessageViewController(nibName: "TraditionalMessageViewController", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                case 1:
                    let vc = ReduxMessageViewController(nibName: "ReduxMessageViewController", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                case 2:
                    let vc = ReactorMessageViewController(nibName: "ReactorMessageViewController", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                case 3:
                    StateChangeRecorder.shared.enableInDebug = true
                    let vc = MessageViewController(nibName: "MessageViewController", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            })
            .disposed(by: self.disposeBag)
    }
}
