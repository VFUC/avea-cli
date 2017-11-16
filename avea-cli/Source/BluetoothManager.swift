//
//  BluetoothManager.swift
//  Avea
//

import Foundation
import CoreBluetooth

private struct Constants {
	static let ColorServiceUUID = "F815E810-456C-6761-746F-4D756E696368"
	static let ColorCharacteristicUUID = "F815E811-456C-6761-746F-4D756E696368"
}

private enum Mode {
	case Write
}




class BluetoothManager: NSObject {
	
	fileprivate var centralManager: CBCentralManager? = nil
	fileprivate var aveaPeripheral : CBPeripheral? {
		didSet {
			if let avea = aveaPeripheral {
				print("[CentralManager] Connecting to peripheral")
				centralManager?.connect(avea, options: nil)
			}
		}
	}
	
	fileprivate var mode: Mode?
	fileprivate var bytesToSend : [UInt8]?
	fileprivate var writeCompletionHandler : (() -> Void)?
	var peripheralUUIDs : [String]? = nil
	var newUUIDHandler : ((String) -> Void)?
	
	func sendBytes(bytes: [UInt8], completionHandler : (() -> Void)? = nil){
		mode = .Write
		bytesToSend = bytes
		writeCompletionHandler = completionHandler
		centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .background))
	}
}



extension BluetoothManager : CBCentralManagerDelegate {
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		
		if let name = peripheral.name, name.contains("Avea"){
			print("[CentralManager] Discovered peripheral \'\(name)\'")
			newUUIDHandler?(peripheral.identifier.uuidString)
			aveaPeripheral = peripheral
		}
		
	}
	
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		print("[CentralManager] State: \(central.state)")

		if (central.state == .poweredOn){
			print("[CentralManager] Powered On")
			
			if let uuidStrings = peripheralUUIDs {
				var uuids = [UUID]()
				for uuidString in uuidStrings {
					uuids.append(UUID(uuidString: uuidString)!)
				}
				
				let peripherals = centralManager?.retrievePeripherals(withIdentifiers: uuids)
				if let peripherals = peripherals, peripherals.count > 0 {
					print("[CentralManager] Retrieved peripheral from stored UUIDs")
					aveaPeripheral = peripherals.first!
					
				} else {
					print("[CentralManager] Scanning for peripherals")
					centralManager?.scanForPeripherals(withServices: nil, options: nil)
				}
				
				
			} else {
				print("[CentralManager] Scanning for peripherals")
				centralManager?.scanForPeripherals(withServices: nil, options: nil)
			}
		}
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		print("[CentralManager] Connected to peripheral \(peripheral.name ?? "with unknown name")")
		peripheral.delegate = self
		
		//start looking for services
		peripheral.discoverServices([CBUUID(string: Constants.ColorServiceUUID)])
		print("[CBPeripheral] Looking for color service")
	}
}



extension BluetoothManager : CBPeripheralDelegate {
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		print("[CBPeripheral] Found service")
		
		
		if let services = peripheral.services {
			for service in services where service.uuid.uuidString == Constants.ColorServiceUUID {
				peripheral.discoverCharacteristics([CBUUID(string: Constants.ColorCharacteristicUUID)], for: service)
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		print("[CBPeripheral] Found characteristic")
		
		guard let characteristics = service.characteristics else {
			print("No characteristics set on service")
			return
		}
		
		guard let mode = mode else {
			print("[Error] Mode not set")
			return
		}
		
		for char in characteristics where char.uuid.uuidString == Constants.ColorCharacteristicUUID {
			
			
			switch mode {
				
			case .Write:
				if let bytes = bytesToSend {
					print("[CBPeripheral] Sending data")
					
					let data = Data(bytes: bytes, count: bytes.count)
					
					peripheral.writeValue(data, for: char, type: .withResponse)
				}
				
			}
			
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		print("[CBPeripheral] Data sent")
		
		
		guard let mode = mode else {
			print("[Error] Mode not set")
			return
		}
		
		switch mode {
			
		case .Write:
			self.writeCompletionHandler?()
			
		}
		
	}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		print("[CBPeripheral] Received data")
	}
}


