# Pile
Pile is a small game framework made in [Beef Language](https://github.com/beefytech/Beef), similar to frameworks like MonoGame/FNA.
This is still in active development. Major TODOs are in Core.bf, minor TODOs in other comments marked with TODO. Contributions are welcome.

This is based on and partly a almost direct port of [Foster](https://github.com/NoelFB/Foster).

## What it does
Pile handles window management, input, rendering and audio through a few abstract core modules that can be implemented for each platform: System, Graphics, Audio.
Currently, there are SDL2 System, simple OpenGL 3.3+ Graphics and SoLoud Audio modules. Custom implementations are possible.

Apart from that, Pile can build asset packages to later load and unload at runtime. This is done by registering importers for each type of asset needed and then requesting certain assets to be built and later loaded by it. These are also very easily writable yourself.
Textures are merged into one big atlas. Currently this cannot be turned off, but such an option would be very easy to implement if somebody needs it.

There are also some useful structs, like Vector2 & 3, Point2 & 3 or Rect (of intagers) as well as some extensions to corelib classes, especially Math.

## Getting started
Pile depends on [JSON_Beef](https://github.com/Jonathan-Racaud/JSON_Beef).

First, you need to override `Game<T>`. `T` should be the class itself. This is used for nothing but supplying a reference to the active game instance with the right type.

Pile has its own entry point. While you can still have your own main function, and start pile like shown in `Run()`, it might be  more conveniant to use `Pile.EntryPoint`, especially when you are using Packages.
To use it:
- set your projects startup object (found in (right click on project) > Properties... > General/Beef > General/Startup Object) to `Pile.EntryPoint`
- you have to make sure your game class is included at all, since it is never referenced by Pile, with `[AlwaysInclude]`
- use the static constructor to tell Pile what to do on startup (See example below). Make sure to register all your Importers (if any) in there as well.

To run Pile (in `Run()`), simply initialize it with implementations of all core modules. To do this, add implementation projects, like `Pile_OpenGL`, `Pile_SDL2` and `Pile_SoLoud` to your dependencies and create the instances as follows. Finally, start Pile with your game instance.

```cs
using Pile;
using Pile.Implementations;
using System;

namespace ExampleGameProject
{
  [AlwaysInclude]
  public class ExampleGame : Game<ExampleGame>
  {
    static this()
    {
      // Register our function to be called on main
      EntryPoint.GameMain = => Run;
    }

    static Result<void> Run()
    {
      // Start pile with an instance of our game
      Core.Initialize("Example Game Window",
        new SDL_System(),
        new GL_Graphics(),
        new SL_Audio(),
        1280, 720);

      Core.Start(new ExampleGame());

      return .Ok;
    }

    // This class contains some fundamental overridable methods which are called by Core.
    protected override void Startup()
    {
      Log.Message(Core.System.DataPath); // Executing directory
    }

    protected override void Step() {}
    protected override void Update() {}
    protected override void Render() {}
  }
}
```

## Documentation
See the [Example](https://github.com/EinBurgbauer/Pile/tree/master/Example) project for further reference.
I try to keep the code clean and commented where needed, but documentation will also follow at some point.

# Platforms
32-Bit Archetictures are not supported.
Windows binaries are already included. Binaries for other platforms are missing (currently SDL2 and SoLoud). Contribution of compiled binaries and general testing for other platforms is welcome.

# Library Credits

## SDL2 Library
[Website](https://www.libsdl.org/license.php)

Binaries found in Implementations/System_SDL/dist/*

## SoLoud
[Website](http://sol.gfxile.net/soloud/index.html)

Binaries found in Implementations/Audio_SoLoud/dist/*

## STB_TrueType
[Source](https://github.com/nothings/stb/blob/master/stb_truetype.h)

A beef port of this public domain header is used for font handeling.
