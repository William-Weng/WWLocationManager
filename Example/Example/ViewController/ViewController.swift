//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/1/1.
//

import UIKit
import WWPrint
import WWLocationManager

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // [Info.plist => NSLocationWhenInUseUsageDescription](https://medium.com/@merlos/how-to-simulate-locations-in-xcode-b0f7f16e126d)
        WWLocationManager.shared.countryCode { code in
            wwPrint(code)
        } failure: { error in
            wwPrint(error)
        }
    }
}

