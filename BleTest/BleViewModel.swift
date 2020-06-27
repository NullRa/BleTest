//
//  BleViewModel.swift
//  BleTest
//
//  Created by Jay on 2020/6/27.
//  Copyright © 2020 Null. All rights reserved.
//

class BleViewModel {
    let bleVC: BleViewController!
    var bleManager = BLEManager.shared

    var bleArray:[String] = []
    
    init(bleViewController: BleViewController){
        bleVC = bleViewController
    }

    func scanDeviceName(deviceName:String){
        bleManager.scanForPeripheralsWithServices(nil, options: nil, deviceName: deviceName)
    }

    func stopScan(){
        bleManager.stopScan()
    }
    
    func getDeviceNameArray(){
        bleArray = bleManager.getDeviceNameArray()
    }
}
