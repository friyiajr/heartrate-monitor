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
  private static var _sharedInstance: BluetoothLeService!
  
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
  /// Constant representing the heard rate characteristic service
  ///
  let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
  
  ///
  /// Default initializer
  ///
  override init() {
    super.init()
    self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
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
    eliteHrvHeartRateMonitor.delegate = self
    eliteHrvHeartRateMonitor
      .discoverServices([heartRateServiceCBUUID])
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
    eliteHrvHeartRateMonitor = peripheral
    centralManager.connect(peripheral)
  }
  
  ///
  /// Delegate method that discovers all relevant services on the Heart Rate
  /// peripheral
  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverServices error: Error?
  ) {
    guard let services = peripheral.services else { return }

    for service in services {
      eliteHrvHeartRateMonitor.discoverCharacteristics(nil, for: service)
    }
  }
  
  ///
  /// Delegate method that discovers all characteristics available to the
  /// programmer and connects to them
  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverCharacteristicsFor service: CBService,
    error: Error?
  ) {
    guard let characteristics = service.characteristics else { return }

    for characteristic in characteristics {
      if characteristic.properties.contains(.notify) {
        print("\(characteristic.uuid): properties contains .notify")
        peripheral.setNotifyValue(true, for: characteristic)
      }
    }
  }
  
  ///
  /// Delegate method called when the heart rate monitor sends data to the
  /// phone
  ///
  func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor characteristic: CBCharacteristic,
    error: Error?
  ) {
    switch characteristic.uuid {
    case heartRateMeasurementCharacteristicCBUUID:
      let bpm = heartRate(from: characteristic)
      print(bpm)
    default:
      print("Unhandled Characteristic UUID: \(characteristic.uuid)")
    }
  }
  
  ///
  /// This method parses the user's heart rate in BPM and returns it as an integer. The heart rate
  /// mesurement is in the 2nd, or in the 2nd and 3rd bytes
  ///
  private func heartRate(from characteristic: CBCharacteristic) -> Int {
    print("Hello 3")
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)

    let firstBitValue = byteArray[0] & 0x01
    if firstBitValue == 0 {
      return Int(byteArray[1])
    } else {
      return (Int(byteArray[1]) << 8) + Int(byteArray[2])
    }
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
  
  ///
  /// Singelton Shared instance of the Bluetooth LE Service
  ///
  public static let shared: BluetoothLeService = {
    if _sharedInstance == nil {
      _sharedInstance = BluetoothLeService()
    }
    return _sharedInstance
  }()
}
