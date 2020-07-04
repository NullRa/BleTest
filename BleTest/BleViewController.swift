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

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bind()
    }

    func initUI(){
        bleTableView.tableFooterView = UIView()
    }

    func bind(){
        bleViewModel = BleViewModel()

        scanButton.rx.tap.subscribe(onNext:{[weak self] in
            guard let s = self else {return}
            s.bleViewModel.scanDevice(deviceName: "")
            }).disposed(by: disposeBag)

        bleViewModel.bleArray.bind(to: self.bleTableView.rx.items(cellIdentifier: "bleCell", cellType: UITableViewCell.self)) { index, model, cell in
        cell.textLabel?.text = model
             }.disposed(by: self.disposeBag)
    }
}
