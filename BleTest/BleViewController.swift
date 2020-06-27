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
    let relay = BehaviorRelay<[String]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bind()
    }

    func initUI(){

    }

    func bind(){
        bleViewModel = BleViewModel(bleArrayRelay: relay)
        scanButton.rx.tap.subscribe(onNext:{[weak self] in
            guard let s = self else {return}
            s.bleViewModel.scanDeviceName(deviceName: "")
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                s.bleViewModel.stopScan()
                s.reloadBleTableView()
            }
            }).disposed(by: disposeBag)

        relay.bind(to: self.bleTableView.rx.items(cellIdentifier: "bleCell", cellType: UITableViewCell.self)) { index, model, cell in
            cell.textLabel?.text = model
                 }.disposed(by: self.disposeBag)
    }

    func reloadBleTableView(){
        bleViewModel.getDeviceNameArray()
    }
}
