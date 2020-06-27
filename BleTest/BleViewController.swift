//
//  ViewController.swift
//  BleTest
//
//  Created by Jay on 2020/6/26.
//  Copyright © 2020 Null. All rights reserved.
//

import UIKit

class BleViewController: UIViewController {
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var bleTableView: UITableView!

    var bleViewModel: BleViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bind()
    }

    func initUI(){

    }

    func bind(){
        bleViewModel = BleViewModel(bleViewController: self)
        bleTableView.delegate = self
        bleTableView.dataSource = self
        scanButton.addTarget(self, action: #selector(scanButtonAction), for: .touchUpInside)
    }

    @objc func scanButtonAction(){
        bleViewModel.scanDeviceName(deviceName: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.bleViewModel.stopScan()
            self.reloadBleTableView()
        }
    }

    func reloadBleTableView(){
        bleViewModel.getDeviceNameArray()
        bleTableView.reloadData()
    }
}


extension BleViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleViewModel.bleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bleCell", for: indexPath)
        cell.textLabel?.text = bleViewModel.bleArray[indexPath.row]
        return cell
    }


}
