using System;
using System.Diagnostics;
using System.Threading;
using System.IO;

using internal Pile;

namespace Pile
{
	[Optimize]
	static class Core
	{
		// Used for Log/info only (to better trace back/ignore issues and bugs base on error logs).
		// '.Minor' should be incremented for changes incompatible with older versions.
		// '.Major' is incremented at milestones or big changes.
		static readonly Version Version = .(2, 1);

		internal static bool run;
		static bool exiting;
		static uint forceSleepMS;

		// This is interchangable.. if you really need to
		internal static function void() coreLoop = => DoCoreLoop;

		internal static Event<Action> OnInit = .() ~ _.Dispose();
		internal static Event<Action> OnDestroy = .() ~ _.Dispose();

		static String title = new .() ~ delete _;
		static Game Game;

		[Inline]
		public static StringView Title => title;

		internal static void Run(RunConfig config)
		{
			Debug.Assert(!run, "Core was already run");
			Debug.Assert(config.gameTitle.Ptr != null, "Pile.EntryPoint.RunPreferences.gameTitle has to be set. Provide an unchanging, file system safe string literal");
			Debug.Assert(config.createGame != null, "Pile.EntryPoint.RunPreferences.createGame has to be set. Provide a function that returns an instance of your game");

			run = true;

			Log.Info(scope $"Initializing Pile {Version.Major}.{Version.Minor}");
			var w = scope Stopwatch(true);
			title.Set(config.gameTitle);

			// Print platform
			{
				let s = scope String();
				Environment.OSVersion.ToString(s);

				Log.Info(scope $"Platform: {s} (bfp: {Environment.OSVersion.Platform})");
			}

			// System init
			{
				System.Initialize();
				
				System.DetermineDataPaths(title);
				Directory.SetCurrentDirectory(System.DataPath);

				System.window = new Window(config.windowTitle.Ptr == null ? config.gameTitle : config.windowTitle, config.windowWidth, config.windowHeight, config.windowState);
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
			
			Log.CreateDefaultPath();

			BeefPlatform.Initialize();
			Perf.Initialize();
			Assets.Initialize();

			w.Stop();
			Log.Info(scope $"Pile initialized (took {w.Elapsed.Milliseconds}ms)");

			OnInit();

			// Prepare for running game
			Game = config.createGame();
			Debug.Assert(Game != null, "Game cannot be null");

			// Startup game
			Game.[Friend]Startup();

			coreLoop();

			// Shutdown game
			Game.[Friend]Shutdown();

			// Destroy
			delete Game;

			OnDestroy();

			// Destroy things that are only set when Pile was actually run.
			// Since Pile isn't necessarily run (Tests, packager) things that
			// are created in static initialization should be deleted in static
			// destruction, and things from Initialize() in Destroy() or Delete()
			Assets.Destroy();

			Audio.Destroy();
			Graphics.Destroy();

			Input.Destroy();
			System.Delete();
			System.Destroy();

			run = false;
		}

		internal static void DoCoreLoop()
		{
			let timer = scope Stopwatch(true);
			var frameCount = 0;
			var lastCounted = 0L;

			int64 lastTime = 0;
			int64 currTime;
			int64 diffTime;

			while(!exiting)
			{
				currTime = timer.[Friend]GetElapsedDateTimeTicks();

				// Step time and diff
				if (!Time.forceFixed)
				{
					diffTime = Math.Min(Time.maxTicks, currTime - lastTime);
					lastTime = currTime;
				}
				else
				{
					// Force diffTime and therefore deltas regardless of actual performance
					diffTime = Time.targetTicks;
				}
				
				{
					PerfTrack!("Pile.Core.DoCoreLoop:Update");

					// Raw time
					Time.rawDuration += diffTime;
					Time.rawDelta = (float)(diffTime * TimeSpan.[Friend]SecondsPerTick);
					
					Perf.Step();

					// Update core modules
					Graphics.Step();
					Input.Step();
					System.Step();

					if (!Time.freezing)
					{
						// Scaled time
						Time.duration += Time.Scale == 1 ? diffTime : (int64)Math.Round(diffTime * Time.Scale);
						Time.delta = Time.rawDelta * Time.Scale;

						// Update game
						Game.[Friend]Step();
						Game.[Friend]Update();
					}
					else
					{
						// Freeze time
						Time.freeze -= Time.rawDelta;

						Time.delta = 0;
						Game.[Friend]Step();

						if (Time.freeze <= float.Epsilon)
						{
							Time.freeze = 0;
							Time.freezing = false;
						}
					}
					Audio.AfterUpdate();
				}

				// Render
				if (!exiting && !System.window.Closed)
				{
					{
						PerfTrack!("Pile.Core.DoCoreLoop:Render");

						System.window.Render(); // Calls WindowRender()
					}

					{
						PerfTrack!("Pile.Core.DoCoreLoop:Present");

						System.window.Present();
					}
				}

				// Record FPS
				frameCount++;
				let endCurrTime = timer.[Friend]GetElapsedDateTimeTicks();
				if (endCurrTime - lastCounted >= TimeSpan.TicksPerSecond)
				{
					Time.fps = frameCount;
					lastCounted = endCurrTime;
					frameCount = 0;
				}

				// Record loop ticks (delta without sleep)
				Time.loopTicks = endCurrTime - currTime;
#if DEBUG
				// We already have a timer running here...
				Perf.[Friend]EndSection("Pile.Core.DoCoreLoop (no sleep)", TimeSpan(Time.loopTicks));
#endif

				// Wait for FPS
				if (endCurrTime - currTime < Time.targetTicks && !exiting)
				{
					let sleep = Time.targetTicks - (timer.[Friend]GetElapsedDateTimeTicks() - currTime);
					
					if (sleep > TimeSpan.TicksPerMillisecond)
						Thread.Sleep((.)sleep / TimeSpan.TicksPerMillisecond);
				}

				// Force sleep
				if (forceSleepMS != 0)
				{
					timer.Stop();
					Thread.Sleep((int32)forceSleepMS);
					forceSleepMS = 0;
					timer.Start();
				}
			}
		}

		public static void Exit()
		{
			if (run && !exiting)
			{
				exiting = true;
			}
		}

		public static void Sleep(uint ms)
		{
			forceSleepMS = ms;
		}

		[Inline]
		internal static void WindowRender()
		{
			Game.[Friend]Render();
			Graphics.AfterRender();
		}
	}
}
