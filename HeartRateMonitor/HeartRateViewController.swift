//
//  HeartRateViewController.swift
//  HeartRateMonitor
//
//  Created by Daniel Friyia on 2020-11-15.
//

import UIKit

class HeartRateViewController: UIViewController {
  
  
  @IBOutlet weak var labelHeartRate: UITextField!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      // Continuously polls for the heart rate and updates
      // the UI. A better way to do this would be using a library
      // like RX Swift. This seemed very heavyweight though for
      // a two screen application
      Timer.scheduledTimer(
        withTimeInterval: 0.5,
        repeats: true
      ) { timer in
        self.labelHeartRate.text = "\(BluetoothLeService.shared.bpm)"
      }
    }
}
