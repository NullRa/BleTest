//
//  BleManager.swift
//  BleTest
//
//  Created by Jay on 2020/6/26.
//  Copyright © 2020 Null. All rights reserved.
//


//https://www.itread01.com/content/1550073243.html
//參考上面連結實作，這篇真的寫得很好。
import CoreBluetooth
protocol BleManagerDelegate: class {
    func setBleState(state:BleState)
}
class BLEManager: NSObject {
    //單例物件
    static let shared = BLEManager()
    //中心物件
    var central: CBCentralManager?
    //裝置列表
    var deviceList: NSMutableArray?
    //當前連線的裝置
    var peripheral: CBPeripheral!
    //傳送資料特徵(連線到裝置之後可以把需要用到的特徵儲存起來，方便使用)
    var sendCharacteristic:CBCharacteristic?
    //可以用下面兩種方式來搜尋設備
    //    let servicesUUID : [CBUUID] = [CBUUID.init(string: "servicesUUIDs")]
    var deviceName: String?

    var delegate: BleManagerDelegate?

    override init() {
        super.init()
        self.central = CBCentralManager.init(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:false])
        self.deviceList = NSMutableArray()
    }

    //掃描裝置的方法 //可以搜尋特定servicesuuid
    func scanForPeripheralsWithServices(_ serviceUUIDS:[CBUUID]?, options:[String: AnyObject]?, deviceName:String){
        self.deviceName = deviceName
        self.central?.scanForPeripherals(withServices: serviceUUIDS, options: options)
        //        self.central?.scanForPeripherals(withServices: servicesUUID, options: options)
    }

    //停止掃描
    func stopScan(){
        self.central?.stopScan()
    }

    //寫資料
    func writeToPeripheral(_ data: Data) {
        peripheral.writeValue(data, for: sendCharacteristic!, type: .withResponse)
    }

    //連線某個裝置的方法
    func requestConnectPeripheral(_ model: CBPeripheral) {
        if model.state != .connected {
            central?.connect(model, options: nil)
        }
    }

    //取得裝置名稱列表
    func getDeviceNameArray() -> [String]{
        var nameArray:[String] = []
        guard let array = deviceList as? [CBPeripheral] else {
            print("deviceList as? [CBPeripheral] EOORO")
            return nameArray
        }
        for value in array {
            nameArray.append(value.name ?? "No device name")
        }
        return nameArray
    }
}

extension BLEManager: CBCentralManagerDelegate{
    //    檢查執行這個App的裝置是不是支援BLE
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("藍牙開啟")
            delegate?.setBleState(state: .poweredOn)
        case .unauthorized:
            print("沒有藍芽功能")
            delegate?.setBleState(state: .unauthorized)
        case .poweredOff:
            print("藍牙關閉")
            delegate?.setBleState(state: .poweredOff)
        default:
            print("未知狀態")
            delegate?.setBleState(state: .unknown)
        }
        // 手機藍芽狀態發生變化，可以傳送通知出去。提示使用者
    }

    //中心管理器掃描到了裝置
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //  因為iOS目前不提供藍芽裝置的UUID的獲取，所以在這裡通過藍芽名稱判斷是否是本公司的裝置
        if deviceList!.contains(peripheral) {
            print("deviceList!.contains(peripheral) == true")
            return
        }

        guard peripheral.name != nil else {
            print("peripheral.name == nil")
            return
        }

        //如果deviceName為空則把所有掃到的設備加入列表中
        if let deviceName = deviceName, deviceName != "" {
            if peripheral.name!.contains(deviceName) {
                deviceList?.add(peripheral)
            }
        } else {
            deviceList?.add(peripheral)
        }
    }

    //連線外設成功，開始發現服務
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        // 設定代理
        peripheral.delegate = self
        // 開始發現服務
        peripheral.discoverServices(nil)
        // 儲存當前連線裝置
        self.peripheral = peripheral
        // 這裡可以發通知出去告訴裝置連線介面連線成功
    }
    // MARK: 連線外設失敗
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // 這裡可以發通知出去告訴裝置連線介面連線失敗
    }
    // MARK: 連線丟失
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DidDisConnectPeriphernalNotification"), object: nil, userInfo: ["deviceList": self.deviceList as AnyObject])
        // 這裡可以發通知出去告訴裝置連線介面連線丟失
    }
}

// 外設的代理
extension BLEManager : CBPeripheralDelegate {
    //MARK: - 匹配對應服務UUID
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        if error != nil {
            return
        }
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service )
        }
    }
    //MARK: - 服務下的特徵
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        if (error != nil){
            return
        }
        for  characteristic in service.characteristics! {

            switch characteristic.uuid.description {

            case "具體特徵值":
                // 訂閱特徵值，訂閱成功後後續所有的值變化都會自動通知
                peripheral.setNotifyValue(true, for: characteristic)
            case "******":
                // 讀區特徵值，只能讀到一次
                peripheral.readValue(for:characteristic)
            default:
                print("掃描到其他特徵")
            }
        }
    }
    //MARK: - 特徵的訂閱狀體發生變化
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?){
        guard error == nil  else {
            return
        }
    }
    // MARK: - 獲取外設發來的資料
    // 注意，所有的，不管是 read , notify 的特徵的值都是在這裡讀取
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)-> (){
        if(error != nil){
            return
        }
        switch characteristic.uuid.uuidString {
        case "***************":
            print("接收到了裝置的溫度特徵的值的變化")
        default:
            print("收到了其他資料特徵資料: \(characteristic.uuid.uuidString)")
        }
    }
    //MARK: - 檢測中心向外設寫資料是否成功
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if(error != nil){
            print("傳送資料失敗!error資訊:\(String(describing: error))")
        }
    }
}
