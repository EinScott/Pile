using System;
using System.IO;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	[Optimize,StaticInitPriority(100)]
	public static class EntryPoint
	{
		public struct RunPreferences
		{
			public uint32 windowWidth = 1280;
			public uint32 windowHeight = 720;
			public StringView gameTitle;
			public function Game() createGame;
		}

		public static Event<delegate Result<void>()> OnStart ~ OnStart.Dispose();
		public static RunPreferences Preferences = .();

		public static String[] CommandLine;

		static int Main(String[] args)
		{
			// Store args
			CommandLine = args;

			// Packager mode
			if (args.Count > 0 && args[0] == "-packager")
			{
				if (RunPackager() case .Err)
					return 1;
				return 0;
			}

			// Run onStart
			if (OnStart() case .Err)
				Core.FatalError("Error in OnStart");

			Core.Assert(Preferences.gameTitle.Ptr != null, "Pile.EntryPoint.RunPreferences.gameTitle has to be set. Provide an unchanging, file system safe string literal");
			Core.Assert(Preferences.createGame != null, "Pile.EntryPoint.RunPreferences.createGame has to be set. Provide a function that returns an instance of your game");

			// Find thing to run
			if (Core.Run(Preferences.windowWidth, Preferences.windowHeight, Preferences.createGame(), Preferences.gameTitle) case .Err)
				Core.FatalError("Error while running game");

			return 0;
		}
	}
}
