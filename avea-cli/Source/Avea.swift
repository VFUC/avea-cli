//
//  Avea.swift
//  Avea
//

import Foundation

class Avea {
	
	var bluetoothManager = BluetoothManager()
	var running = false
	
	private func send(bytes: [UInt8], peripheralUUIDs : [String]? = nil, newPeripheralHandler : ((String) -> Void)? = nil){
		running = true
		let sem = DispatchSemaphore.init(value: 0);
		bluetoothManager.peripheralUUIDs = peripheralUUIDs
		bluetoothManager.newUUIDHandler = { uuid in
			newPeripheralHandler?(uuid)
		}
		
		bluetoothManager.sendBytes(bytes: bytes, completionHandler: {
			sem.signal()
		})
		
		sem.wait()
	}
	
	
	func set(color: Color, peripheralUUIDs : [String]? = nil, newPeripheralHandler : ((String) -> Void)? = nil){
		send(bytes: getBytes(forColor: color), peripheralUUIDs: peripheralUUIDs, newPeripheralHandler: newPeripheralHandler)
	}
	
	func set(brightness: Int, peripheralUUIDs : [String]? = nil, newPeripheralHandler : ((String) -> Void)? = nil){
		send(bytes: getBytes(forBrightness: brightness), peripheralUUIDs: peripheralUUIDs, newPeripheralHandler: newPeripheralHandler)
	}
}





extension Avea { //Byte Juggling
	
	fileprivate func getBytes(forBrightness brightness: Int) -> [UInt8]{
		var bytes = [UInt8]()
		
		let extended = UInt16(brightness * 16)
		
		bytes.append(0x57)
		bytes.append(splitWord(word: extended).1)
		bytes.append(splitWord(word: extended).0)
		
		return bytes
	}
	
	private func splitWord(word: UInt16) -> (UInt8, UInt8) {
		return ( UInt8(word >> 8), UInt8(word & 0xFF) )
	}
	
	private func encodeWhite(color: Int) -> UInt16 {
		return colorEncodeWithPrefix(prefix: 8, color: color)
	}
	
	private func encodeRed(color: Int) -> UInt16 {
		return colorEncodeWithPrefix(prefix: 3, color: color)
	}
	
	private func encodeGreen(color: Int) -> UInt16 {
		return colorEncodeWithPrefix(prefix: 2, color: color)
	}
	
	private func encodeBlue(color: Int) -> UInt16 {
		return colorEncodeWithPrefix(prefix: 1, color: color)
	}
	
	
	private func colorEncodeWithPrefix(prefix: Int, color: Int) -> UInt16 {
		guard (0...255).contains(color) else {
			print("Color value out of range")
			return 0
		}
		
		let extended = color * 16
		let prefixMask = prefix << 4
		
		let lower = (extended >> 8) | prefixMask
		let higher = extended & 0xFF
		
		let ret = (higher << 8) | lower
		
		return UInt16(ret)
	}
	
	
	fileprivate func getBytes(forColor color: Color) -> [UInt8] {
		var bytes = [UInt8]()
		bytes.append(0x35)
		bytes.append(0x32)
		bytes.append(0)
		bytes.append(0x0a)
		bytes.append(0)
		bytes.append(splitWord(word: encodeWhite(color: color.white)).0)
		bytes.append(splitWord(word: encodeWhite(color: color.white)).1)
		bytes.append(splitWord(word: encodeRed(color: color.red)).0)
		bytes.append(splitWord(word: encodeRed(color: color.red)).1)
		bytes.append(splitWord(word: encodeGreen(color: color.green)).0)
		bytes.append(splitWord(word: encodeGreen(color: color.green)).1)
		bytes.append(splitWord(word: encodeBlue(color: color.blue)).0)
		bytes.append(splitWord(word: encodeBlue(color: color.blue)).1)
		
		return bytes
	}
}
