//
//  BleViewModel.swift
//  BleTest
//
//  Created by Jay on 2020/6/27.
//  Copyright © 2020 Null. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation
class BleViewModel {
    let bleManager = BLEManager.shared
    let bleArray: BehaviorRelay<[String]>

    init(bleArrayRelay:BehaviorRelay<[String]>){
        bleArray = bleArrayRelay
        bleArray.accept([])
    }

    func scanDevice(deviceName:String){
        bleManager.scanForPeripheralsWithServices(nil, options: nil, deviceName: deviceName)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.bleManager.stopScan()
            self.bleArray.accept(self.bleManager.getDeviceNameArray())
        }
    }
}
