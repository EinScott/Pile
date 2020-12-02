# Pile
Pile is a small game framework made in [Beef Language](https://github.com/beefytech/Beef), similar to frameworks like MonoGame/FNA.
This is still in active development, suggestions & contributions for changes and fixes are welcome.

## What it does
Pile handles window management, input, rendering and audio through a few abstract core modules that can be implemented for each platform: System, Graphics, Audio.
Currently, there are SDL2 System, simple OpenGL 3.3+ Graphics and SoLoud Audio modules. Custom implementations are possible.

Apart from that, Pile features an extendable asset management pipeline and supports UTF8 unicode text rendering via STB_TrueType fonts.

There are also some useful structs, like Vector2 & 3, Point2 & 3 or Rect (of intagers) as well as some extensions to corelib classes, especially Math.

## Getting started
Pile depends on [JSON_Beef](https://github.com/Jonathan-Racaud/JSON_Beef).

To add Pile to your project:
- add the projects you need to your workspace (right click on your project > add from installed../add existing project.. (depending on how you installed Pile)):
  - Pile (the main project), found in ./Pile/
  - one Graphics, Audio and System implementation, found in ./Implementations/(list of all implementation projects)
- add those to your dependencies (right click on your project > Properties.. > General/Dependencies) by ticking the boxes of all related Pile projects

First, you need to override `Game<T>`. `T` should be the class itself. This is used for nothing but supplying a reference to the active game instance with the right type.

Pile has its own entry point. While you can still have your own main function, and start pile like shown in `Run()`, it might be  more conveniant to use `Pile.EntryPoint`, especially when you are using Packages.
To use it:
- set your projects startup object (right click on your project > Properties... > General/Beef > General/Startup Object) to `Pile.EntryPoint`
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

    // This class contains some fundamental overridable methods which are called by Core
    protected override void Startup()
    {
      Log.Message(Core.System.DataPath);
    }
  }
}
```

## Documentation
Documentation is still WIP.

See the [Example](https://github.com/EinBurgbauer/Pile/tree/master/Example) project for further reference.

# Platforms
32-Bit Archetictures are not supported.
Windows binaries are already included. Binaries for other platforms are missing (currently SDL2 and SoLoud). Contribution of compiled binaries and general testing for other platforms is welcome.

## Contributing
You may suggest to change stuff to make the framework nicer to work with or add features. More specifically, major TODOs are in Core.bf, minor TODOs in other comments marked with TODO (CTRL+SHIFT+F).

# License
Pile is licensed under the ZLIB license, see [LICENSE.txt](https://github.com/EinBurgbauer/Pile/blob/master/LICENSE.txt).
See [ATTRIBUTIONS.md](https://github.com/EinBurgbauer/Pile/blob/master/ATTRIBUTIONS.md) for info on and licenses of all libraries used.
