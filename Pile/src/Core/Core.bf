using System;
using System.Collections;
using System.Diagnostics;
using System.Threading;
using System.IO;

using internal Pile;

/* DEFINES:
 * PILE_LONG_LOG_RECORD - increases amount of output log lines Log remembers from 64 to 512
 * PILE_DISABLE_LOG_MESSAGES - adds [SkipCall] attribute to Log.Message functions
 * PILE_DISABLE_LOG_WARNINGS - adds [SkipCall] attribute to Log.Warning functions
 * PILE_DISABLE_PACKAGER - removes package building functionality from EntryPoint
 */

/* TODO
 * support more platforms (build soloud & sdl for linux etc)
 * look into other implementations (bgfx, ...)
 * finish audio stuff (3d, filters http://sol.gfxile.net/soloud/filters.html, (fading))
 * support some mesh format? (.obj or something)
 * make Assets suitable for more use cases (-> per-texture texture filtering option?)
 * make more importers? (for prerendered SpriteFonts..., Aseprite -> basically create ase instance, save that, and then load from that?)
 */

namespace Pile
{
	[Optimize]
	public static class Core
	{
		static this()
		{
			Title = new .();
		}

		static ~this()
		{
			if (run) Delete();
		}

		static void Delete()
		{
			// Delete assets and textures while modules are still present
			delete Assets;

			delete Window;
			delete Input;

			delete Audio;
			delete Graphics;
			delete System;

			delete Title;
		}

		// Used for Log/info only (to better trace back/ignore issues and bugs base on error logs).
		// '.Minor' should be incremented for changes incompatible with older versions.
		// '.Major' is incremented at milestones or big changes.
		static readonly Version Version = .(0, 8);

		internal static bool run;
		static bool exiting;

		public static String Title { get; private set; }

		public static System System { get; private set; }
		public static Graphics Graphics { get; private set; }
		public static Audio Audio { get; private set; }

		public static Input Input { get; private set; }
		public static Window Window { get; private set; }

		public static Assets Assets { get; private set; }

		static Game Game;

		public static Result<void> Run(Graphics graphics, uint32 windowWidth, uint32 windowHeight, Game game, StringView gameTitle, bool deleteGameOnShutdown = true)
		{
			Debug.Assert(!run, "Core was already run");
			Debug.Assert(graphics != null, "Core modules cannot be null");
			Debug.Assert(game != null, "Game cannot be null");

			run = true;
#if DEBUG
			Console.WriteLine();
#endif
			Log.Message(scope $"Initializing Pile {Version.Major}.{Version.Minor}");
			var w = scope Stopwatch(true);
			Title.Set(gameTitle);
			System = new System();
			Graphics = graphics;
			Audio = new Audio();

			// Print platform
			{
				let s = scope String();
				Environment.OSVersion.ToString(s);

				Log.Message(scope $"Platform: {s} (bfp: {Environment.OSVersion.Platform})");
			}

			// System init
			{
				System.Initialize();
				
				System.DetermineDataPaths(Title);
				Directory.SetCurrentDirectory(System.DataPath);

				Window = new Window(gameTitle, windowWidth, windowHeight);
				Input = new Input();

				Log.Message(scope $"System: {System.ApiName} {System.MajorVersion}.{System.MinorVersion} ({System.Info})");
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

			// Assets init
			Assets = new Assets();

			w.Stop();
			Log.Message(scope $"Pile initialized (took {w.Elapsed.Milliseconds}ms)");

			// Prepare for running game
			Game = game;

			let timer = scope Stopwatch(true);
			var frameCount = 0;
			var lastCounted = 0L;

			int64 lastTime = 0;
			int64 currTime;
			int64 diffTime;

			// Startup game
			Game.[Friend]Startup();

			while(!exiting)
			{
				// Step time and diff
				currTime = timer.[Friend]GetElapsedDateTimeTicks();
				diffTime = Math.Min(Time.maxTicks, currTime - lastTime);
				lastTime = currTime;

				// Raw time
				Time.RawDuration += diffTime;
				Time.RawDelta = (float)(diffTime * TimeSpan.[Friend]SecondsPerTick);

				// Update core modules
				Graphics.Step();
				Input.Step();
				System.Step();

				if (Time.freeze > float.Epsilon)
				{
					// Freeze time
					Time.freeze -= Time.RawDelta;

					Time.Delta = 0;
					Game.[Friend]Step();

					if (Time.freeze <= float.Epsilon)
						Time.freeze = 0;
				}
				else
				{
					// Scaled time
					Time.Duration += Time.Scale == 1 ? diffTime : (int64)Math.Round(diffTime * Time.Scale);
					Time.Delta = Time.RawDelta * Time.Scale;
	
					// Update game
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
				if ((float)(timer.[Friend]GetElapsedDateTimeTicks() - lastCounted) / TimeSpan.TicksPerSecond >= 1)
				{
					Time.FPS = frameCount;
					lastCounted = timer.[Friend]GetElapsedDateTimeTicks();
					frameCount = 0;
				}

				// Wait for FPS
				if (timer.[Friend]GetElapsedDateTimeTicks() - currTime < Time.targetTicks && !exiting)
				{
					let sleep = Time.targetTicks - (timer.[Friend]GetElapsedDateTimeTicks() - currTime);
					
					if (sleep > 0)
						Thread.Sleep((int32)((float)sleep / TimeSpan.TicksPerMillisecond));
				}
			}

			// Shutdown game
			Game.[Friend]Shutdown();

			if (deleteGameOnShutdown) delete Game;
			return .Ok;
		}

		public static void Exit()
		{
			if (run && !exiting)
			{
				exiting = true;
			}
		}

		internal static void CallRender()
		{
			Game.[Friend]Render();
			Graphics.AfterRender();
		}
	}
}
