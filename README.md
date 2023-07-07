# ColorPaletteCodable

A color palette reader/editor/writer package for iOS, macOS, macCatalyst, tvOS, watchOS and Linux.

Supports the following color palette formats

* Adobe Swatch Exchange (`.ase`)
* Adobe Photoshop Color Swatch (`.aco`)
* Adobe Color Table (`.act`)
* Adobe Color Book (`.acb`) *(read only)*
* NSColorList (`.clr`) *(macOS only)* 
* RGB text files (`.rgb`)
* RGBA text files (`.rgba`)
* GIMP palette files (`.gpl`)
* Paint Shop Pro files (`.pal`, `.psppalette`)
* Microsoft RIFF palette files (`.pal`) *(read only)*
* SketchPalette files (`.sketchpalette`)
* CorelDraw/Adobe Illustrator xml palette (`.xml`)
* JSON encoded color files (`.jsoncolorpalette`) *ColorPaletteCodable internal file format*
* Hex Color Palette (text file with delimited hexadecimal color strings) (`.hex`)

<p align="center">
    <img src="https://img.shields.io/github/v/tag/dagronf/ColorPaletteCodable" />
    <img src="https://img.shields.io/badge/Swift-5.4-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <img src="https://img.shields.io/github/actions/workflow/status/dagronf/ColorPaletteCodable/swift.yml">
</p>

<p align="center">
    <img src="https://img.shields.io/badge/macOS-10.13+-red" />
    <img src="https://img.shields.io/badge/macCatalyst-2+-purple" />
    <img src="https://img.shields.io/badge/iOS-13+-blue" />
    <img src="https://img.shields.io/badge/tvOS-13+-orange" />
    <img src="https://img.shields.io/badge/watchOS-4+-yellow" />
    <img src="https://img.shields.io/badge/Linux-compatible-orange" />
</p>

## Why?

I wanted to be able to read and write `.ase` palette files in my Swift app. 
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
* Simple image generation for an group of colors

[Online API Documentation](https://swiftpackageindex.com/dagronf/ColorPaletteCodable/main/documentation/colorpalettecodable)

## API

| Type          | Description    | 
|:--------------|:---------------|
|`PAL.Palette`  | The full representation of a palette     |
|`PAL.Group`    | An optionally named collection of colors |
|`PAL.Color`    | An optionally named color                |

### Coders

| Type                      | Description                                 |
|:--------------------------|:--------------------------------------------|
|`PAL.Coder.ACB`            | Adobe Color Book (.acb)                     |
|`PAL.Coder.ACO`            | Adobe Photoshop Color Swatch (.aco)         |
|`PAL.Coder.ACT`            | Adobe Color Table (.act)                    |
|`PAL.Coder.ASE`            | Adobe Swatch Exchange (.ase)                |
|`PAL.Coder.CLR`            | NSColorList (.clr) *(macOS only)*           |
|`PAL.Coder.GIMP`           | GIMP palette files (.gpl)                   |
|`PAL.Coder.HEX`            | Hex Color Palette (`.hex`)                  |
|`PAL.Coder.JSON`           | JSON encoded palette (.jsoncolorpalette)    |
|`PAL.Coder.PaintShopPro`   | Paint Shop Pro palette (.pal;.psppalette)   |
|`PAL.Coder.RGB`            | RGB text files (.rgb)                       |
|`PAL.Coder.RGBA`           | RGB(A) text files (.rgba)                   |
|`PAL.Coder.RIFF`           | Microsoft RIFF palette (.pal)               |
|`PAL.Coder.SketchPalette`  | Sketch Palette (.sketchpalette)             |
|`PAL.Coder.XMLPalette`     | CorelDraw/Adobe Illustrator Palette (.xml)  |

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

   // Generate a simple image from the colors
   let image = try PAL.Image.Image(colors: [c1, c2, c3], size: CGSize(width: 100, height: 25))

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

* Adobe Color Book files (.acb)
* Adobe Photoshop Color Swatch files (.aco)
* Adobe Color Table files (.act)
* Adobe Swatch Exchange files (.ase)
* Apple ColorList files (.clr)
* RGB/RGBA hex encoded text files (.txt)
* GIMP text files (.gpl)
* JASC Paint Shop Pro (Corel) text files (.pal, .psppalette)
* Microsoft RIFF Palette (.pal)
* Sketch palette (.sketchpalette)
* CorelDraw/Adobe Illustrator XML palette (.xml)
* Hex delimited color palette (.hex)

You can drag colors out of the preview window into applications that support dropping of `NSColor` instances.

You can also save the palette to a new format (eg. saving a gimp `.gpl` format to an Adobe `.aco` format)

## Palette format encoding/decoding limitations

|                           | File Type              | Named<br>Colors? | Named<br>palette? | Color<br>Groups? | ColorType<br>Support? | Supports<br>Colorspaces? |
|---------------------------|------------------------|:----------------:|:-----------------:|:-----------------:|:--------------------:|:--------------------:|
| `PAL.Coder.ACB`           | Binary                 |         ✅       |         ❌        |         ❌        |           ❌           |        ✅           |
| `PAL.Coder.ACO`           | Binary                 |         ✅       |         ❌        |         ❌        |           ❌           |        ✅           |
| `PAL.Coder.ACT`           | Binary                 |         ❌       |         ❌        |         ❌        |           ❌           |     RGB only        |
| `PAL.Coder.ASE`           | Binary                 |         ✅       |         ❌        |         ✅        |           ✅           |        ✅           |
| `PAL.Coder.CLR`           | Binary<br>(macOS only) |         ✅       |         ❌        |         ❌        |           ❌           |        ✅           |
| `PAL.Coder.GIMP`          | Text                   |         ✅       |         ✅        |         ❌        |           ❌           |     RGB only        |
| `PAL.Coder.HEX`           | Text                   |         ❌       |         ❌        |         ❌        |           ❌           |     RGB only        |
| `PAL.Coder.JSON`          | JSON Text              |         ✅       |         ✅        |         ✅        |           ✅           |        ✅           |
| `PAL.Coder.PaintShopPro`  | Text                   |         ❌       |         ❌        |         ❌        |           ❌           |     RGB only        |
| `PAL.Coder.RGB/A`         | Text                   |         ✅       |         ❌        |         ❌        |           ❌           |     RGB only        |
| `PAL.Coder.RIFF`          | Binary                 |         ❌       |         ❌        |         ❌        |           ❌           |     RGB only        |
| `PAL.Coder.SketchPalette` | XML                   |         ❌       |         ❌        |         ❌        |           ❌           |     RGB only        |
| `PAL.Coder.XMLPalette`    | XML                    |         ✅       |         ✅        |         ✅        |           ❌           |        ✅           |

*(A ColorType represents the type of color (global/spot/normal))*

## Simple Gradient support

The library additional defines `PAL.Gradients` which defines a collection of colors with positions
that can be used when defining gradient types.  Certain gradient types (eg. `.grd`) support multiple 
gradients within the same file.

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
let coder = PAL.Gradients.Coder.JSON()

// Encode the gradient using the JSON encoder
let data = try coder.encode(gradients)

// Decode a gradient from data
let decoded = try PAL.Gradients.Decode(
   from: data,
   fileExtension: PAL.Gradients.Coder.JSON.fileExtension
)
```

The gradient coder includes basic importers/exporters.

| Type                       | Description                                       |
|:---------------------------|:--------------------------------------------------|
|`PAL.Gradients.Coder.JSON`  | Built-in JSON format (.jsongradient)              |
|`PAL.Gradients.Coder.GGR`   | GIMP gradient file (.ggr)                         |
|`PAL.Gradients.Coder.GRD`   | Basic Adobe Photoshop gradient file (.grd)        |
|`PAL.Gradients.Coder.PSP`   | Basic Paint Shop Pro gradient file (.pspgradient) |

* `.ggr` support doesn't respect segment blending functions other than linear (always imported as linear)
* `.ggr` support doesn't allow for segment coloring functions other than rgb (throws an error)
* `.grd` support is _very_ basic at this point. There's no formal document for it, and I built this using very 
vague documents [1](http://www.selapa.net/swatches/gradients/fileformats.php), [2]()
  * doesn't (currently) support encode
  * Only user colors are supported in the gradients (ie. book colors aren't supported)
  * Noise gradients aren't supported
  * only rgb, cmyk, hsb, gray colors are supported
* `.pspgradient` _appears_ to be equal to the grd v3 format. (Read only)

For some nice gradient files, [cptcity](http://soliton.vm.bytemark.co.uk/pub/cpt-city/index.html) has all of them :-)

cptcity also has a [nice converter](http://soliton.vm.bytemark.co.uk/pub/cptutils-online/select.html) for gradients to ggr

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

Copyright (c) 2023 Darren Ford

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
