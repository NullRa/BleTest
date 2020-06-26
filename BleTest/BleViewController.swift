//
//  ViewController.swift
//  BleTest
//
//  Created by Jay on 2020/6/26.
//  Copyright © 2020 Null. All rights reserved.
//

import UIKit

class BleViewController: UIViewController {

    var bleArray:[String] = []
    var bleManager = BLEManager.shared

    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var bleTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bind()
    }

    func initUI(){

    }

    func bind(){
        bleTableView.delegate = self
        bleTableView.dataSource = self
        scanButton.addTarget(self, action: #selector(scanButtonAction), for: .touchUpInside)
    }

    @objc func scanButtonAction(){
        bleManager.scanForPeripheralsWithServices(nil, options: nil, deviceName: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.bleManager.stopScan()
            self.reloadBleTableView()
        }
    }

    func reloadBleTableView(){
        bleArray = bleManager.getDeviceNameArray()
        bleTableView.reloadData()
    }
}


extension BleViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bleCell", for: indexPath)
        cell.textLabel?.text = bleArray[indexPath.row]
        return cell
    }


}
