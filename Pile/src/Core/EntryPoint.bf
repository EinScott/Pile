using System;
using System.IO;
using System.Collections;
using System.Diagnostics;

using internal Pile;

namespace Pile
{
	[Optimize]
	public static class EntryPoint
	{
		public delegate void StartDelegate();
		public static Event<StartDelegate> OnStart;

		public static function Result<void> GameMainFunction();
		public static GameMainFunction GameMain;

		public static String[] CommandLine;

		static int Main(String[] args)
		{
			// Handle args
			CommandLine = args;

#if !PILE_DISABLE_PACKAGER
			// Run packager
			{
				let exePath = scope String();
				Environment.GetExecutableFilePath(exePath);

				let dirPath = scope String();
				if (Path.GetDirectoryPath(exePath, dirPath) case .Ok)
				{
					let markerPath = Path.GetAbsolutePath(@"..\Pile\output_dir.temp", dirPath, .. scope String());//Path.InternalCombine(.. scope String(dirPath), "output_dir.temp");

					// If we are inside the build output directory
					// todo: this should probably be part of the build process itself...
					if (File.Exists(markerPath))
					{
						let inPath = Path.GetAbsolutePath(@"..\..\..\assets\", dirPath, .. scope String());
						let outPath = Path.InternalCombine(.. scope String(dirPath), @"packages\");

						RunPackager(inPath, outPath);
					}
				}
			}
#endif

			// Run onStart
			OnStart();
			OnStart.Dispose();

			if (RunGame() case .Err)
			{
				Core.FatalError("Error while running game");
			}

			return 0;
		}

		static Result<void> RunGame()
		{
			if (GameMain == null)
				LogErrorReturn!("EntryPoint.GameMain cannot be null. Register a function for it in static construction and call Core.Initialize and Core.Start");

			// Run GameMain
			LogErrorTry!(GameMain(), "Error while executing EntryPoint.GameMain");

			return .Ok;
		}
	}
}
