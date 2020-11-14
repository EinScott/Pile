using System;
using System.Collections;
using System.Diagnostics;
using System.Threading;
using System.IO;

using internal Pile;

/* 
 * DEFINES:
 * PILE_LONG_LOG_RECORD - increases amount of output log lines Log remembers from 16 to 128
 * PILE_DISABLE_LOG_MESSAGES - adds [SkipCall] attribute to Log.Message functions
 * PILE_DISABLE_LOG_WARNINGS - adds [SkipCall] attribute to Log.Warning functions
 * PILE_DISABLE_PACKAGER - removes package building functionality from EntryPoint
 */

// TODO before public:  font support/batcher drawing (spritefonts?), audioclip (mp3... etc to AudioClip) and font (font (=> to Font) and spritefont (=> to SpriteFont) importer) importers!
//						finish example project, update/simplify readme
// TODO: support more platforms (build soloud & sdl for linux etc, investigate what is crashing win32 builds), look into other implementations (bgfx, ...), finish audio stuff (3d, filters, (fading)), support some mesh format?

namespace Pile
{
	public static class Core
	{
		static ~this()
		{
			if (initialized) Delete();
		}

		static void Delete()
		{
			// Delete assets and textures while modules are still present
			Assets.Shutdown();

			delete Window;
			delete Input;

			delete Audio;
			delete Graphics;
			delete System;
		}

		static readonly Version Version = .(0, 4);

		static bool running;
		static bool exiting;
		internal static bool initialized;

		public static String Title { get; private set; }

		public static System System { get; private set; }
		public static Graphics Graphics { get; private set; }
		public static Audio Audio { get; private set; }

		public static Input Input { get; private set; }
		public static Window Window { get; private set; }

		static Game Game;

		public static Result<void> Initialize(String title, System system, Graphics graphics, Audio audio, int32 windowWidth, int32 windowHeight)
		{
			if (initialized) LogErrorReturn!("Core is already initialized");
			if (system == null || graphics == null || audio == null) LogErrorReturn!("Core modules cannot be null");

#if DEBUG
			Console.WriteLine();
#endif
			Log.Message(scope $"Initializing Pile {Version.Major}.{Version.Minor}");
			var w = scope Stopwatch(true);
			Title = title;
			System = system;
			Graphics = graphics;
			Audio = audio;

			// Print platform
			{
				let s = scope String();
				Environment.OSVersion.ToString(s);

				Log.Message(scope $"Platform: {s} (bfp: {Environment.OSVersion.Platform})");
			}

			// System init
			{
				System.Initialize();
				Log.Message(scope $"System: {System.ApiName} {System.MajorVersion}.{System.MinorVersion} ({System.Info})");
				
				Window = System.CreateWindow(windowWidth, windowHeight);
				Input = System.CreateInput();
				System.DetermineDataPaths(Title);

				Directory.SetCurrentDirectory(System.DataPath);
			}

			// Graphics init
			{
				Graphics.Initialize();
				Log.Message(scope $"Graphics: {Graphics.ApiName} {Graphics.MajorVersion}.{Graphics.MinorVersion} ({Graphics.Info})");
			}

			// Audio init
			{
				Audio.Initialize();
				Log.Message(scope $"Audio: {Audio.ApiName} {Audio.MajorVersion}.{Audio.MinorVersion} ({Audio.Info})");
			}

			// Packages init
			Packages.Initialize();

			w.Stop();
			Log.Message(scope $"Pile initialized (took {w.Elapsed.Milliseconds}ms)");

			initialized = true;
			return .Ok;
		}

		public static Result<void> Start(Game game, bool deleteGameOnShutdown = true)
		{
			if (running || exiting) LogErrorReturn!("A game is already running");
			else if (!initialized) LogErrorReturn!("Core needs to be initialized first");
			else if (game == null) LogErrorReturn!("Game cannot be null");

			Game = game;

			let timer = scope Stopwatch(true);
			var frameCount = 0;
			var frameTicks = 0L;

			int64 lastTime = 0;
			int64 currTime;
			int64 diffTime;

			running = true;

			// Startup game
			Game.[Friend]Startup();

			while(running)
			{
				// step time and diff
				currTime = timer.[Friend]GetElapsedDateTimeTicks();
				diffTime = Math.Min(Time.maxTicks, currTime - lastTime);
				lastTime = currTime;

				// Raw time
				Time.RawDuration += diffTime;
				Time.RawDelta = (float)(diffTime * TimeSpan.[Friend]SecondsPerTick);

				// Update engine
				Graphics.Step();
				Input.Step();
				System.Step();

				if (Time.freeze > double.Epsilon)
				{
					// Freeze time
					Time.freeze -= Time.RawDelta;

					Time.Delta = 0;
					Game.[Friend]Step();

					if (Time.freeze <= double.Epsilon)
						Time.freeze = 0;
				}
				else
				{
					// Scaled time vars
					Time.Duration += Time.Scale == 1 ? diffTime : (int64)Math.Round(diffTime * Time.Scale);
					Time.Delta = Time.RawDelta * Time.Scale;
	
					// Update
					Game.[Friend]Step();
					Game.[Friend]Update();
				}

				// Render
				if (!exiting && !Window.Closed)
				{
					Window.Render(); // Calls CallRender()
					Window.Present();
				}

				// Count FPS
				frameCount++;
				if ((double)(timer.[Friend]GetElapsedDateTimeTicks() - frameTicks) / TimeSpan.TicksPerSecond >= 1)
				{
					Time.FPS = frameCount;
					frameTicks = timer.[Friend]GetElapsedDateTimeTicks();
					frameCount = 0;
				}

				// Wait for FPS
				if (timer.[Friend]GetElapsedDateTimeTicks() - currTime < Time.targetTicks && !exiting)
				{
					let sleep = Time.targetTicks - (timer.[Friend]GetElapsedDateTimeTicks() - currTime);
					
					if (sleep > 0)
						Thread.Sleep((int32)((double)sleep / TimeSpan.TicksPerMillisecond));
				}
			}

			// Shutdown game
			Game.[Friend]Shutdown();

			if (deleteGameOnShutdown) delete Game;
			Game = null;

			exiting = false;
			return .Ok;
		}

		public static void Exit()
		{
			if (running && !exiting)
			{
				exiting = true;
				running = false;
			}
		}

		internal static void CallRender()
		{
			Game.[Friend]Render();
			Graphics.AfterRender();
		}
	}
}
