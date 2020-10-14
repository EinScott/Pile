using SDL2;
using System;

namespace Pile.Implementations
{
	public static class SDL_Init
	{
		static SDL.InitFlag InitFlags;
		static bool initialized;

		static Result<void> Init()
		{
			if (initialized) return .Ok;

			if (SDL.Init(InitFlags) != 0)
			{
				LogErrorReturn!(scope String(SDL.GetError()));
			}
			else initialized = true;

			return .Ok;
		}
	}
}
