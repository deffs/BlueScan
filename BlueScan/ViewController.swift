//
//  ViewController.swift
//  BlueScan
//
//  Created by Alex de France on 4/14/18.
//  Copyright © 2018 Def Labs. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let CHARACTERISTIC_UUID = "FFF3"
    private var centralManager: CBCentralManager?
    private var discoveredPerip: CBPeripheral?
    private var bluetoothOn = false
    @IBOutlet weak var outTxt: UITextView!
    @IBOutlet weak var verbSelector: UISegmentedControl!
    @IBOutlet weak var valueLbl: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        outTxt.layer.cornerRadius = 8.0
        tLog(msg: "Bluetooth LE Device Scanner\r\n\r\nProgramming IoT for iOS")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func verboseMode() -> Bool {
        return verbSelector.selectedSegmentIndex != 0
    }
    
    func tLog(msg: String) {
        let startTxt = "\r\n\r\n"
        outTxt.text = startTxt+outTxt.text
        outTxt.text = msg+outTxt.text
    }
    
    @IBAction func startTap(_ sender: Any) {
        if let send = sender as? UIButton {
            if send.isSelected {
                bluetoothOn = false
                send.isSelected = !send.isSelected
            } else {
                send.isSelected = !send.isSelected
            }
        }
        if !bluetoothOn {
            print("bluetooth off")
            return
        } else {
            centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //
        if central.state != .poweredOn {
            tLog(msg: "Bluetooth OFF")
            self.bluetoothOn = false
        } else {
            tLog(msg: "Bluetooth ON")
            self.bluetoothOn = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let data = advertisementData["kCBAdvDataLocalName"] {
            tLog(msg: "Discovered \(data), RSSI \(RSSI)")
        } else {
            tLog(msg: "No peripherals found")
            for (x,_) in advertisementData {
                tLog(msg: "Key \(x)")
            }
            
        }
        discoveredPerip = peripheral
        
        if verboseMode() {
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            tLog(msg: err.localizedDescription)
        }
        
        for service in peripheral.services! {
            tLog(msg: "Discovered service: \(service.description)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            tLog(msg: err.localizedDescription)
        }
        
        for characteristic in service.characteristics! {
            tLog(msg: "Discovered service: \(characteristic.description)")
            if characteristic.uuid == CBUUID(string: CHARACTERISTIC_UUID) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            tLog(msg: err.localizedDescription)
            return
        } else {
            let str = String(data: characteristic.value!, encoding: .utf8)
            valueLbl.text = str!
        }
    }

}

