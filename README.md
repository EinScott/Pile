# Pile
Pile is a small game framework made in [Beef Language](https://github.com/beefytech/Beef), similar to frameworks like MonoGame/FNA and directly inspired by [Foster](https://github.com/NoelFB/Foster).

## What it does
Pile handles window, input, rendering and audio management through a few abstract core modules.

The included core modules rely on
- SDL2 for the System,
- OpenGL 3.3+ for the Graphics (basic implementation, should be swapped out at some point),
- SoLoud for the Audio module
Custom implementations are possible.

Apart from that, there's an extendable asset management pipeline and UTF8 Unicode text rendering via SpriteFonts using TrueType fonts.

There are also some basic math structs, like Vector2 & 3, Point2 & 3 or Rect (of integers) as well as some extensions to corelib classes, especially Math.

## Documentation
Guide on [Getting Started](https://github.com/EinBurgbauer/Pile/wiki/Getting-Started). Documentation can be found here: [Wiki](https://github.com/EinBurgbauer/Pile/wiki)

See the [Examples](https://github.com/EinBurgbauer/Pile/tree/master/Examples) for further reference and a minimal template project.

# Platforms
32-Bit Architectures are not supported.
Windows binaries are already included. Binaries for other platforms are missing (See ./Implementations/(any)/dist/).

# Contributing
Help is appreciated, especially concerning supporting more platforms and core module implementations.

# License
Pile is licensed under the MIT license, see [LICENSE.txt](https://github.com/EinBurgbauer/Pile/blob/master/LICENSE.txt).
Other open source libraries used:
- [stb_truetype](https://github.com/nothings/stb/blob/master/stb_truetype.h) - Font handling
- [referencesource/System.Numerics](https://github.com/microsoft/referencesource/tree/master/System.Numerics/System/Numerics) - Parts of the structs located in ./Pile/src/Struct/*
- [SDL2](https://www.libsdl.org/) - System Implementation
- [SoLoud](http://sol.gfxile.net/soloud/index.html) - Audio Implementation

The licenses for the binaries of each library used in Implementation projects can be found in `./Implementations/(name)/dist/LICENSE.txt`.
stb_truetype is licensed under the Unlicense. The MS referencesource is MIT licensed.
