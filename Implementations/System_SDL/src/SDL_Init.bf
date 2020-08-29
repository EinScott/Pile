using SDL2;
using System;

namespace Pile.Implementations
{
	public static class SDL_Init
	{
		static SDL.InitFlag InitFlags;
		static bool initialized;

		static Result<void, String> Init()
		{
			if (initialized) return .Ok;

			if (SDL.Init(InitFlags) != 0)
			{
				return .Err(scope .(SDL.GetError()));
			}
			else initialized = true;

			return .Ok;
		}
	}
}
