using System;
using System.Collections;
using System.Diagnostics;
using System.Threading;
using System.IO;

using internal Pile;

namespace Pile
{
	[Optimize]
	static class Core
	{
		static this()
		{
			Title = new .();
		}

		static ~this()
		{
			if (run) Delete();

			delete Title;
		}

		static void Delete() // @do we'll see what really remains of this, maybe we can just make all static, maybe we need some conducting / static init order
		{
			// Delete assets and textures while modules are still present
			delete Assets;
		}

		// Used for Log/info only (to better trace back/ignore issues and bugs base on error logs).
		// '.Minor' should be incremented for changes incompatible with older versions.
		// '.Major' is incremented at milestones or big changes.
		static readonly Version Version = .(1, 1);

		internal static bool run;
		static bool exiting;

		public static String Title { get; private set; }

		public static Assets Assets { get; private set; }

		static Game Game;

		internal static Result<void> Run(RunConfig config)
		{
			Debug.Assert(!run, "Core was already run");
			Debug.Assert(config.gameTitle.Ptr != null, "Pile.EntryPoint.RunPreferences.gameTitle has to be set. Provide an unchanging, file system safe string literal");
			Debug.Assert(config.createGame != null, "Pile.EntryPoint.RunPreferences.createGame has to be set. Provide a function that returns an instance of your game");
			Runtime.Assert(EntryPoint.CommandLine != null, "Set Pile.EntryPoint as your project entry point location");

			let game = config.createGame();
			Debug.Assert(game != null, "Game cannot be null");

			run = true;

			Log.Info(scope $"Initializing Pile {Version.Major}.{Version.Minor}");
			var w = scope Stopwatch(true);
			Title.Set(config.gameTitle);

			// Print platform
			{
				let s = scope String();
				Environment.OSVersion.ToString(s);

				Log.Info(scope $"Platform: {s} (bfp: {Environment.OSVersion.Platform})");
			}

			// System init
			{
				System.Initialize();
				
				System.DetermineDataPaths(Title);
				Directory.SetCurrentDirectory(System.DataPath);

				System.Window = new Window(config.windowTitle.Ptr == null ? config.gameTitle : config.windowTitle, config.windowWidth, config.windowHeight, config.windowState);
				Input.Initialize();

				Log.Info(scope $"System: {System.ApiName} {System.MajorVersion}.{System.MinorVersion} ({System.Info})");
			}

			// Graphics init
			{
				Graphics.Initialize();
				Log.Info(scope $"Graphics: {Graphics.ApiName} {Graphics.MajorVersion}.{Graphics.MinorVersion} ({Graphics.Info})");
			}

			// Audio init
			{
				Audio.Initialize();
				Log.Info(scope $"Audio: {Audio.ApiName} {Audio.MajorVersion}.{Audio.MinorVersion} ({Audio.Info})");
			}

			Assets = new Assets();
			Log.Initialize();
			Performance.Initialize();
			BeefPlatform.Initialize();

			w.Stop();
			Log.Info(scope $"Pile initialized (took {w.Elapsed.Milliseconds}ms)");

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
				if (Time.targetTicks != 0 && Time.maxTicks == Time.targetTicks) // Cannot lock frame rate to 0
				{
					// Still calculate actual fps
					currTime = timer.[Friend]GetElapsedDateTimeTicks();

					// Force diffTime and therefore deltas regardless of actual performance
					diffTime = Time.targetTicks;
				}
				else
				{
					// Run variable time step
					currTime = timer.[Friend]GetElapsedDateTimeTicks();
					
					diffTime = Math.Min(Time.maxTicks, currTime - lastTime);
					lastTime = currTime;
				}

				CallUpdate(diffTime);

				CallRender();

				{
					// Record FPS
					frameCount++;
					let newTime = timer.[Friend]GetElapsedDateTimeTicks();
					if ((float)(newTime - lastCounted) / TimeSpan.TicksPerSecond >= 1)
					{
						Time.FPS = frameCount;
						lastCounted = timer.[Friend]GetElapsedDateTimeTicks();
						frameCount = 0;
					}

					// Record loop ticks (delta without sleep)
					Time.loopTicks = newTime - currTime;
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

			delete Game;
			return .Ok;
		}

		public static void Exit()
		{
			if (run && !exiting)
			{
				exiting = true;
			}
		}

		[Inline]
		internal static void WindowRender()
		{
			Game.[Friend]Render();
			Graphics.AfterRender();
		}

		[PerfTrack, Inline]
		static void CallRender()
		{
			// Render
			if (!exiting && !System.Window.Closed)
			{
				System.Window.Render(); // Calls WindowRender()
				System.Window.Present();
			}
		}

		[PerfTrack, Inline]
		static void CallUpdate(int64 diffTime)
		{
			// Raw time
			Time.RawDuration += diffTime;
			Time.RawDelta = (float)(diffTime * TimeSpan.[Friend]SecondsPerTick);
			
			Performance.Step();

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
			Audio.AfterUpdate();
		}
	}
}
