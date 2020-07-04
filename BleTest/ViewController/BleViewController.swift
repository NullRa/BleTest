//
//  ViewController.swift
//  BleTest
//
//  Created by Jay on 2020/6/26.
//  Copyright © 2020 Null. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BleViewController: UIViewController {
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var bleTableView: UITableView!

    var bleViewModel: BleViewModel!
    var disposeBag = DisposeBag()
    var hud = HudManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bind()
    }

    func initUI(){
        bleTableView.tableFooterView = UIView()
        scanButton.setTitle("SCAN".localized, for: .normal)
    }

    func scanAction(){
        let alert = UIAlertController(title: "輸入搜尋設備名稱", message: "空白即搜尋所有設備", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            guard let deviceNameTextField = alert.textFields?.first else {
                return
            }
            self.bleViewModel.scanDevice(deviceName: deviceNameTextField.text ?? "")
        }
        alert.addTextField { (textField) in
            textField.placeholder = "輸入搜尋設備名稱"
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    func bind(){
        bleViewModel = BleViewModel()

        scanButton.rx.tap.subscribe(onNext:{[weak self] in
            guard let s = self else {return}
            s.scanAction()
        }).disposed(by: disposeBag)

        bleViewModel.bleArray.bind(to: self.bleTableView.rx.items(cellIdentifier: "bleCell", cellType: UITableViewCell.self)) { index, model, cell in
            cell.textLabel?.text = model
        }.disposed(by: self.disposeBag)

        bleViewModel.showLoadingSubject
            .subscribe(onNext:{
                showLoading in
                if showLoading {
                    DispatchQueue.main.async {
                        self.hud.showSimpleHUD(toView: self.view, text: "Scan...".localized, detailText: "Wait...".localized)
                    }
                } else {
                    if self.hud.hud != nil {
                        self.hud.hideHUD()
                    }
                }
            }).disposed(by: self.disposeBag)
    }
}
