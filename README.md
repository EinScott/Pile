# Pile
Pile is a small game framework made in [Beef Language](https://github.com/beefytech/Beef), similar to frameworks like MonoGame/FNA and directly inspired by [Foster](https://github.com/NoelFB/Foster).
This is still in active development, suggestions & contributions for changes and fixes are welcome.

## What it does
Similar to frameworks mentioned above, you can build your own game or engine code on top of the `Game` class.

Pile handles window management, input, rendering and audio through a few abstract core modules that can be implemented for each platform: System, Graphics, Audio.

Currently, there are
- SDL2 System
- simple OpenGL 3.3+ Graphics
- SoLoud Audio modules

Custom implementations are possible.

Apart from that, there's an extendable asset management pipeline and UTF8 unicode text rendering via SpriteFonts using TTF fonts.

There are also some useful structs, like Vector2 & 3, Point2 & 3 or Rect (of integers) as well as some extensions to corelib classes, especially Math.

## Documentation
Guide on [Getting Started](https://github.com/EinBurgbauer/Pile/wiki/Getting-Started). Documentation can be found here: [Wiki](https://github.com/EinBurgbauer/Pile/wiki)

See the [Example](https://github.com/EinBurgbauer/Pile/tree/master/Example) project for further reference.

# Platforms
32-Bit Archetictures are not supported.
Windows binaries are already included. Binaries for other platforms are missing (See ./Implementations/(any)/dist/).

# Contributing
You may suggest to change stuff to make the framework nicer to work with or add features. More specifically, major TODOs are in Core.bf, minor TODOs in other comments marked with TODO (CTRL+SHIFT+F).

# License
Pile is licensed under the MIT license, see [LICENSE.txt](https://github.com/EinBurgbauer/Pile/blob/master/LICENSE.txt).
Other open source libraries used:
- [stb_truetype](https://github.com/nothings/stb/blob/master/stb_truetype.h) - Font handeling
- [referencesource/System.Numerics](https://github.com/microsoft/referencesource/tree/master/System.Numerics/System/Numerics) - Parts of the structs located in ./Pile/src/Struct/*
- [SDL2](https://www.libsdl.org/) - System Implementation
- [SoLoud](http://sol.gfxile.net/soloud/index.html) - Audio Implementation
- [bgfx](https://github.com/bkaradzic/bgfx) - Graphics Implementation

The licenses for the binaries of each library used in Implementation projects can be found in `./Implementations/(name)/dist/LICENSE.txt`.
stb_truetype is licensed under the Unlicense. The MS referencesource is MIT licensed.
