# ASEPalette

An Adobe .ase (Adobe Swatch Exchange File) file reader/writer for Swift (macOS, iOS, tvOS, macCatalyst)

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/ASEPalette" />
    <img src="https://img.shields.io/badge/macOS-10.13+-red" />
    <img src="https://img.shields.io/badge/iOS-13+-blue" />
    <img src="https://img.shields.io/badge/tvOS-13+-orange" />
    <img src="https://img.shields.io/badge/macCatalyst-2+-purple" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.4-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

## Why?

I wanted to be able to read and write `.ase` files in Swift.

The `.ase` file format is not formally defined, however there are a number of deconstructions available on the web.
I used the breakdown of the format defined [here](http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase).

## API

| Type          | Description   | 
|:--------------|:---------------|
|`ASE.Palette`  | The full representation of the ASE palette file |
|`ASE.Group`    | An optionally named collection of colors |
|`ASE.Color`    | An optionally named color |

## Tasks

### Load an ASE file

```swift
do {
   let aseFileURL = URL(fileURL: ...)
   let palette = try ASE.Palette(fileURL: aseFileURL)
   
   // do something with 'palette'
}
catch {
   // Do something with 'error'
}
```

### Generate an ASE binary representation

```swift
do {
   // Build a palette
   var palette = ASE.Palette()
   let c1 = try ASE.Color(name: "red", model: ASE.ColorModel.RGB, colorComponents: [1, 0, 0])
   let c2 = try ASE.Color(name: "green", model: ASE.ColorModel.RGB, colorComponents: [0, 1, 0])
   let c3 = try ASE.Color(name: "blue", model: ASE.ColorModel.RGB, colorComponents: [0, 0, 1])
   palette.colors.append(contentsOf: [c1, c2, c3])

   // Get the .ase format data
   let rawData = try palette.data()
   
   // Do something with 'rawData' like write to a file for example
}
catch {
   // Do something with 'error'
}
```

## QuickLook support (macOS 12+ only)

This package also includes a Quicklook Plugin for .ase files. macOS 12 has changed the was quicklook plugins work, by creating an .appex extension (which is the quicklook plugin) embedded within an application.

In the `Quicklook` subfolder you'll find an `xcodeproj` which you can use to build the application `Palette Viewer` which contains the QuickLook plugin.

For the plugin to register, you need to run the application. After the first run the QuickLook plugin will be registered.

## License

MIT. Use it for anything you want, just attribute my work if you do. Let me know if you do use it somewhere, I'd love to hear about it!

```
MIT License

Copyright (c) 2022 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
