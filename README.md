# Pile
Pile is a small game engine made in the [Beef Language](https://github.com/beefytech/Beef), similar to frameworks like MonoGame/FNA and directly inspired by [Foster](https://github.com/NoelFB/Foster).

It focusses on handling and abstracting some of the basic underlying workings of a game in a reasonably extendable and performant way while giving you control about the structure of the actual game logic.

## What it does
Pile handles platform specific implementations through three core modules.
- System (application window, save location & input)
- Graphics
- Audio

The included core modules rely on
- SDL2 for the System
- OpenGL 3.3+ for the Graphics
- SoLoud for the Audio module
Custom implementations are possible.

It also includes an extendable system for managing assets, a sprite batcher, UTF8 Unicode text rendering via SpriteFonts using TrueType fonts, performance tools and a logging system.

There are also some math structs, like Vector2 & 3, Point2 & 3, Quaternion and Rect (of integers) as well as some extensions to corelib classes, especially Math.

## Documentation
Guide on [Getting Started](https://github.com/EinScott/Pile/wiki/Getting-Started). Further documentation can be found here: [Wiki](https://github.com/EinScott/Pile/wiki), [Examples & Template Project](https://github.com/EinScott/Pile/tree/master/Examples)

# Platforms
32-Bit Architectures are not supported.
Windows binaries are already included. Binaries for other platforms are missing (See ./Implementations/(any)/dist/).

# Contributing
Help is appreciated, especially concerning supporting more platforms and core module implementations.

# License
Pile is licensed under the MIT license, see [LICENSE.txt](https://github.com/EinScott/Pile/blob/master/LICENSE.txt).

Third party software used:
- [fast-obj](https://github.com/thisistherk/fast_obj) - OBJ format support
- [stb_truetype](https://github.com/nothings/stb/blob/master/stb_truetype.h) - Font handling
- [referencesource/System.Numerics](https://github.com/microsoft/referencesource/tree/master/System.Numerics/System/Numerics) - Parts of the structs located in ./Pile/src/Struct/*
- [SDL2](https://www.libsdl.org/) - System Implementation
- [SoLoud](http://sol.gfxile.net/soloud/index.html) - Audio Implementation
- [Beef-OpenGL-Header-Generator](https://github.com/heisluft/Beef-OpenGL-Header-Generator) - GL function bindings

The licenses for the binaries of each library used in Implementation projects can be found in `./Implementations/(name)/dist/LICENSE.txt`. Source files that include third party code have a separate license notice at the top of the file.
