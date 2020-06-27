//
//  BleViewModel.swift
//  BleTest
//
//  Created by Jay on 2020/6/27.
//  Copyright © 2020 Null. All rights reserved.
//

import RxSwift
import RxCocoa
class BleViewModel {
    let bleManager = BLEManager.shared
    let bleArray: BehaviorRelay<[String]>

    init(bleArrayRelay:BehaviorRelay<[String]>){
        bleArray = bleArrayRelay
        bleArray.accept([])
    }

    func scanDeviceName(deviceName:String){
        bleManager.scanForPeripheralsWithServices(nil, options: nil, deviceName: deviceName)
    }

    func stopScan(){
        bleManager.stopScan()
    }
    
    func getDeviceNameArray(){
        bleArray.accept(bleManager.getDeviceNameArray())
    }
}
