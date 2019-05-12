//
//  CBPeripheral+Workaround.swift
//  avea-cli
//
//  Created by Jonas on 17.03.19.
//

import Foundation
import CoreBluetooth

// MARK: - Taken from https://github.com/Polidea/RxBluetoothKit/issues/157
extension CBPeripheral {
    override open var identifier: UUID {
        get {
            if #available(macOS 10.13, *) {
                return super.identifier
            } else {
                return value(forKey: "identifier") as! NSUUID as UUID
            }
        }
        
        set {
            setValue(newValue, forKey: "identifier")
        }
    }
}
