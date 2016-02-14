#!/usr/bin/swift

import Foundation

func printHelp() {
	print("Avea-CLI\n")

	print("Usage options:\n")

	print(" rgbw [red] [green] [blue] [white]")
	print(" set-color-rgbw [red] [green] [blue] [white]")
	print("\t\tSet color according to red, green, blue and white value in range of 0-255\n")	
	
	print(" c [descriptor]")
	print(" set-color [descriptor]")
	print("\t\tSet color using color descriptor\n")

	print(" show-colors")
	print("\t\t Show all color descriptors\n")

	print(" help")
	print("\t\t Show this help\n")


	print("\n\ngithub.com/vfuc/avea-cli")
	print("vfuc.co")
}

func setColorRGBW(){
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

	Avea().setColor(red: red, green: green, blue: blue, white: white)
}





/* MAIN */

//let avea = Avea()
//avea.setColor(red: 100, green: 100, blue: 100, white: 100)

guard Process.arguments.count > 1 else {
	printHelp()
	exit(1)
}


switch Process.arguments[1] {

	case "rgbw", "set-color-rgbw":
		setColorRGBW()
	
	case "help":
		printHelp()
	
	default:
		print("Argument not recognized! Use -help for more information")
}

