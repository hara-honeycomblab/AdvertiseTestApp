import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    private var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        scanBtn.addTarget(self, action: #selector(self.scanButton(_:)), for: UIControl.Event.touchUpInside)
        stopBtn.addTarget(self, action: #selector(self.stopButton(_:)), for: UIControl.Event.touchUpInside)
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        centralManager.delegate = self
    }
    

    @IBAction func scanButton(_ sender: Any) {
        scan()
    }

    @IBAction func stopButton(_ sender: Any) {
        stopScan()
    }

    func deviceLabel(string: String) {
        print(string)
    }
    
    func scan() {
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
//        print("state: \(central.state.rawValue)")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        deviceLabel(string: "pheripheral.name: \(String(describing: peripheral.name))" + "\n" + "advertisementData:\(advertisementData.count)" + "\n" +
                "RSSI: \(RSSI)" + "\n")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
}
