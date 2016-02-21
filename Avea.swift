//
//  Avea.swift
//  Avea
//
//  Created by Jonas on 13/02/16.
//  Copyright © 2016 VFUC. All rights reserved.

import Foundation

class Avea {
	
	var bluetoothManager = BluetoothManager()
	var running = false
	
	func setColor(color: Color, peripheralUUIDS : [String]? = nil, newPeripheralHandler : (String -> Void)? = nil){
		running = true
		let sem = dispatch_semaphore_create(0);
		bluetoothManager.peripheralUUIDs = peripheralUUIDS
		bluetoothManager.newUUIDHandler = { uuid in
			newPeripheralHandler?(uuid)
		}
		
		bluetoothManager.sendColorBytes(composeArrayWithColor(color), completionHandler: {
			
			dispatch_semaphore_signal(sem)
		})
		
		dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
	}
}


extension Avea {
		
	
	private func bufferFromColorValues(white white: Int, red: Int, green: Int, blue: Int) -> [UInt8]{
		let j = 500
		var color = [UInt8](count: 8, repeatedValue: 0)
		color[0] = UInt8(white * 16)
		color[1] = UInt8((white * 16) << 8 )
		
		return [0x35, UInt8(j & 0xFF), UInt8(j >> 8 & 0xFF), 10, 0]
		
	}
	
	private func splitWord(word: UInt16) -> (UInt8, UInt8) {
		return ( UInt8(word >> 8), UInt8(word & 0xFF) )
	}
	
	private func encodeWhite(color: Int) -> UInt16 {
		return colorEncodeWithPrefix(8, color: color)
	}
	
	private func encodeRed(color: Int) -> UInt16 {
		return colorEncodeWithPrefix(3, color: color)
	}
	
	private func encodeGreen(color: Int) -> UInt16 {
		return colorEncodeWithPrefix(2, color: color)
	}
	
	private func encodeBlue(color: Int) -> UInt16 {
		return colorEncodeWithPrefix(1, color: color)
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
	
	
	private func composeArrayWithColor(color: Color) -> [UInt8] {
		var bytes = [UInt8]()
		bytes.append(0x35)
		bytes.append(0x32)
		bytes.append(0)
		bytes.append(0x0a)
		bytes.append(0)
		bytes.append(splitWord(encodeWhite(color.white)).0)
		bytes.append(splitWord(encodeWhite(color.white)).1)
		bytes.append(splitWord(encodeRed(color.red)).0)
		bytes.append(splitWord(encodeRed(color.red)).1)
		bytes.append(splitWord(encodeGreen(color.green)).0)
		bytes.append(splitWord(encodeGreen(color.green)).1)
		bytes.append(splitWord(encodeBlue(color.blue)).0)
		bytes.append(splitWord(encodeBlue(color.blue)).1)
		
		return bytes
	}
}