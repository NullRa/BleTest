//
//  UIViewController.swift
//  BleTest
//
//  Created by Jay on 2020/7/4.
//  Copyright © 2020 Null. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentAlert(title:String,message:String?,actions:[UIAlertAction] = [UIAlertAction(title: "OK".localized, style: .default, handler: nil)]){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
    }
}
