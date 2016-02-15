# 💡Avea-CLI

A Swift Command Line Interface to interact with [Elgato Avea](https://www.elgato.com/en/smart/avea) light bulbs.

The script currently starts up and looks for the first Bluetooth LE device containing the name "Avea". It then connects and sends the desired bytes to set the color.

At the moment I only have a single "avea bulb", so I haven't worked on multi-device support yet and don't know if it works with the "sphere" and "flare" products as well.

The implementation wouldn't be possible without knowing the details of which bytes to send, so big ass hat tip to [Marmelatze](https://github.com/Marmelatze/avea_node) for figuring that out.


## 🛠 Setup
** XCode is required to compile the executable **

- Clone the repo

`$ git clone https://github.com/vfuc/avea-cli`

<br>

- Run the `build.sh` script to compile the binary

`$ avea-cli ./build.sh`


<br>
If you're feeling crazy you can 
- Copy it to `/usr/local/bin` to be able to run it everywhere : 

`$ sudo cp avea /usr/local/bin`

## 🎛 Usage

##### Setting the color
The color is set using **red**, **green**, **blue** and **white** values in the range of 0-255 with the `set-color-rgbw` command or its short form `rgbw`. 
 
```sh
$ avea set-color-rgbw [red] [green] [blue] [white]
$ avea rgbw [red] [green] [blue] [white]
```

##### Turn the bulb off
```sh
$ avea off
```

### Color descriptors
Because I'm too lazy to type out raw values I added color descriptors, they're pretty self-explanatory.
The data is stored as JSON in the `avea-colors.json` file
##### Show available colors
```sh
$ avea show-colors

Available colors: 

[blue] Red: 0, Green: 0, Blue: 255, White: 30
[green] Red: 0, Green: 255, Blue: 0, White: 30
[red] Red: 255, Green: 0, Blue: 0, White: 30
[yellow] Red: 235, Green: 0, Blue: 0, White: 200
[white] Red: 0, Green: 0, Blue: 0, White: 255
[warm-white] Red: 255, Green: 80, Blue: 0, White: 220
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



## 🙋 Contributing
Issues and Pull Requests are welcome, of course :)
