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
        let alert = UIAlertController(title: "Enter device name".localized, message: "Search all device without enter".localized, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Confirm".localized, style: .default) { (_) in
            guard let deviceNameTextField = alert.textFields?.first else {
                return
            }
            self.bleViewModel.scanDevice(deviceName: deviceNameTextField.text ?? "")
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter device name".localized
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

        //取得index
        bleTableView.rx.itemSelected.subscribe(onNext:{
            [weak self]indexPath in
            guard let s = self else {return}
            let bleIndex = indexPath.row
            let deviceName = s.bleViewModel.getDeviceName(index: bleIndex)

            let actions = [
                UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil),
                UIAlertAction(title: "Confirm".localized, style: .default, handler: { _ in
                    print("device: \(deviceName)")
                    self?.bleViewModel.connectBLE(index: bleIndex)
                })
            ]
            s.presentAlert(title: "連接裝置", message: "裝置: \(deviceName)", actions: actions)

        }).disposed(by: disposeBag)

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

        bleViewModel.bleStateSubject
            .subscribe(onNext:{
                state in
                switch state {
                case .poweredOn:
                    print("powerOn")
                case .poweredOff:
                    print("powerOff")
                    self.presentAlert(title: "Ble power off", message: nil)
                case .unauthorized:
                    print("unauthorized")
                    self.presentAlert(title: "Ble unauthiruzed", message: nil)
                case .unknown:
                    print("unknown")
                    self.presentAlert(title: "Ble state unknow", message: nil)
                }
            }).disposed(by: disposeBag)

        bleViewModel.scanButtonEnabled
            .subscribe(onNext: {
                [weak self] in
                self?.scanButton.isEnabled = $0
                self?.scanButton.alpha = $0 ? 1 : 0.5
               }).disposed(by: disposeBag)
    }
}
