#!/usr/bin/swift

import Foundation

private struct Constants {
    static let aveaDirectoryPath = "~/.avea"
    static let colorDescriptorFile = "avea-colors.json"
    static let peripheralUUIDFile = "avea-uuids.txt"
}

struct ColorDescriptor {
    let title: String
    let color: Color
}


let defaultColors = [
    ColorDescriptor(title: "blue", color: Color(red: 0, green: 5, blue: 255, white: 10)),
    ColorDescriptor(title: "green", color: Color(red: 0, green: 255, blue: 0, white: 10)),
    ColorDescriptor(title: "red", color: Color(red: 255, green: 0, blue: 0, white: 15)),
    ColorDescriptor(title: "yellow", color: Color(red: 255, green: 255, blue: 0, white: 10)),
    ColorDescriptor(title: "orange", color: Color(red: 255, green: 75, blue: 0, white: 0)),
    ColorDescriptor(title: "purple", color: Color(red: 200, green: 0, blue: 250, white: 0)),
    ColorDescriptor(title: "pink", color: Color(red: 220, green: 0, blue: 80, white: 10)),
    ColorDescriptor(title: "white", color: Color(red: 0, green: 0, blue: 0, white: 255)),
    ColorDescriptor(title: "white-warm", color: Color(red: 200, green: 100, blue: 0, white: 175)),
    ColorDescriptor(title: "white-cold", color: Color(red: 0, green: 100, blue: 200, white: 175)),
    ColorDescriptor(title: "white-rose", color: Color(red: 100, green: 0, blue: 100, white: 200))
]

/* FUNCTIONS */

func getColorDescriptorsFromFile() -> [ColorDescriptor]? {
    let directoryPath = NSString(string: Constants.aveaDirectoryPath).expandingTildeInPath
    let filePath = directoryPath.appending("/\(Constants.colorDescriptorFile)")
    
    
    let fileURL = URL(fileURLWithPath: filePath)
    
    do {
        let data = try Data(contentsOf: fileURL)
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        guard let json = jsonObject as? [String : Any] else {
            print("[Error] Can't get json dictionary from JSON object!")
            return nil
        }
        
        guard let results = json["colors"] as? NSArray else {
            print("[Error] Can't get array for dictionary key \'colors\' from JSON")
            return nil
        }
        
        var colorDescriptors = [ColorDescriptor]()
        
        for result in results {
            guard let dict = result as? [String : Any] else {
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
            
            colorDescriptors.append(ColorDescriptor(title: title, color: Color(red: red, green: green, blue: blue, white: white)))
        }
        
        return colorDescriptors
        
    } catch let error {
        print(error)
        return nil
    }
}

func getJSONData(forColorDescriptors colorDescriptors: [ColorDescriptor]) -> Data? {
    var colorDicts = [[String : Any]]()
    
    for colorDescriptor in colorDescriptors {
        var colorDict = [String : Any]()
        colorDict["title"] = colorDescriptor.title
        colorDict["red"] = colorDescriptor.color.red
        colorDict["green"] = colorDescriptor.color.green
        colorDict["blue"] = colorDescriptor.color.blue
        colorDict["white"] = colorDescriptor.color.white
        colorDicts.append(colorDict)
    }
    
    let colorsJSON = [ "colors" : colorDicts ]
    
    var data: Data
    do {
        data = try JSONSerialization.data(withJSONObject: colorsJSON, options: JSONSerialization.WritingOptions())
    } catch let error {
        print("Error converting Colors to JSON - \(error)")
        return nil
    }
    
    return data
}

// Returns true if directory is setup and valid
func setupAveaDirectory() -> Bool {
    let fileManager = FileManager.default
    let directoryPath = NSString(string: Constants.aveaDirectoryPath).expandingTildeInPath
    
    var isDirectory : ObjCBool = false
    
    if fileManager.fileExists(atPath: directoryPath, isDirectory: &isDirectory) {
        if isDirectory.boolValue {
            return true
        } else {
            print("[Error] File exists at specified Avea directory location \'\(directoryPath)\'\nRemove file or change directory path in script.")
            exit(1)
        }
    }	else { // Nothing at path, create directory
        do {
            try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
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
    let fileManager = FileManager.default
    let directoryPath = NSString(string: Constants.aveaDirectoryPath).expandingTildeInPath
    let colorFilePath = directoryPath.appending("/\(Constants.colorDescriptorFile)")
    
    if fileManager.fileExists(atPath: colorFilePath) {
        return !(getColorDescriptorsFromFile() == nil)
    } else { // file doesn't exist, create file
        if fileManager.createFile(atPath: colorFilePath, contents: getJSONData(forColorDescriptors: defaultColors)!, attributes: nil) {
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
    let fileManager = FileManager.default
    let directoryPath = NSString(string: Constants.aveaDirectoryPath).expandingTildeInPath
    let idFilePath = directoryPath.appending("/\(Constants.peripheralUUIDFile)")
    
    if fileManager.fileExists(atPath: idFilePath) {
        return true
    } else { // file doesn't exist, create file
        if fileManager.createFile(atPath: idFilePath, contents: nil, attributes: nil) {
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
    let directoryPath = NSString(string: Constants.aveaDirectoryPath).expandingTildeInPath
    let idFilePath = directoryPath.appending("/\(Constants.peripheralUUIDFile)")
    
    let idFileURL = URL(fileURLWithPath: idFilePath)
    //  else {
    // 	print("[Error] Can't read id file. Make sure \"\(idFilePath)\" exists.")
    // 	return nil
    // }
    
    do {
        let data = try Data(contentsOf: idFileURL)
        guard let dataString = String(data: data, encoding: String.Encoding.utf8) else {
            print("[Error] Can't parse periherpal id file data to String!")
            return nil
        }
        let components = dataString.components(separatedBy: NSCharacterSet.newlines)
        var uuids = Set<String>()
        
        for component in components where !component.isEmpty {
            uuids.insert(component)
        }
        
        return Array(uuids)
        
    } catch let error{
        print(error)
        return nil
    }
}

func writeUUIDsToFile(uuids: [String]) {
    let directoryPath = NSString(string: Constants.aveaDirectoryPath).expandingTildeInPath
    let idFilePath = directoryPath.appending("/\(Constants.peripheralUUIDFile)")
    
    guard let fileHandle = FileHandle(forUpdatingAtPath: idFilePath) else {
        print("[Error] Can't write to peripheral uuid file, exiting")
        exit(1)
    }
    
    var writeString = ""
    for (index,uuid) in uuids.enumerated() {
        if index != 0 {
            writeString.append("\n")
        }
        
        writeString.append(uuid)
    }
    
    guard let data = writeString.data(using: String.Encoding.utf8) else {
        print("[ERROR] Can't get data from peripheral id string, exiting!")
        exit(1)
    }
    
    fileHandle.truncateFile(atOffset: 0) //Delete current file contents
    fileHandle.write(data)
}

func addNewPeripheralUUIDToFile(uuid: String) {
    var ids = Set<String>([uuid])
    
    if let existingIDs = getUUIDSFromFile() {
        ids = ids.union(existingIDs)
    }
    
    print("[main] Stored new peripheral UUID \'\(uuid)\'")
    writeUUIDsToFile(uuids: Array(ids))
}




/* COMMANDS */

// "rgbw", "set-color-rgbw"
func setColorUsingRGBW(){
    guard CommandLine.arguments.count == 6 else	 { // self + command + 4 arguments = 6
        print("[Error] Wrong number of arguments! Needs [red] [green] [blue] [white]")
        exit(1)
    }
    
    guard let red = Int(CommandLine.arguments[2]), (0...255).contains(red) else {
        print("[Error] Red value (\(CommandLine.arguments[2])) is not an Int or out of range (0-255)")
        exit(1)
    }
    
    guard let green  = Int(CommandLine.arguments[3]), (0...255).contains(green) else {
        print("[Error] Green value (\(CommandLine.arguments[3])) is not an Int or out of range (0-255)")
        exit(1)
    }
    
    guard let blue  = Int(CommandLine.arguments[4]), (0...255).contains(blue) else {
        print("[Error] Blue value (\(CommandLine.arguments[4])) is not an Int or out of range (0-255)")
        exit(1)
    }
    
    guard let white = Int(CommandLine.arguments[5]), (0...255).contains(white) else {
        print("[Error] White value (\(CommandLine.arguments[5])) is not an Int or out of range (0-255)")
        exit(1)
    }
    
    print("[setColor] Red: \(red), Green: \(green), Blue: \(blue), White: \(white)")
    Avea().set(color: Color(red: red, green: green, blue: blue, white: white), peripheralUUIDs: getUUIDSFromFile(), newPeripheralHandler: addNewPeripheralUUIDToFile)
}

// "c", "set-color"
func setColorUsingDescriptor(){
    guard CommandLine.arguments.count == 3 else	 { // self + command + 1 arguments = 3
        print("[Error] Wrong number of arguments! See help for usage details")
        exit(1)
    }
    
    let input = CommandLine.arguments[2]
    
    guard let colorDescriptors = getColorDescriptorsFromFile() else {
        print("Colors not loaded, exiting")
        exit(1)
    }
    
    for colorDescriptor in colorDescriptors where colorDescriptor.title == input {
        print("[setColor] \(input) - Red: \(colorDescriptor.color.red), Green: \(colorDescriptor.color.green), Blue: \(colorDescriptor.color.blue), White: \(colorDescriptor.color.white)")
        Avea().set(color: colorDescriptor.color, peripheralUUIDs: getUUIDSFromFile(), newPeripheralHandler: addNewPeripheralUUIDToFile)
        return
    }
    
    print("[Error] Color Descriptor not recognized! Show available colors using \'avea show-colors\'")
}


// "b", "set-brightness"
func setBrightness(){
    guard CommandLine.arguments.count == 3 else	 { // self + command + 1 argument = 3
        print("[Error] Wrong number of arguments! See help for usage details")
        exit(1)
    }
    
    
    guard let brightness = Int(CommandLine.arguments[2]), (0...255).contains(brightness) else {
        print("[Error] Brightness value (\(CommandLine.arguments[2])) is not an Int or out of range (0-255)")
        exit(1)
    }
    
    print("[setBrightness] Setting brightness to \(brightness)/255")
    
    Avea().set(brightness: brightness, peripheralUUIDs: getUUIDSFromFile(), newPeripheralHandler: addNewPeripheralUUIDToFile)
}


// "off"
func turnOff(){
    print("[main] Turning off Avea")
    Avea().set(color: Color(red: 0, green: 0, blue: 0, white: 0), peripheralUUIDs: getUUIDSFromFile(), newPeripheralHandler: addNewPeripheralUUIDToFile)
}

// "show-colors"
func showColorDescriptors(){
    guard let colorDescriptors = getColorDescriptorsFromFile() else {
        print("Colors not loaded, exiting")
        exit(1)
    }
    
    print("Available colors: \n")
    for colorDescriptor in colorDescriptors {
        print("[\(colorDescriptor.title)] Red: \(colorDescriptor.color.red), Green: \(colorDescriptor.color.green), Blue: \(colorDescriptor.color.blue), White: \(colorDescriptor.color.white)")
    }
}

// "add-color"
func addColor(){
    guard CommandLine.arguments.count == 7 else { // self + command + 5 arguments = 7
        print("[Error] Wrong number of arguments! See help for usage details")
        exit(1)
    }
    
    let title = CommandLine.arguments[2]
    
    guard let red = Int(CommandLine.arguments[3]), (0...255).contains(red) else {
        print("[Error] Red value (\(CommandLine.arguments[3])) is not an Int or out of range (0-255)")
        exit(1)
    }
    
    guard let green  = Int(CommandLine.arguments[4]), (0...255).contains(green) else {
        print("[Error] Green value (\(CommandLine.arguments[4])) is not an Int or out of range (0-255)")
        exit(1)
    }
    
    guard let blue  = Int(CommandLine.arguments[5]), (0...255).contains(blue) else {
        print("[Error] Blue value (\(CommandLine.arguments[5])) is not an Int or out of range (0-255)")
        exit(1)
    }
    
    guard let white = Int(CommandLine.arguments[6]), (0...255).contains(white) else {
        print("[Error] White value (\(CommandLine.arguments[6])) is not an Int or out of range (0-255)")
        exit(1)
    }
    
    let addedColorDescriptor = ColorDescriptor(title: title, color: Color(red: red, green: green, blue: blue, white: white))
    
    guard let colorDescriptors = getColorDescriptorsFromFile() else {
        print("[Error] Can't get colors from file, exiting")
        exit(1)
    }
    
    for colorDescriptor in colorDescriptors where colorDescriptor.title == addedColorDescriptor.title {
        print("[Error] Color with name \'\(addedColorDescriptor.title)\' exists already, use \'avea delete-color \(addedColorDescriptor.title)\' to remove it first")
        exit(1)
    }
    
    var newColorDescriptors = colorDescriptors //mutable copy
    newColorDescriptors.append(addedColorDescriptor)
    
    guard let jsonData = getJSONData(forColorDescriptors: newColorDescriptors) else {
        exit(1)
    }
    
    let directoryPath = NSString(string: Constants.aveaDirectoryPath).expandingTildeInPath
    let colorFilePath = directoryPath.appending("/\(Constants.colorDescriptorFile)")
    
    guard let fileHandle = FileHandle(forUpdatingAtPath: colorFilePath) else {
        print("[Error] Can't write to color JSON file, exiting")
        exit(1)
    }
    
    fileHandle.truncateFile(atOffset: 0) //Delete current file contents
    fileHandle.write(jsonData)
    print("[main] \'\(addedColorDescriptor.title)\' added to colors")
}

// "delete-color"
func deleteColor(){
    guard CommandLine.arguments.count == 3 else { // self + command + 1 argument = 3
        print("[Error] Wrong number of arguments! See help for usage details")
        exit(1)
    }
    
    let title = CommandLine.arguments[2]
    
    guard let colorDescriptors = getColorDescriptorsFromFile() else {
        print("[Error] Can't get colors from file, exiting")
        exit(1)
    }
    
    var newColorDescriptors = colorDescriptors //mutable copy
    
    for (index, colorDescriptor) in colorDescriptors.enumerated() where colorDescriptor.title == title {
        newColorDescriptors.remove(at: index)
    }
    
    guard newColorDescriptors.count < colorDescriptors.count else { //no color removed
        print("[Error] No color found with name \'\(title)\', check saved colors using \'avea show-colors\'")
        exit(1)
    }
    
    guard let jsonData = getJSONData(forColorDescriptors: newColorDescriptors) else {
        exit(1)
    }
    
    
    let directoryPath = NSString(string: Constants.aveaDirectoryPath).expandingTildeInPath
    let colorFilePath = directoryPath.appending("/\(Constants.colorDescriptorFile)")
    
    guard let fileHandle = FileHandle(forUpdatingAtPath: colorFilePath) else {
        print("[Error] Can't write to color JSON file, exiting")
        exit(1)
    }
    
    fileHandle.truncateFile(atOffset: 0) //Delete current file contents
    fileHandle.write(jsonData)
    print("[main] \'\(title)\' removed from colors")
}

// "help"
func printHelp() {
    print("Avea-CLI\n")
    
    print("Usage options:\n")
    
    print(" avea rgbw [red] [green] [blue] [white]")
    print(" avea set-color-rgbw [red] [green] [blue] [white]")
    print("\t\tSet color according to red, green, blue and white value in range of 0-255\n")
    
    print(" avea b [brightness]")
    print(" avea set-brightness [brightness]")
    print("\t\t Set brightness of bulb to value in range of 0-255\n")
    
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


guard CommandLine.arguments.count > 1 else {
    printHelp()
    exit(1)
}


switch CommandLine.arguments[1] {
    
case "rgbw", "set-color-rgbw":
    setColorUsingRGBW()
    
case "c", "set-color":
    setColorUsingDescriptor()
    
case "b", "set-brightness":
    setBrightness()
    
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

