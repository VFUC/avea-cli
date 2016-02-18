#!/usr/bin/swift

import Foundation



private struct Constants {
	static let AveaDirectoryPath = "~/.avea"
	static let ColorDescriptorFile = "avea-colors.json"
	static let PeripheralUUIDFile = "avea-uuids.txt"
}

struct Color {
	let title: String
	let red: Int
	let green: Int
	let blue: Int
	let white: Int
}

let defaultColors = [
	Color(title: "blue", red: 0, green: 30, blue: 255, white: 30),
	Color(title: "green", red: 0, green: 255, blue: 0, white: 30)
]

/* FUNCTIONS */

func getColorsFromFile() -> [Color]? {
	let directoryPath = NSString(string: Constants.AveaDirectoryPath).stringByExpandingTildeInPath
	let filePath = directoryPath.stringByAppendingString("/\(Constants.ColorDescriptorFile)")

	guard let data = NSData(contentsOfFile: filePath) else {
		print("[Error] Can't read colors from file! Make sure \"\(Constants.ColorDescriptorFile)\" exists and is valid JSON.")
		return nil
	}
	
	do {
		let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)		
		guard let results = json["colors"] as? NSArray else {
			print("[Error] Can't get array for dictionary key \'colors\' from JSON")
			return nil
		}

		var colors = [Color]()
		
		for result in results {
			guard let dict = result as? NSDictionary else {
				print("[Error] Can't get color dictionary from JSON file")
				return nil
			}
			
			guard let title = dict["title"] as? String else {
				print("[Error] Error retrieving color title from JSON file")
				return nil
			}	
			
			guard let red = dict["red"] as? Int,
				let green = dict["green"] as? Int,
				let blue = dict["blue"] as? Int,
				let white = dict["white"] as? Int else {
				print("[Error] Can't parse color values for color with title \'\(title)\'")
				return nil
			}			

			colors.append(Color(title: title, red: red, green: green, blue: blue, white: white))
		}
		
		return colors	

	} catch let error {
		print(error)
		return nil
	}
}

func getJSONDataForColors(colors: [Color]) -> NSData? {
	var colorDicts = [[String : AnyObject]]()
	
	for color in colors {
		var colorDict = [String : AnyObject]()
		colorDict["title"] = color.title
		colorDict["red"] = color.red
		colorDict["green"] = color.green
		colorDict["blue"] = color.blue
		colorDict["white"] = color.white
		colorDicts.append(colorDict)
	}

	let colorsJSON = [ "colors" : colorDicts ]

	var data: NSData
	do {
		data = try NSJSONSerialization.dataWithJSONObject(colorsJSON, options: NSJSONWritingOptions())
	} catch let error {
		print("Error converting Colors to JSON - \(error)")
		return nil
	}

	return data
}

// Returns true if directory is setup and valid
func setupAveaDirectory() -> Bool {
	let fileManager = NSFileManager.defaultManager()
	let directoryPath = NSString(string: Constants.AveaDirectoryPath).stringByExpandingTildeInPath

	var isDirectory : ObjCBool = false

	if fileManager.fileExistsAtPath(directoryPath, isDirectory: &isDirectory) {
		if isDirectory {
			return true
		} else {
			print("[Error] File exists at specified Avea directory location \'\(directoryPath)\'\nRemove file or change directory path in script.")
			exit(1)
		}
	}	else { // Nothing at path, create directory
		do {
			try fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
			print("[main] Created Avea directory at path \'\(directoryPath)\'")
			return true
		} catch let error {
			print("Error creating Avea directory: \(error)")
			exit(1)
		}
	}
}

// Returns true if color file exists and JSON parseable / has been created
func setUpColorFile() -> Bool {
	let fileManager = NSFileManager.defaultManager()
	let directoryPath = NSString(string: Constants.AveaDirectoryPath).stringByExpandingTildeInPath
	let colorFilePath = directoryPath.stringByAppendingString("/\(Constants.ColorDescriptorFile)")

	if fileManager.fileExistsAtPath(colorFilePath) {
		return !(getColorsFromFile() == nil)
	} else { // file doesn't exist, create file
		if fileManager.createFileAtPath(colorFilePath, contents: getJSONDataForColors(defaultColors)!, attributes: nil) {
			print("[main] Created color file \'\(colorFilePath)\'")
			return true
		} else {
			print("Couldn't create avea color file at path \'\(colorFilePath)\'")
			exit(1)
		}
	}
}

// Returns true if periheral id file exists/has been created
func setUpPeripheralUUIDFile() -> Bool {
	let fileManager = NSFileManager.defaultManager()
	let directoryPath = NSString(string: Constants.AveaDirectoryPath).stringByExpandingTildeInPath
	let idFilePath = directoryPath.stringByAppendingString("/\(Constants.PeripheralUUIDFile)")

	if fileManager.fileExistsAtPath(idFilePath) {
		return true
	} else { // file doesn't exist, create file
		if fileManager.createFileAtPath(idFilePath, contents: nil, attributes: nil) {
			print("[main] Created peripheral ID file \'\(idFilePath)\'")
			return true
		} else {
			print("Couldn't create peripheral ID file at path \'\(idFilePath)\'")
			exit(1)
		}
	}
}


func setupAveaFiles() -> Bool {
	return setUpColorFile() && setUpPeripheralUUIDFile()
}


func getUUIDSFromFile() -> [String]? {
	let directoryPath = NSString(string: Constants.AveaDirectoryPath).stringByExpandingTildeInPath
	let idFilePath = directoryPath.stringByAppendingString("/\(Constants.PeripheralUUIDFile)")
	
	guard let data = NSData(contentsOfFile: idFilePath) else {
		print("[Error] Can't read peripheral ids from id file! Make sure \"\(idFilePath)\" exists")
		return nil
	}
	
	guard let dataString = String(data: data, encoding: NSUTF8StringEncoding) else {
		print("[Error] Can't parse periherpal id file data to String!")
		return nil
	}
	let components = dataString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
	var uuids = [String]()
	
	for component in components where component.characters.count > 0 {
		uuids.append(component)
	}
	
	return uuids
}

func writeUUIDsToFile(uuids: [String]) {
	let directoryPath = NSString(string: Constants.AveaDirectoryPath).stringByExpandingTildeInPath
	let idFilePath = directoryPath.stringByAppendingString("/\(Constants.PeripheralUUIDFile)")

	guard let fileHandle = NSFileHandle(forUpdatingAtPath: idFilePath) else {
		print("[Error] Can't write to peripheral uuid file, exiting")
		exit(1)
	}

	var writeString = ""
	for (index,uuid) in uuids.enumerate() {
		if index != 0 {
			writeString.appendContentsOf("\n")
		}

		writeString.appendContentsOf(uuid)
	}

	guard let data = writeString.dataUsingEncoding(NSUTF8StringEncoding) else {
		print("[ERROR] Can't get data from peripheral id string, exiting!")
		exit(1)
	}

	fileHandle.truncateFileAtOffset(0) //Delete current file contents 
	fileHandle.writeData(data)
}

func addNewPeripheralUUIDToFile(uuid: String) {
	var ids = [uuid]
	
	if let existingIDs = getUUIDSFromFile() {
		ids.appendContentsOf(existingIDs)
	}
	
	print("[main] Stored new peripheral UUID \'\(uuid)\'")
	writeUUIDsToFile(ids)
}




/* COMMANDS */

// "rgbw", "set-color-rgbw"
func setColorUsingRGBW(){
	guard Process.arguments.count == 6 else	 { // self + command + 4 arguments = 6
		print("[Error] Wrong number of arguments! Needs [red] [green] [blue] [white]")
		exit(1)
	}

	guard let red = Int(Process.arguments[2]) where (0...255).contains(red) else {
		print("[Error] Red value (\(Process.arguments[2])) is not an Int or out of range (0-255)")
		exit(1)
	}
	
	guard let green  = Int(Process.arguments[3]) where (0...255).contains(green) else {
		print("[Error] Green value (\(Process.arguments[3])) is not an Int or out of range (0-255)")
		exit(1)
	}
	
	guard let blue  = Int(Process.arguments[4]) where (0...255).contains(blue) else {
		print("[Error] Blue value (\(Process.arguments[4])) is not an Int or out of range (0-255)")
		exit(1)
	}
	
	guard let white = Int(Process.arguments[5]) where (0...255).contains(white) else {
		print("[Error] White value (\(Process.arguments[5])) is not an Int or out of range (0-255)")
		exit(1)
	}
	
	print("[setColor] Red: \(red), Green: \(green), Blue: \(blue), White: \(white)")
	Avea().setColor(red: red, green: green, blue: blue, white: white, peripheralUUIDS: getUUIDSFromFile(), newPeripheralHandler: addNewPeripheralUUIDToFile)
}

// "c", "set-color"
func setColorUsingDescriptor(){
	guard Process.arguments.count == 3 else	 { // self + command + 1 arguments = 3
		print("[Error] Wrong number of arguments! See help for usage details")
		exit(1)
	}
	
	let input = Process.arguments[2]

	guard let colors = getColorsFromFile() else {
		print("Colors not loaded, exiting")
		exit(1)
	}

	for color in colors where color.title == input {
		print("[setColor] \(input) - Red: \(color.red), Green: \(color.green), Blue: \(color.blue), White: \(color.white)")		
		Avea().setColor(red: color.red, green: color.green, blue: color.blue, white: color.white, peripheralUUIDS: getUUIDSFromFile(), newPeripheralHandler: addNewPeripheralUUIDToFile)
		return
	}

	print("[Error] Color Descriptor not recognized! Show available colors using \'avea show-colors\'") 
}

// "off"
func turnOff(){
	print("[main] Turning off Avea")
	Avea().setColor(red: 0, green: 0, blue: 0, white: 0, peripheralUUIDS: getUUIDSFromFile(), newPeripheralHandler: addNewPeripheralUUIDToFile)
}

// "show-colors"
func showColorDescriptors(){
	guard let colors = getColorsFromFile() else {
		print("Colors not loaded, exiting")
		exit(1)
	}

	print("Available colors: \n")
	for color in colors {
		print("[\(color.title)] Red: \(color.red), Green: \(color.green), Blue: \(color.blue), White: \(color.white)")
	}
}

// "add-color"
func addColor(){
	guard Process.arguments.count == 7 else { // self + command + 5 arguments = 7
		print("[Error] Wrong number of arguments! See help for usage details")
		exit(1)
	}

	let title = Process.arguments[2]	
	
	guard let red = Int(Process.arguments[3]) where (0...255).contains(red) else {
		print("[Error] Red value (\(Process.arguments[3])) is not an Int or out of range (0-255)")
		exit(1)
	}
	
	guard let green  = Int(Process.arguments[4]) where (0...255).contains(green) else {
		print("[Error] Green value (\(Process.arguments[4])) is not an Int or out of range (0-255)")
		exit(1)
	}
	
	guard let blue  = Int(Process.arguments[5]) where (0...255).contains(blue) else {
		print("[Error] Blue value (\(Process.arguments[5])) is not an Int or out of range (0-255)")
		exit(1)
	}
	
	guard let white = Int(Process.arguments[6]) where (0...255).contains(white) else {
		print("[Error] White value (\(Process.arguments[6])) is not an Int or out of range (0-255)")
		exit(1)
	}
	
	let addedColor = Color(title: title, red: red, green: green, blue: blue, white: white)
	
	guard let colors = getColorsFromFile() else {
		print("[Error] Can't get colors from file, exiting")
		exit(1)
	}

	for color in colors where color.title == addedColor.title {
		print("[Error] Color with name \'\(addedColor.title)\' exists already, use \'avea delete-color \(addedColor.title)\' to remove it first")
		exit(1)
	}
	
	var newColors = colors //mutable copy
	newColors.append(addedColor)

	guard let jsonData = getJSONDataForColors(newColors) else {
		exit(1)
	}

	let directoryPath = NSString(string: Constants.AveaDirectoryPath).stringByExpandingTildeInPath
	let colorFilePath = directoryPath.stringByAppendingString("/\(Constants.ColorDescriptorFile)")
	
	guard let fileHandle = NSFileHandle(forUpdatingAtPath: colorFilePath) else {
		print("[Error] Can't write to color JSON file, exiting")
		exit(1)
	}

	fileHandle.truncateFileAtOffset(0) //Delete current file contents 
	fileHandle.writeData(jsonData)
	print("[main] \'\(addedColor.title)\' added to colors")
}

// "delete-color"
func deleteColor(){
	guard Process.arguments.count == 3 else { // self + command + 1 argument = 3
		print("[Error] Wrong number of arguments! See help for usage details")
		exit(1)
	}

	let title = Process.arguments[2]

	guard let colors = getColorsFromFile() else {
		print("[Error] Can't get colors from file, exiting")
		exit(1)
	}

	var newColors = colors //mutable copy

	for (index, color) in colors.enumerate() where color.title == title {
		newColors.removeAtIndex(index)
	}

	guard newColors.count < colors.count else { //no color removed
		print("[Error] No color found with name \'\(title)\', check saved colors using \'avea show-colors\'")
		exit(1)
	}

	guard let jsonData = getJSONDataForColors(newColors) else {
		exit(1)
	}
	

	let directoryPath = NSString(string: Constants.AveaDirectoryPath).stringByExpandingTildeInPath
	let colorFilePath = directoryPath.stringByAppendingString("/\(Constants.ColorDescriptorFile)")

	guard let fileHandle = NSFileHandle(forUpdatingAtPath: colorFilePath) else {
		print("[Error] Can't write to color JSON file, exiting")
		exit(1)
	}

	fileHandle.truncateFileAtOffset(0) //Delete current file contents 
	fileHandle.writeData(jsonData)
	print("[main] \'\(title)\' removed from colors")
}

// "help"
func printHelp() {
	print("Avea-CLI\n")

	print("Usage options:\n")

	print(" avea rgbw [red] [green] [blue] [white]")
	print(" avea set-color-rgbw [red] [green] [blue] [white]")
	print("\t\tSet color according to red, green, blue and white value in range of 0-255\n")	

	print(" avea off")
	print("\t\t Turn avea off\n")
	
	print(" avea c [descriptor]")
	print(" avea set-color [descriptor]")
	print("\t\tSet color using color descriptor\n")

	print(" avea show-colors")
	print("\t\t Show all color descriptors\n")

	print(" avea add-color [name] [red] [green] [blue] [white]")
	print("\t\t Add color descriptor with associated RGBW values\n")

	print(" avea delete-color [name]")
	print("\t\t Delete a color descriptor\n")

	print(" avea help")
	print("\t\t Show this help\n")

	print("\n\ngithub.com/vfuc/avea-cli")
	print("vfuc.co")
}






/* MAIN */

guard setupAveaDirectory() else {
	print("[Error] Avea directory not setup correctly, exiting.")
	exit(1)
}

guard setupAveaFiles() else {
	print("[Error] Avea files not setup correctly, exiting.")
	exit(1)
}



guard Process.arguments.count > 1 else {
	printHelp()
	exit(1)
}


switch Process.arguments[1] {

	case "rgbw", "set-color-rgbw":
		setColorUsingRGBW()
	
	case "c", "set-color":
		setColorUsingDescriptor()

	case "off":
		turnOff()
	
	case "show-colors":
		showColorDescriptors()
	
	case "add-color":
		addColor()

	case "delete-color":
		deleteColor()
		
	case "help":
		printHelp()
	
	default:
		print("Argument not recognized! Use avea help for more information")
}

