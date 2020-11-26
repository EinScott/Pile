using SDL2;
using System;

namespace Pile.Implementations
{
	public static class SDL_Init
	{
		internal static SDL.InitFlag InitFlags;
		static bool initialized;

		internal static Result<void> Init()
		{
			if (initialized) return .Ok;

			if (SDL.Init(InitFlags) != 0)
				LogErrorReturn!(scope String(SDL.GetError()));
			else initialized = true;

			return .Ok;
		}
	}
}
