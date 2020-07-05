//
//  ShakingManager.swift
//  BleTest
//
//  Created by Jay on 2020/7/5.
//  Copyright © 2020 Null. All rights reserved.
//

import Foundation
import CoreMotion
protocol ShakingManagerDelegate: class {
    func getShakingState(enable: Bool)
}
class ShakingManager {
    static var shared = ShakingManager()
    var manager = CMMotionManager()
    private var queue = OperationQueue()
    var delayFlag: Bool = true
    var delegate: ShakingManagerDelegate?

    //Detect shaking motaion
    func accelerometerPush() {
        guard self.manager.isAccelerometerAvailable else {
            print("裝置不支援搖一搖功能")
            return
        }
        self.manager.accelerometerUpdateInterval = 0.1
        //開始獲取資訊
        manager.startAccelerometerUpdates(to: queue) { (data: CMAccelerometerData?, error: Error?) in
            let acceleration = data?.acceleration
            let accelerameter = sqrt(pow(acceleration!.x, 2) + pow(acceleration!.y, 2) + pow(acceleration!.z, 2))
            if accelerameter > Double(2.0) && self.delayFlag {
                //綜合加速度>設定值(2~4)才會觸發底下的程式(數字越小越靈敏)
                if self.delayFlag == false {
                    return
                }
                self.delayFlag = false
                self.delegate?.getShakingState(enable: !self.delayFlag)
                print("shaking shaking")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                    print("reset shaking")
                    self.delayFlag = true
                    self.delegate?.getShakingState(enable: !self.delayFlag)
                }
            }
        }
    }

    //Stop Detect shaking motaion
    func accelerometerStop() {
        guard manager.isAccelerometerActive else {
            return
        }
        self.manager.stopAccelerometerUpdates()
    }
}

