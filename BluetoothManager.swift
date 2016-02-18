//
//  BluetoothManager.swift
//  Avea
//
//  Created by Jonas on 13/02/16.
//  Copyright © 2016 VFUC. All rights reserved.
//

import Foundation
import CoreBluetooth

private struct Constants {
	static let ColorServiceUUID = "F815E810-456C-6761-746F-4D756E696368"
	static let ColorCharacteristicUUID = "F815E811-456C-6761-746F-4D756E696368"
}


class BluetoothManager: NSObject {
	
	private var centralManager: CBCentralManager? = nil
	private var aveaPeripheral : CBPeripheral? {
		didSet {
			if let avea = aveaPeripheral {
				print("[CentralManager] Connecting to peripheral")
				centralManager?.connectPeripheral(avea, options: nil)
			}
		}
	}
	
	private var bytesToSend : [UInt8]?
	private var completionHandler : (Void -> Void)?
	var peripheralUUIDs : [String]? = nil
	var newUUIDHandler : (String -> Void)?
	
	func sendBytes(bytes: [UInt8], completionHandler : (Void -> Void)? = nil){
		bytesToSend = bytes
		self.completionHandler = completionHandler
		centralManager = CBCentralManager(delegate: self, queue: dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0))
	}
}



extension BluetoothManager : CBCentralManagerDelegate {
	
	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		
		if let name = peripheral.name where name.containsString("Avea"){
			print("[CentralManager] Discovered peripheral \'\(name)\'")
			newUUIDHandler?(peripheral.identifier.UUIDString)
			aveaPeripheral = peripheral
		}
		
	}
	
	
	func centralManagerDidUpdateState(central: CBCentralManager) {
		print("[CentralManager] State: \(central.state)")
		
		if (central.state == CBCentralManagerState.PoweredOn){
			print("[CentralManager] Powered On")
			
			if let uuidStrings = peripheralUUIDs {
				var uuids = [NSUUID]()
				for uuidString in uuidStrings {
					uuids.append(NSUUID(UUIDString: uuidString)!)
				}
				
				let peripherals = centralManager?.retrievePeripheralsWithIdentifiers(uuids)
				if let peripherals = peripherals where peripherals.count > 0 {
					print("[CentralManager] Retrieved peripheral from stored UUIDs")
					aveaPeripheral = peripherals.first!
					
				} else {
					print("[CentralManager] Scanning for peripherals")
					centralManager?.scanForPeripheralsWithServices(nil, options: nil)
				}
				
				
			} else {
				print("[CentralManager] Scanning for peripherals")
				centralManager?.scanForPeripheralsWithServices(nil, options: nil)
			}
		}
	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		print("[CentralManager] Connected to peripheral \(peripheral.name ?? "with unknown name")")
		peripheral.delegate = self
		
		//start looking for services
		peripheral.discoverServices([CBUUID(string: Constants.ColorServiceUUID)])
		print("[CBPeripheral] Looking for color service")
	}
}



extension BluetoothManager : CBPeripheralDelegate {
	
	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
		print("[CBPeripheral] Found service")
		
		
		if let services = peripheral.services {
			for service in services where service.UUID.UUIDString == Constants.ColorServiceUUID {
				peripheral.discoverCharacteristics([CBUUID(string: Constants.ColorCharacteristicUUID)], forService: service)
			}
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
		print("[CBPeripheral] Found characteristic")
		
		guard let characteristics = service.characteristics else {
			print("No characteristics set on service")
			return
		}
		
		for char in characteristics where char.UUID.UUIDString == Constants.ColorCharacteristicUUID {
			
			if let bytes = bytesToSend {
				print("[CBPeripheral] Sending data")
			
				let data = NSData(bytes: bytes, length: bytes.count)
			
				peripheral.writeValue(data, forCharacteristic: char, type: .WithResponse)
			
			}
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
		print("[CBPeripheral] Data sent")
		self.completionHandler?()
	}
}


