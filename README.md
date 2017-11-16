# 💡Avea-CLI

A Swift Command Line Interface to interact with [Elgato Avea](https://www.elgato.com/en/smart/avea) light bulbs.

The script currently starts up and looks for the first Bluetooth LE device containing the name "Avea". It then connects and sends the desired bytes to modify the bulb's color or brightness.

The implementation wouldn't be possible without knowing the details of which bytes to send, so kudos to [Marmelatze](https://github.com/Marmelatze/avea_node) for figuring that out.

**Requirements**: macOS, Xcode (command line tools), Swift 3+

<br>

## 🛠 Setup
**Note: Xcode is required to compile the executable**

- Clone the repo

	`$ git clone https://github.com/vfuc/avea-cli`
	<br>
	`$ cd avea-cli`

<br>

- Run the `xcodebuild build` script to compile the binary

	`$ xcodebuild build`

<br>

The binary will be compiled to `build/Release/`
- Run the binary

	`$ build/Release/avea`

<br>
or if you're feeling fancy you can 

- Link the binary to `/usr/local/bin` to be able to run it everywhere: 

	`$ sudo cp build/Release/avea /usr/local/bin/`

<br>

## 🎛 Usage

##### Set the color
The color is set using **red**, **green**, **blue** and **white** values in the range of 0-255 with the `set-color-rgbw` command or its short form `rgbw`. 
 
```sh
$ avea set-color-rgbw [red] [green] [blue] [white]
$ avea rgbw [red] [green] [blue] [white]
```

##### Set the brightness
Color and brightness are set independently of each other as they are two different commands sent to the bulb. Use values in the range of 0-255 with the command `set-brightness` or just `b`.

```sh
$ avea set-brightness [value]
$ avea b [value]
```

##### Turn the bulb off
```sh
$ avea off
```

### Color descriptors
Because I'm too lazy to type out raw values I added color descriptors, they're pretty self-explanatory.
The data is stored as JSON in the `~/.avea/avea-colors.json` file
##### Show available colors
```sh
$ avea show-colors

Available colors: 

[blue] Red: 0, Green: 5, Blue: 255, White: 10
[green] Red: 0, Green: 255, Blue: 0, White: 10
[red] Red: 255, Green: 0, Blue: 0, White: 15
[yellow] Red: 255, Green: 255, Blue: 0, White: 10
[orange] Red: 255, Green: 75, Blue: 0, White: 0
[purple] Red: 200, Green: 0, Blue: 250, White: 0
[pink] Red: 220, Green: 0, Blue: 80, White: 10
[white] Red: 0, Green: 0, Blue: 0, White: 255
[white-warm] Red: 200, Green: 100, Blue: 0, White: 175
[white-cold] Red: 0, Green: 100, Blue: 200, White: 175
[white-pinkish] Red: 100, Green: 0, Blue: 100, White: 200
```

##### Setting color
```sh
$ avea set-color [descriptor]
$ avea c [descriptor]
```

##### Adding color
```sh
$ avea add-color [descriptor] [red] [green] [blue] [white]
```

##### Deleting color
```sh
$ avea delete-color [descriptor]
```
<br>

## 🤔 Caveats
At the moment I only have a single "avea bulb", so I haven't worked on multi-device support yet and don't know if it works with the "sphere" and "flare" products as well.

Occasionally, the bulb is not discoverable and the script will look for it indefinitely. This seems to be an issue with the bulb itself though, as I experience it with the iOS client as well. 

<br>

## 🙋 Contributing
Issues and Pull Requests are welcome, of course :)

I included some basic default colors, but please add to them if there's a cool one you found!
