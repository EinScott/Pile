using System;
using System.IO;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	public struct RunPreferences
	{
		public WindowMode windowMode;
		public uint32 windowWidth = 1280;
		public uint32 windowHeight = 720;
		public StringView gameTitle;
		public StringView windowTitle;
		public function Game() createGame;
	}

	[Optimize,StaticInitPriority(100)]
	public static class EntryPoint
	{
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

#if DEBUG
			// In debug, run this on actual execute for debugging perks
			TrySilent!(RunPackager());
#endif

			// Run onStart
			Core.Assert(OnStart() case .Ok, "Error in OnStart");
			OnStart.Dispose();
			
			// Run with registered settings
			Core.Assert(Core.Run(Preferences) case .Ok, "Error while running");

			return 0;
		}
	}
}
