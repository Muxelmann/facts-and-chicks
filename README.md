# The (unofficial) Facts and Chicks MenuApp

[![Build Status](https://travis-ci.org/Muxelmann/facts-and-chicks.svg?branch=master)](https://travis-ci.org/Muxelmann/facts-and-chicks)

This menu app obtains a random image from the facts and chicks website and displays the fact (and chick) as a popover. Both source and image can be accessed quickly.

The main reason behind this app was to challenge me with writing Swift **3** code, as well as making a funny little app.

## Preview

![](https://github.com/Muxelmann/facts-and-chicks/raw/master/Supporting/sample.png)

## Build

### Xcode

Install Xcode and open the project `Facts and Chicks.xcodeproj`. Select the required scheme in the top left hand corner and build (`cmd + b`) or run (`cmd + r`). The available schemes are:

- `Facts and Chicks - Debug`
- `Facts and Chicks - Release`

### Terminal

Make sure you install Xcode and the Command Line Tools. Then run:

```
make
```

This will build the app, copy it into the repository's root directory and remove the temporary `build` folder. If you want to keep this folder, i.e. build the release and debug version, issue one of the following commands:

```
make release
make debug
```

