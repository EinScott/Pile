# Pile
Pile is a small game framework made in [Beef Language](https://github.com/beefytech/Beef), similar to frameworks like MonoGame/FNA.
This is still in active development. Major TODOs are in Core.bf, minor TODOs in other comments marked with TODO. Contributions are welcome.

This is based on and partly a almost direct port of [Foster](https://github.com/NoelFB/Foster).

## What it does
Pile handles window management, input, rendering and audio through a few core modules that can be implemented for each platform: System, Graphics, Audio.
Currently, there are SDL2 System, OpenGL 3.3+ Graphics and SoLoud Audio (WIP) modules. Custom implementations are possible.

Apart from that, Pile can build asset packages to later load and unload at runtime. This is done by registering importers for each type of asset needed and then requesting certain assets to be built and later loaded by it. These are also very easily writable yourself.
Textures are merged into one big atlas. Currently this cannot be turned off, but such an option would be very easy to implement if requested.

There are also some useful structs, like Vector2&3, Point2&4 or Rect (of intagers) as well as some extensions to corelib classes, especially Math.

## Platforms
Pile is currently Win64 only due to two factors:

- SDL2 and SoLoud are only compiled for Win64&32 currently. Contribution of compiled binaries and general testing for other platforms is welcome.
- The OpenGL module crashes on Win32 and acts weired. Should investigate at some point. We probably need a few other Graphics modules for certain platforms.

## Getting started
Pile depends on [JSON_Beef](https://github.com/Jonathan-Racaud/JSON_Beef).

First, you need to override Game<T>. T should be the class itself. This is used for nothing but supplying a reference to the active game instance with the right type.

```cs
using Pile;

namespace ExampleGameProject
{
  public class ExampleGame : Game<ExampleGame>
  {
    public this() {}

    // This class contains some fundamental overridable methods which are called by Core.
    // Examples:
    protected override void Step() {}
    protected override void Update() {}
    protected override void Render() {}

    protected override void Startup()
    {
      // Graphics, System (=> Window & Input) & Audio are accessed through Core since they are overridable instances.
      // Packages, Assets (and a few others) are static and can be accessed directly.

      Log.Message(Core.System.DataPath); // Executing directory
      Log.Message(Assets.AssetCount);

      // All other types are created as you would expect
      let buf = scope FrameBuffer(320, 170);
    }
  }
}
```

To run Pile, simply initialize it with implementations of all core modules. To do this, add implementation projects, like Pile_OpenGL, Pile_SDL2 and Pile_SoLoud to your dependencies and create the instances as follows. Finally, start Pile with your game instance.

```cs
using Pile;
using Pile.Implementations;

namespace ExampleGameProject
{
  static
  {
    public static int Main(String[] args)
    {
      // Initializes Pile with the given core modules. Also opens the game window.
      Core.Initialize("An Example Game", new SDL_System(), new GL_Graphics(), new SL_Audio(), 1280, 720);

      // "Starts" your game. Will enter the core loop until closing is requested.
			Core.Start(new ExampleGame());

      return 0;
    }
  }
}
```

## Documentation
I try to keep the code clean and commented where needed, but documentation will also follow at some point.
