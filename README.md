# ColorPaletteCodable

A color palette reader/editor/writer package for iOS, macOS, macCatalyst, tvOS, watchOS and Linux.

![tag](https://img.shields.io/github/v/tag/dagronf/ColorPaletteCodable)
![Swift](https://img.shields.io/badge/Swift-5.4-orange.svg)
[![License MIT](https://img.shields.io/badge/license-MIT-magenta.svg)](https://github.com/dagronf/ColorPaletteCodable/blob/master/LICENSE) 
![SPM](https://img.shields.io/badge/spm-compatible-maroon.svg)
![Build](https://img.shields.io/github/actions/workflow/status/dagronf/ColorPaletteCodable/swift.yml)


![macOS](https://img.shields.io/badge/macOS-10.13+-darkblue)
![iOS](https://img.shields.io/badge/iOS-13+-crimson)
![tvOS](https://img.shields.io/badge/tvOS-13+-forestgreen)
![watchOS](https://img.shields.io/badge/watchOS-6+-indigo)
![macCatalyst](https://img.shields.io/badge/macCatalyst-2+-orangered)
![Linux](https://img.shields.io/badge/Linux-compatible-peru)

Supports the following :-

## Supported palette formats

* Adobe Swatch Exchange (`.ase`)
* Adobe Photoshop Color Swatch (`.aco`)
* Adobe Color Table (`.act`)
* Adobe Color Book (`.acb`) ***(read only)***
* NSColorList (`.clr`) ***(macOS only)***
* RGB text files (`.rgb`)
* RGBA text files (`.rgba`)
* GIMP palette files (`.gpl`)
* OpenOffice/LibreOffice palette files (`.soc`)
* Paint Shop Pro files (`.pal`, `.psppalette`)
* Image palette files (`.png`, `.jpg`, `.gif`) (unique colors in the first row of the image)
* Microsoft RIFF palette files (`.pal`) ***(read only)***
* SketchPalette files (`.sketchpalette`)
* CorelDraw/Adobe Illustrator xml palette (`.xml`)
* Corel swatches (`.txt`)
* Corel Paint file format (`.cpl`) ***(read only)***
* JSON encoded color files (`.jsoncolorpalette`) ***ColorPaletteCodable internal file format***
* Hex Color Palette (text file with delimited hexadecimal color strings) (`.hex`)
* Paint.NET palette files (`.txt`)
* SVG swatches (`.svg`) ***(write only)***
* Basic CSV
* Basic XML
* Android `colors.xml` resource file format

## Supported gradient formats

* GIMP gradient (`.ggr`)
* Built-in JSON format gradient (`.jsongradient`)
* Basic Adobe gradient (`.grd`) ***(read only)***
* CPT gradient (`.cpt`) ***(read only)***
* Basic Paint Shop Pro gradient (`.pspgradient`) ***(read only)***
* SVG Gradient file (`.svg`) ***(write only)***

## Why?

I wanted to be able to read and write Adobe `.ase` palette files in my Swift app. 
This then extended to `.aco` Adobe Photoshop Color Swatch files.
Which then expanded to other types :-)

Some features :-

* Named palettes
* Named colors
* Multiple named groups of colors within a single palette
* Colorspace support (RGB, CMYK, Gray) with conversion capabilities
* Encoding/Decoding of all supported palette coder types
* Includes a cross-platorm, human readable, palette coder (json utf8 format)
* Integrated pasteboard support for macOS/iOS
* Simple image generation for an collection of colors
* Gradient support

[Online API Documentation](https://swiftpackageindex.com/dagronf/ColorPaletteCodable/main/documentation/colorpalettecodable)

## Palette API

| Type          | Description                              | 
|:--------------|:-----------------------------------------|
|`PAL.Palette`  | The full representation of a palette     |
|`PAL.Group`    | An optionally named collection of colors |
|`PAL.Color`    | An optionally named color                |

### Available Coders

| Type                              | Description                                 |
|:----------------------------------|:--------------------------------------------|
|`PAL.Coder.ACB`                    | Adobe Color Book (.acb)                     |
|`PAL.Coder.ACO`                    | Adobe Photoshop Color Swatch (.aco)         |
|`PAL.Coder.ACT`                    | Adobe Color Table (.act)                    |
|`PAL.Coder.AndroidColorsXML`       | Android `color.xml` resources (.xml)        |
|`PAL.Coder.ASE`                    | Adobe Swatch Exchange (.ase)                |
|`PAL.Coder.BasicXML`               | Basic XML structure (.xml)                  |
|`PAL.Coder.CLR`                    | NSColorList (.clr) *(macOS only)*           |
|`PAL.Coder.CorelPainter`           | CorelPainter Swatch (.txt)                  |
|`PAL.Coder.CorelXMLPalette`        | CorelDraw/Adobe Illustrator Palette (.xml)  |
|`PAL.Coder.CPL`                    | Corel Paint (.cpl)                          |
|`PAL.Coder.CSV`                    | CSV (.csv)                                  |
|`PAL.Coder.GIMP`                   | GIMP palette files (.gpl)                   |
|`PAL.Coder.HEX`                    | Hex Color Palette (`.hex`)                  |
|`PAL.Coder.Image`                  | Image files (.png, .jpg, .gif)              |
|`PAL.Coder.JSON`                   | JSON encoded palette (.jsoncolorpalette)    |
|`PAL.Coder.OpenOfficePaletteCoder` | OpenOffice Palette (.soc)                   |
|`PAL.Coder.PaintNET`               | Paint.NET Palette (.txt)                    |
|`PAL.Coder.PaintShopPro`           | Paint Shop Pro palette (.pal;.psppalette)   |
|`PAL.Coder.RGBA`                   | RGB(A) text files (.rgba)                   |
|`PAL.Coder.RGB`                    | RGB text files (.rgb)                       |
|`PAL.Coder.RIFF`                   | Microsoft RIFF palette (.pal)               |
|`PAL.Coder.SketchPalette`          | Sketch Palette (.sketchpalette)             |
|`PAL.Coder.SVG`                    | SVG image file (.svg)                       |

Each coder defines `.encode` and `.decode`. Not all coders support both encode and decode.

### Example usage

#### Decode a palette file

```swift
do {
   let myFileURL = URL(fileURL: ...)
   
   // Try to decode the palette based on its file extension
   let palette = try PAL.Palette.Decode(from: myFileURL)
   
   // do something with 'palette'
}
catch {
   // Do something with 'error'
}
```

#### Build a palette and generate an ASE binary representation

```swift
// Build a palette
var palette = PAL.Palette()
let c1 = try PAL.Color.rgb(name: "red",   1, 0, 0)
let c2 = try PAL.Color.rgb(name: "green", 0, 1, 0)
let c3 = try PAL.Color.rgb(name: "blue",  0, 0, 1)
palette.colors.append(contentsOf: [c1, c2, c3])

// Generate a simple image from the colors
let image = try PAL.Image.Image(colors: [c1, c2, c3], size: CGSize(width: 100, height: 25))

// Create an ASE coder
let coder = PAL.Coder.ASE()

// Get the .ase format data
let rawData = try coder.encode(palette)
   
// Do something with 'rawData' (like write to a file for example)
```

#### Read an ACO file, write an ASE file

```swift
let acoFileURL = URL(fileURL: ...)
let coder = PAL.Coder.ACO()
var palette = try coder.decode(from: acoFileURL)
   
// do something with 'palette'
   
// re-encode the palette to an ASE format
let encoder = PAL.Coder.ASE()
let rawData = try encoder.encode(palette) 
```

### Palette format encoding/decoding limitations

|                               | File Type              | Decode?  | Encode?  | Named<br>Colors? | Named<br>palette? | Color<br>Groups? | ColorType<br>Support? | Supports<br>Colorspaces? |
|-------------------------------|------------------------|:--------:|:--------:|:----------------:|:-----------------:|:----------------:|:--------------------:|:--------------------:|
| `PAL.Coder.ACB`               | Binary                 |    ✅    |    ❌    |         ✅       |         ❌        |        ❌       |          ❌          |        ✅           |
| `PAL.Coder.ACO`               | Binary                 |    ✅    |    ✅    |         ✅       |         ❌        |        ❌       |          ❌          |        ✅           |
| `PAL.Coder.ACT`               | Binary                 |    ✅    |    ✅    |         ❌       |         ❌        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.AndroidColorsXML`  | XML                    |    ✅    |    ✅    |         ✅       |         ❌        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.ASE`               | Binary                 |    ✅    |    ✅    |         ✅       |         ❌        |        ✅       |          ✅          |        ✅           |
| `PAL.Coder.BasicXML`          | XML                    |    ✅    |    ✅    |         ✅       |         ✅        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.CLR`               | Binary<br>(macOS only) |    ✅    |    ✅    |         ✅       |         ❌        |        ❌       |          ❌          |        ✅           |
| `PAL.Coder.CorelPainter`      | Text                   |    ✅    |    ✅    |         ✅       |         ❌        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.CPL`               | Binary                 |    ✅    |    ❌    |         ✅       |         ✅        |        ❌       |          ✅          |        ✅           |
| `PAL.Coder.CSV`               | Text                   |    ✅    |    ✅    |         ✅       |         ❌        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.GIMP`              | Text                   |    ✅    |    ✅    |         ✅       |         ✅        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.HEX`               | Text                   |    ✅    |    ✅    |         ❌       |         ❌        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.Image`             | Binary                 |    ✅    |    ✅    |         ❌       |         ❌        |        ❌       |          ❌          |        ❌           |
| `PAL.Coder.JSON`              | JSON Text              |    ✅    |    ✅    |         ✅       |         ✅        |        ✅       |          ✅          |        ✅           |
| `PAL.Coder.OpenOfficePalette` | XML                    |    ✅    |    ✅    |         ✅       |         ❌        |        ❌       |          ❌          |        ❌           |
| `PAL.Coder.PaintNET`          | Text                   |    ✅    |    ✅    |         ❌       |         ❌        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.PaintShopPro`      | Text                   |    ✅    |    ✅    |         ❌       |         ❌        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.RGB/A`             | Text                   |    ✅    |    ✅    |         ✅       |         ❌        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.RIFF`              | Binary                 |    ✅    |    ❌    |         ❌       |         ❌        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.SketchPalette`     | XML                    |    ✅    |    ✅    |         ❌       |         ❌        |        ❌       |          ❌          |     RGB only        |
| `PAL.Coder.SVG`               | SVG text               |    ❌    |    ✅    |         ❌       |         ✅        |        ✅       |          ❌          |     RGB only        |
| `PAL.Coder.XMLPalette`        | XML                    |    ✅    |    ✅    |         ✅       |         ✅        |        ✅       |          ❌          |        ✅           |

*(A ColorType represents the type of color (global/spot/normal))*

## Gradients

The library defines `PAL.Gradients` which defines a collection of colors with positions
that can be used when using a gradient.  Certain gradient types (eg. `.grd`) support multiple 
gradients within the same file.

## Gradient API

| Type                   | Description                            | 
|:-----------------------|:---------------------------------------|
|`PAL.Gradients`         | A collection of gradients              |
|`PAL.Gradient`          | A gradient                             |
|`PAL.Stop`              | A color stop within a gradient         |
|`PAL.TransparencyStop`  | A transparency stop within a gradient  |

### Available Coders

| Type                       | Description                                       | Decode? | Encode? |
|:---------------------------|:--------------------------------------------------|:-------:|:-------:|
|`PAL.Gradients.Coder.CPT`   | CPT gradient file (.cpt)                          |    ✅   |   ❌   |
|`PAL.Gradients.Coder.JSON`  | Built-in JSON format (.jsongradient)              |    ✅   |   ✅   |
|`PAL.Gradients.Coder.GGR`   | GIMP gradient file (.ggr)                         |    ✅   |   ✅   |
|`PAL.Gradients.Coder.GPF`   | GNUPlot color palette file (.gpf)                 |    ✅   |   ✅   |
|`PAL.Gradients.Coder.GRD`   | Basic Adobe Photoshop gradient file (.grd)        |    ✅   |   ❌   |
|`PAL.Gradients.Coder.PSP`   | Basic Paint Shop Pro gradient file (.pspgradient) |    ✅   |   ❌   |
|`PAL.Gradients.Coder.SVG`   | SVG file (.svg)                                   |    ❌   |   ✅   |

* `.gpf` only supports rgb
* `.ggr` support doesn't respect segment blending functions other than linear (always imported as linear)
* `.ggr` support doesn't allow for segment coloring functions other than rgb (throws an error)
* `.grd` support is _very_ basic at this point. There's no formal document for it, and I built this using very 
vague documents [1](http://www.selapa.net/swatches/gradients/fileformats.php), [2]()
  * doesn't (currently) support encode
  * Only user colors are supported in the gradients (ie. book colors aren't supported)
  * Noise gradients aren't supported
  * only rgb, cmyk, hsb, gray colors are supported
* `.pspgradient` _appears_ to be equal to the grd v3 format. (Read only)

For some nice gradient files

* [cptcity](http://seaviewsensing.com/pub/cpt-city/) has all of them :-)
* [lospec](https://lospec.com/palette-list)

cptcity also has a [nice converter](http://seaviewsensing.com/pub/cptutils-online/convert/select.html) for gradients to ggr

### Examples

#### Create a gradient

```swift
let gradient = PAL.Gradient(
   colorPositions: [
      (0.0, try PAL.Color(rgbHexString: "#FFFFFF")),
      (0.5, try PAL.Color(rgbHexString: "#444444")),
      (1.0, try PAL.Color(rgbHexString: "#000000"))
   ]
)

// Create a gradients container
let gradients = PAL.Gradients(gradients: [gradient])

// Create the appropriate coder
let coder = PAL.Gradients.Coder.GGR()

// Encode the gradient using the GIMP gradient encoder
let data = try coder.encode(gradients)

// Decode a gradient from data
let decoded = try PAL.Gradients.Decode(
   from: data,
   fileExtension: PAL.Gradients.Coder.GGR.fileExtension
)
```

#### Load a gradient

```swift
// Load a gradient from a file, inferring the type from the file's extension
let gradient1 = try PAL.Gradients.Decode(from: fileURL)

// Load a specific gradient format from a file
let coder = PAL.Gradients.Coder.GRD()
let gradient2 = try coder.decode(from: i)
```

## Palette Viewer

Palette Viewer allows you to view the contents of all supported palette and gradient files

You can drag colors out of the preview window into applications that support dropping of `NSColor` instances.

You can also save the palette to a new format (eg. saving a gimp `.gpl` format to an Adobe `.aco` format)

### QuickLook support

This package also includes a Quicklook Plugin for palette and gradient files.

In the `Quicklook` subfolder you'll find an `xcodeproj` which you can use to build the application `Palette Viewer` which contains the QuickLook plugin.

For the plugin to register, you need to run the application. After the first run the QuickLook plugin will be registered.

## Linux support

* Linux only supports very naive color conversions between RGB-CMYK-Gray.

### To build/test linux support using a mac

See: [Testing Swift packages on Linux using Docker](https://oleb.net/2020/swift-docker-linux/)

1. Install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop) on your mac
2. Make sure that docker is running (or else the next command will fail with a weird or no error message)
3. Run the following command in the directory you want to mirror in your linux 
	
```bash
docker run --rm --privileged --interactive --tty --volume "$(pwd):/src" --workdir "/src" swift:latest
```

Now, from within the docker container, run 

```bash
swift build
swift test
```

Note that the /src directory in the Linux container is a direct mirror of the current directory on the host OS, not a copy. If you delete a file in /src in the Linux container, that file will be gone on the host OS, too.

## Format specs

The `.ase` file format is not formally defined, however there are a number of deconstructions available on the web.
I used the breakdown of the format defined [here](http://www.selapa.net/swatches/colors/fileformats.php#adobe_ase).

The `.aco` file format is defined [here](https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#50577411_pgfId-1055819).

The `.act` file format is defined [here](https://www.adobe.com/devnet-apps/photoshop/fileformatashtml/#50577411_pgfId-1070626).

The `.acb` format discussed and deined [here](https://magnetiq.ca/pages/acb-spec/)

The CorelDraw/Adobe Illustrator `.xml` file format is (somewhat) defined [here](https://community.coreldraw.com/sdk/w/articles/177/creating-color-palettes)

### GRD references

* [http://www.selapa.net/swatches/gradients/fileformats.php](http://www.selapa.net/swatches/gradients/fileformats.php)
* [https://github.com/Balakov/GrdToAfpalette/blob/master/palette-js/load_grd.js](https://github.com/Balakov/GrdToAfpalette/blob/master/palette-js/load_grd.js)
* [https://github.com/abought/grd_to_cmap/blob/master/grd_reader.py](https://github.com/abought/grd_to_cmap/blob/master/grd_reader.py)
* [https://github.com/tonton-pixel/json-photoshop-scripting/tree/master/Documentation/Photoshop-Gradients-File-Format#descriptor](https://github.com/tonton-pixel/json-photoshop-scripting/tree/master/Documentation/Photoshop-Gradients-File-Format#descriptor)

## License

```
MIT License

Copyright (c) 2024 Darren Ford

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
