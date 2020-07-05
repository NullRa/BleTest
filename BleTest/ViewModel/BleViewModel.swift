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
    let shakingManager = ShakingManager.shared
    let bleArray = BehaviorRelay<[String]>(value: [])
    let showLoadingSubject = PublishSubject<Bool>()
    let bleStateSubject = PublishSubject<BleState>()
    let scanButtonEnabled:Observable<Bool>
    let isShakingSubject = PublishSubject<Bool>()
    init(){
        scanButtonEnabled = bleStateSubject.asObservable().map{
            state in
            return state == .poweredOn
        }.share(replay: 1)

        bleManager.delegate = self
        shakingManager.delegate = self
    }

    func scanDevice(deviceName:String){
        showLoadingSubject.onNext(true)
        bleManager.scanForPeripheralsWithServices(nil, options: nil, deviceName: deviceName)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.bleManager.stopScan()
            self.bleArray.accept(self.bleManager.getDeviceNameArray())
            self.showLoadingSubject.onNext(false)
        }
    }

    func getDeviceName(index:Int)->String{
        return bleArray.value[index]
    }

    func connectBLE(index:Int){
        let deviceName = bleArray.value[index]
        bleManager.requestConnect(deviceName: deviceName)
    }

    //shakingManager
    func startDetectShaking(){
        shakingManager.accelerometerPush()
    }

    func stopDetectShaking(){
        shakingManager.accelerometerStop()
    }
}

extension BleViewModel: BleManagerDelegate {
    func setBleState(state: BleState) {
        bleStateSubject.onNext(state)
    }
}

extension BleViewModel: ShakingManagerDelegate {
    func getShakingState(enable: Bool) {
        isShakingSubject.onNext(enable)
    }
}

enum BleState: String{
    case poweredOn
    case unauthorized
    case poweredOff
    case unknown
}
