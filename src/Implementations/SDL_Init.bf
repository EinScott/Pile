using SDL2;
using System;

namespace Pile.Implementations
{
	public static class SDL_Init
	{
		static SDL.InitFlag InitFlags;
		static bool initialized;

		static void Init()
		{
			if (initialized) return;

			if (SDL.Init(InitFlags) != 0)
			{
				String error = scope String(SDL.GetError());
				Runtime.FatalError(error);
			}
			else initialized = true;
		}
	}
}
