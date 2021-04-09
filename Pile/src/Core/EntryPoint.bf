using System;

using internal Pile;

namespace Pile
{
	struct RunConfig
	{
		public WindowState windowState;
		public uint32 windowWidth = 1280;
		public uint32 windowHeight = 720;
		public StringView gameTitle;
		public StringView windowTitle;
		public function Game() createGame;
	}

	[Optimize, StaticInitPriority(PILE_SINIT_ENTRY)]
	static class EntryPoint
	{
		public static Event<delegate Result<void>()> OnStart ~ OnStart.Dispose();
		public static RunConfig Config = .();
		
		public static String[] CommandLine;

		static int Main(String[] args)
		{
			// Store args
			CommandLine = args;

			// Packager mode
			if (args.Count > 0 && args[0] == "-packager")
			{
				if (RunPackager() case .Err)
					Runtime.FatalError("Error while running packager");
				return 0;
			}

#if DEBUG
			// In debug, run this on actual execute for debugging perks
			RunPackager().IgnoreError();
#endif
			
			// Run onStart
			Runtime.Assert(OnStart() case .Ok, "Error in OnStart");
			OnStart.Dispose();
			
			// Run with registered settings
			Core.Run(Config);

			return 0;
		}
	}
}
