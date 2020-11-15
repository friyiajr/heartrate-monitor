//
//  BluetoothLeService.swift
//  HeartRateMonitor
//
//  Created by Daniel Friyia on 2020-11-15.
//

import Foundation
import CoreBluetooth

class BluetoothLeService :
  NSObject,
  CBCentralManagerDelegate,
  CBPeripheralDelegate
{
  ///
  /// Static variable representing the shared singleton for BluetoothLeService
  ///
  static var sharedInstance: BluetoothLeService!
  
  ///
  /// Constant used to make sure the only thing picked up by the BLE Scan
  /// is heart rate monitors
  ///
  let heartRateServiceCBUUID = CBUUID(string: "0x180D")
  
  ///
  /// The central manger provided by the Apple Bluetooth Service
  ///
  var centralManager: CBCentralManager!
  
  ///
  /// Peripheral representation of Elite HRV Heart Rate Monitor
  ///
  var eliteHrvHeartRateMonitor: CBPeripheral!
  
  ///
  /// Map representation of all HRV sensors found during the scan
  ///
  var hrvSensors: [[String:CBPeripheral]]!
  
  ///
  /// Default initializer
  ///
  override init() {
    super.init()
    self.centralManager = CBCentralManager(delegate: self, queue: nil)
    self.hrvSensors = [[String:CBPeripheral]]()
  }
  
  ///
  /// The current state of the hardware Bluetooth manager
  ///
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .unknown:
      print("central.state is .unknown")
    case .resetting:
      print("central.state is .resetting")
    case .unsupported:
      print("central.state is .unsupported")
    case .unauthorized:
      print("central.state is .unauthorized")
    case .poweredOff:
      print("central.state is .poweredOff")
    case .poweredOn:
      print("central.state is .poweredOn")
    @unknown default:
      print("central.state is default")
    }
  }
  
  ///
  /// Delgate method with information describing the connection
  /// status of a peripheral
  ///
  func centralManager(
    _ central: CBCentralManager,
    didConnect peripheral: CBPeripheral
  ) {
    print("Connected")
  }
  
  ///
  /// Method used to scan for EliteHRV Devices
  ///
  func scanForPeripherals() {
    // Remove any previous HRV sensors (If Applicable)
    hrvSensors = [[String:CBPeripheral]]()
    
    // Start scanning for sensors
    centralManager.scanForPeripherals(
      withServices: [heartRateServiceCBUUID]
    )
  }
  
  ///
  /// Method to stop scanning for heart rate monitors
  ///
  func stopScanningForPeripherals() {
    centralManager.stopScan()
  }
  
  ///
  /// Method for connecting to a Bluetooth Peripheral
  ///
  func connectToEliteHrvDevice(peripheral: CBPeripheral) {
    centralManager.connect(peripheral)
  }
  
  ///
  /// Delegate method called every time a device is discovered
  ///
  func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String : Any],
    rssi RSSI: NSNumber
  ) {
    // Add all discovered devices to a HashMap
    let hrvSensor = [peripheral.name ?? "HRV_SENSOR": peripheral]
    hrvSensors.append(hrvSensor)
  }
  
  
  public static let shared: BluetoothLeService = {
    if sharedInstance == nil {
      sharedInstance = BluetoothLeService()
    }
    return sharedInstance
  }()
}
