//
//  UIViewController+Extension.swift
//  RxStateDemo
//
//  Created by LZephyr on 2018/5/24.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func startLoading() {
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
    }
    
    func stopLoading() {
        self.indicatorView.stopAnimating()
    }
}

// MARK: - Subview

fileprivate var indicatorKey = "indicatorKey"

extension UIViewController {
    var indicatorView: UIActivityIndicatorView {
        set (newValue) {
            objc_setAssociatedObject(self, &indicatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let indicator = objc_getAssociatedObject(self, &indicatorKey) as? UIActivityIndicatorView {
                self.view.bringSubview(toFront: indicator)
                return indicator
            }
            
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.hidesWhenStopped = true
            self.view.addSubview(indicator)
            indicator.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
            
            self.indicatorView = indicator
            return indicator
        }
    }
}
