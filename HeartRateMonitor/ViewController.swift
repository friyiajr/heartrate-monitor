//
//  ViewController.swift
//  HeartRateMonitor
//
//  Created by Daniel Friyia on 2020-11-15.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  @IBAction func scanForSensors(_ sender: Any) {
    var runCount = 0
    // Start Scanning for HRV Sensors
    BluetoothLeService.shared.scanForPeripherals()
    
    // After 3 Seconds stop scanning and populate
    // the results in the UI
    Timer.scheduledTimer(
      withTimeInterval: 3.0,
      repeats: true
    ) { timer in
        runCount += 1
        if runCount == 3 {
            BluetoothLeService
              .shared
              .stopScanningForPeripherals()
            self.tableView.reloadData()
            timer.invalidate()
        }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return BluetoothLeService.shared.hrvSensors.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell

    cell.textLabel?.text = BluetoothLeService.shared.hrvSensors[indexPath.row].keys.first

    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print(BluetoothLeService.shared.hrvSensors[indexPath.row].keys.first!)
  }
}

