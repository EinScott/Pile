using System;
using System.IO;
using System.Collections;

using internal Pile;

namespace Pile
{
	public static class EntryPoint
	{
		public delegate void StartDelegate();
		public static Event<StartDelegate> OnStart;

		public static function Result<void> GameMainFunction();
		public static GameMainFunction GameMain;

		public delegate Result<void> LaunchDelegate(Span<String> args);
		static Dictionary<String, LaunchDelegate> launchOptions = new Dictionary<String, LaunchDelegate>();

		// This should be in here, because that way, this class is mentioned nowhere in the library and won't get included if it's not used (as well as the RunPackager() function).
		static this()
		{
#if !PILE_DISABLE_PACKAGER
			AddLaunchOption("-packager", new => RunPackager);
#endif
		}

		static ~this()
		{
			OnStart.Dispose();

			// Tests will leak this otherwise
			if (launchOptions != null) DeleteDictionaryAndKeysAndValues!(launchOptions);
		}

		[Optimize]
		public static Result<void> AddLaunchOption(StringView name, LaunchDelegate launch)
		{
			if (launchOptions == null)
				LogErrorReturn!("Failed to add launch option: Cannot add launch option after the game has already launched");

			if (name.Length == 0 || launch == null)
				LogErrorReturn!("Failed to add launch option: Name cannot have a length of 0, launch delegate cannot be null");

			let command = new String();
			if (!name.StartsWith("-"))
				command.Append("-");
			command.Append(name);

			launchOptions.Add(command, launch);
			return .Ok;
		}

		[Optimize]
		static int Main(String[] runArgs)
		{
			// Handle args
			{
				// Does launch file exist?
				let datArgs = new List<String>();
				{
					let exePath = scope String();
					Environment.GetExecutableFilePath(exePath);

					let path = scope String();
					Path.GetDirectoryPath(exePath, path);
					Path.InternalCombine(path, "launch.dat");

					// Parse args from file
					if (File.Exists(path))
					{
						let content = scope String();
						if (File.ReadAllText(path, content) case .Err(let err))
							Log.Warning(scope $"launch.dat exists but couldn't be read: {err}");

						if (content.Length > 0)
						{
							for (var arg in content.Split(' ', '\n'))
							{
								arg.Trim();
								if (arg.Length > 0)
									datArgs.Add(new String(arg));
							}
						}
					}
				}

				// Combine into one args list
				let args = new String[runArgs.Count + datArgs.Count];

				int k = 0;
				for (; k < datArgs.Count; k++)
					args[k] = datArgs[k];

				for (int l = 0; l < runArgs.Count; l++)
					args[k + l] = runArgs[l];

				// Launch options
				bool launch = true;
				if (args.Count > 0)
				{
					// Example: game.exe -resolution 30 60 -windowed -devmode
					for (int i = 0; i < args.Count; i++)
					{
						// Skip arguments of arguments
						if (!args[i].StartsWith("-")) continue;

						if (launchOptions.ContainsKey(args[i]))
						{
							// Index after this argument, possibly start of argument arguments (or just anther argument or end)
							let subArgStart = i + 1;

							// Find end of argument arguments
							int subArgEnd = subArgStart;
							for (; subArgEnd < args.Count; subArgEnd++)
								if (args[subArgEnd].StartsWith("-"))
									break;

							// Run launch option - pass empty span when no argument arguments are given
							let res = launchOptions[args[i]].Invoke(subArgStart == subArgEnd ? Span<String>() : Span<String>(args, subArgStart, subArgEnd - subArgStart));

							if (res case .Err)
							{
								launch = false;
								break;
							}
						}
						else Log.Warning(scope $"Unknown launch option: {args[i]}");
					}
				}

				// Clean up launch options. We wont need them anymore
				DeleteDictionaryAndKeysAndValues!(launchOptions);
				launchOptions = null;

				// Clean up args
				DeleteContainerAndItems!(datArgs);
				delete args;

				// Exit on error (after cleaning up)
				if (!launch)
					return 1;
			}

			// Run onStart
			OnStart();
			OnStart.Dispose();

			if (RunGame() case .Err)
				return -1;

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
