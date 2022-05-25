# ColorPaletteCodable

A palette reader/editor/writer package for iOS, macOS, macCatalyst, tvOS, watchOS and Linux.

Supports the following color palette formats

* Adobe Swatch Exchange (.ase)
* Adobe Photoshop Color Swatch (.aco)
* NSColorList (.clr) *(macOS only)* 
* RGB text files (.rgb)
* RGBA text files (.rgba)
* GIMP palette files (.gpl)
* JSON encoded color files (.jsoncolorpalette) *ColorPaletteCodable internal file format*

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/ColorPaletteCodable" />
    <img src="https://img.shields.io/badge/macOS-10.13+-red" />
    <img src="https://img.shields.io/badge/macCatalyst-2+-purple" />
    <img src="https://img.shields.io/badge/iOS-13+-blue" />
    <img src="https://img.shields.io/badge/tvOS-13+-orange" />
    <img src="https://img.shields.io/badge/watchOS-4+-yellow" />
    <img src="https://img.shields.io/badge/Linux-compatible-orange" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.3-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

## Why?

I wanted to be able to read and write `.ase` files in Swift. This was extended to Adobe Photoshop Color Swatch files `.aco`.

The `.ase` file format is not formally defined, however there are a number of deconstructions available on the web.
I used the breakdown of the format defined [here](http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase).

The `.aco` file format is defined [here](https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#50577411_pgfId-1070626).

## API

| Type          | Description    | 
|:--------------|:---------------|
|`PAL.Palette`  | The full representation of a palette     |
|`PAL.Group`    | An optionally named collection of colors |
|`PAL.Color`    | An optionally named color                |

### Coders

| Type             | Description                              |
|:-----------------|:-----------------------------------------|
|`PAL.Coder.ASE`   | Adobe Swatch Exchange (.ase)             |
|`PAL.Coder.ACO`   | Adobe Photoshop Color Swatch (.aco)      |
|`PAL.Coder.CLR`   | NSColorList (.clr) *(macOS only)*        |
|`PAL.Coder.RGB`   | RGB text files (.rgb)                    |
|`PAL.Coder.RGBA`  | RGB(A) text files (.rgba)                |
|`PAL.Coder.GIMP`  | GIMP palette files (.gpl)                |
|`PAL.Coder.JSON`  | JSON encoded palette (.jsoncolorpalette) |

## Tasks

### Decode a palette file

```swift
do {
   let myFileURL = URL(fileURL: ...)
   let palette = try PAL.Palette.Decode(from: myFileURL)
   
   // do something with 'palette'
}
catch {
   // Do something with 'error'
}
```

### Build a palette and generate an ASE binary representation

```swift
do {
   // Build a palette
   var palette = PAL.Palette()
   let c1 = try PAL.Color.rgb(name: "red",   1, 0, 0)
   let c2 = try PAL.Color.rgb(name: "green", 0, 1, 0)
   let c3 = try PAL.Color.rgb(name: "blue",  0, 0, 1)
   palette.colors.append(contentsOf: [c1, c2, c3])

   // Create an ASE coder
   let coder = PAL.Coder.ASE()

   // Get the .ase format data
   let rawData = try coder.encode(palette)
   
   // Do something with 'rawData' (like write to a file for example)
}
catch {
   // Do something with 'error'
}
```

### Read an ACO file, write an ASE file

```swift
do {
   let acoFileURL = URL(fileURL: ...)
   let coder = PAL.Coder.ACO()
   var palette = try coder.decode(from: acoFileURL)
   
   // do something with 'palette'
   
   // re-encode the palette to an ASE format
   let encoder = PAL.Coder.ASE()
   let rawData = try encoder.encode(palette) 
}
catch {
   // Do something with 'error'
}
```

## QuickLook support (macOS 12+ only)

This package also includes a Quicklook Plugin for palette files. macOS 12 has changed the was quicklook plugins work, by creating an .appex extension (which is the quicklook plugin) embedded within an application.

In the `Quicklook` subfolder you'll find an `xcodeproj` which you can use to build the application `Palette Viewer` which contains the QuickLook plugin.

For the plugin to register, you need to run the application. After the first run the QuickLook plugin will be registered.

## Palette viewer

Palette Viewer allows you to view the contents of

* Adobe Swatch Exchange files (.ase)
* Adobe Photoshop Color Swatch files (.aco)
* Apple ColorList files (.clr)
* RGB/RGBA hex encoded text files (.txt)

You can drag colors out of the preview window into applications that support dropping of `NSColor` instances.

You can also save the palette to a new format (eg. saving a gimp `.gpl` format to an Adobe `.aco` format)

## Palette format encoding/decoding limitations

|                   | File Type              | Named<br>Colors? | Named<br>palette? | Color<br>Groups? | ColorType<br>Support? | Supports<br>Colorspaces? |
|-------------------|------------------------|:----------------:|:-----------------:|:----------------:|:---------------------:|:------------------------:|
| `PAL.Coder.JSON`  | JSON Text              |         ✅        |         ✅         |         ✅        |           ✅           |             ✅            |
| `PAL.Coder.ASE`   | Binary                 |         ✅        |         ❌         |         ✅        |           ✅           |             ✅            |
| `PAL.Coder.ACO`   | Binary                 |         ✅        |         ❌         |         ❌        |           ❌           |             ✅            |
| `PAL.Coder.RGB/A` | Text                   |         ✅        |         ❌         |         ❌        |           ❌           |         RGB only         |
| `PAL.Coder.GIMP`  | Text                   |         ✅        |         ✅         |         ❌        |           ❌           |         RGB only         |
| `PAL.Coder.CLR`   | Binary<br>(macOS only) |         ✅        |         ❌         |         ❌        |           ❌           |             ✅            |

*(A ColorType represents the type of color (global/spot/normal))*

## Linux caveats

* Linux only supports very naive color conversions between RGB-CMYK-Gray.

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
