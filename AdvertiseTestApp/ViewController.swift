import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    private var centralManager: CBCentralManager!
    private var cbPeripheral:CBPeripheral? = nil
//    private var serviceUUID: [CBUUID] = [CBUUID(string: "")]
    // BLEで用いるサービス用のUUID
        let BLELoacalName = "TEST BLE"
        
        let BLEServiceUUID = CBUUID(string:"AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")

        // BLEで用いるキャラクタリスティック用のUUID
        let BLEWriteCharacteristicUUID = CBUUID(string:"AAAAAAAA-AAAA-BBBB-BBBB-BBBBBBBBBBBB")
        let BLEWriteWithoutResponseCharacteristicUUID = CBUUID(string:"AAAAAAAA-BBBB-BBBB-BBBB-BBBBBBBBBBBB")
        let BLEReadCharacteristicUUID = CBUUID(string:"AAAAAAAA-CCCC-BBBB-BBBB-BBBBBBBBBBBB")
        let BLENotifyCharacteristicUUID = CBUUID(string:"AAAAAAAA-DDDD-BBBB-BBBB-BBBBBBBBBBBB")
        let BLEIndicateCharacteristicUUID = CBUUID(string:"AAAAAAAA-EEEE-BBBB-BBBB-BBBBBBBBBBBB")
    
    var data: NSMutableArray! = []
    private var writeCharacteristic: CBCharacteristic? = nil
    private var readCharacteristic: CBCharacteristic? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        scanBtn.addTarget(self, action: #selector(self.scanButton(_:)), for: UIControl.Event.touchUpInside)
        stopBtn.addTarget(self, action: #selector(self.stopButton(_:)), for: UIControl.Event.touchUpInside)
        deleteBtn.addTarget(self, action: #selector(self.deleteButton(_:)), for: UIControl.Event.touchUpInside)
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        centralManager.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // セルに表示する値を設定する
        cell.textLabel?.text = "\(data[indexPath.row])"
        
        return cell
    }
    

    @IBAction func scanButton(_ sender: Any) {
        print("scan")
        scan()
    }

    @IBAction func stopButton(_ sender: Any) {
        print("disconnect")
        if (cbPeripheral != nil) {
            disconnect(peripheral: cbPeripheral!)
        }
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        print("履歴削除")
        data = []
        tableView.reloadData()
    }
    
    func scan() {
//        centralManager.scanForPeripherals(withServices: serviceUUID, options: nil)
        centralManager.scanForPeripherals(withServices: nil, options: nil)

    }

    func stopScan() {
        centralManager.stopScan()
    }

    func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
}

extension ViewController: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
                //②:セントラル側BLEの電源ONを待つ
                //BLEが使用可能な状態：電源がONになっている
            case CBManagerState.poweredOn:
                print("Bluetooth PowerON")
                break
                //BLEが使用出来ない状態：電源がONになっていない
            case CBManagerState.poweredOff:
                print("Bluetooth PoweredOff")
                break
                //BLEが使用出来ない状態：リセット中
            case CBManagerState.resetting:
                print("Bluetooth resetting")
                break
                //BLEが使用出来ない状態：Permissionの許諾が得られていない
            case CBManagerState.unauthorized:
                print("Bluetooth unauthorized")
                break
                //BLEが使用出来ない状態：不明な場外
            case CBManagerState.unknown:
                print("Bluetooth unknown")
                break
                //BLEが使用出来ない状態：BLEをサポートしていない
            case CBManagerState.unsupported:
                print("Bluetooth unsupported")
                break
            }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        if (peripheral.name != nil && advertisementData["kCBAdvDataServiceUUIDs"] != nil)
        if (peripheral.name == "聡吾のAirPods") {
            let date = Date()
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            print(formatter.string(from: date))
            data.add("name:\(peripheral.name)")
            data.add("advertisementData:\(advertisementData)")
            data.add("advertisementServiceUUID:\(advertisementData["kCBAdvDataServiceUUIDs"])")
            data.add("rssi:\(RSSI.stringValue)")
            tableView.reloadData()
            print(data)
            self.cbPeripheral = peripheral
            connect(peripheral: peripheral)
            stopScan()
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("接続成功")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            print("接続失敗")
        }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("切断")
    }
}

extension ViewController: CBPeripheralDelegate {
    //サービスが見つかった時に呼ばれるデリゲートメソッド
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            //全てのサービスのキャラクタリスティックの検索
            for service in peripheral.services! {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    
    //キャラクタリスティックが見つかった時に呼ばれるデリゲートメソッド
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            for characteristic in service.characteristics!{
//                if characteristic.uuid == BLENotifyCharacteristicUUID {
//                    print("Notify")
//                    peripheral.setNotifyValue(true, for: characteristic)
//                }
//                
//                if characteristic.uuid == BLEIndicateCharacteristicUUID {
//                    print("Indicate")
//                    peripheral.setNotifyValue(true, for: characteristic)
//                }
//
//                if characteristic.uuid == BLEWriteCharacteristicUUID {
//                    print("Write")
//                    writeCharacteristic = characteristic
//                }
//                if characteristic.uuid == BLEReadCharacteristicUUID{
//                    print("Read")
//                    readCharacteristic = characteristic
//                }
                //なおcharacteristicの属性は以下で取得可能
                //characteristic.propertie
                //「.indicate .notify .read .write .writeWithoutResponse」で属性の判別が可能
                print("発見したキャラクタリスティック",characteristic.uuid.uuidString)
            }
    }
    
    //write実行時に呼ばれる
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            if let error = error {
                print("書き込みエラー：",error.localizedDescription)
                return
            }else{
                print("書き込み成功：",characteristic.uuid)

            }
        }
    //Notify or indicate or Read時に呼ばれる
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            
            print("送信元のCharacteristic:",characteristic.uuid.uuidString)
            if let error = error {
                print("情報受信失敗...error:",error.localizedDescription)
            } else {
                print("受信成功")
                let receivedData = String(bytes: characteristic.value!, encoding: String.Encoding.ascii)
                print("受信データ",receivedData)
//                switch characteristic.properties{
//                case .read:
//                    logTextView.text.append("read \n")
//                case .indicate:
//                    logTextView.text.append("indicate \n")
//
//                case .notify:
//                    logTextView.text.append("notify \n")
//                default:
//                    logTextView.text.append("unknown \n")
//                }
//
//                logTextView.text.append("受信データ：\(receivedData) \n")
            }
        }
}
