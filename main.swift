#!/usr/bin/swift

import Foundation



private struct Constants {
	static let ColorDescriptorFile = "avea-colors.json"	
}

struct Color {
	let title: String
	let red: Int
	let green: Int
	let blue: Int
	let white: Int
}



func printHelp() {
	print("Avea-CLI\n")

	print("Usage options:\n")

	print(" avea rgbw [red] [green] [blue] [white]")
	print(" avea set-color-rgbw [red] [green] [blue] [white]")
	print("\t\tSet color according to red, green, blue and white value in range of 0-255\n")	
	
	print(" avea c [descriptor]")
	print(" avea set-color [descriptor]")
	print("\t\tSet color using color descriptor\n")

	print(" avea show-colors")
	print("\t\t Show all color descriptors\n")

	print(" avea help")
	print("\t\t Show this help\n")


	print("\n\ngithub.com/vfuc/avea-cli")
	print("vfuc.co")
}

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
	Avea().setColor(red: red, green: green, blue: blue, white: white)
}


func getColorsFromFile() -> [Color]? {
	guard let data = NSData(contentsOfFile: Constants.ColorDescriptorFile) else {
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
		Avea().setColor(red: color.red, green: color.green, blue: color.blue, white: color.white)
		return
	}

	print("[Error] Color Descriptor not recognized! Show available colors using \'avea show-colors\'") 
}


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








/* MAIN */



guard Process.arguments.count > 1 else {
	printHelp()
	exit(1)
}


switch Process.arguments[1] {

	case "rgbw", "set-color-rgbw":
		setColorUsingRGBW()
	
	case "c", "set-color":
		setColorUsingDescriptor()
	
	case "show-colors":
		showColorDescriptors()
	
	case "help":
		printHelp()
	
	default:
		print("Argument not recognized! Use avea help for more information")
}

