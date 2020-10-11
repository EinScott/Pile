using System;
using System.Collections;
using System.Diagnostics;
using System.Threading;
using System.IO;

/* 
 * DEFINES:
 * PILE_LONG_LOG_RECORD - increases amount of output log lines Log remembers from 16 to 128
 * PILE_DISABLE_LOG_MESSAGES - adds [SkipCall] attribute to Log.Message functions
 * PILE_DISABLE_LOG_WARNINGS - adds [SkipCall] attribute to Log.Warning functions
 */

// TODO: asset importers, font support/spritefonts/batcher font drawing, audio, package unloading, (networking??)

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
			CondDelete!(Window);
			CondDelete!(Input);

			CondDelete!(Audio);
			CondDelete!(Graphics);
			CondDelete!(System);
		}

		static readonly Version Version = .(0, 1);

		static bool running;
		static bool exiting;
		static bool initialized;

		public static String Title { get; private set; }

		public static System System { get; private set; }
		public static Graphics Graphics { get; private set; }
		public static Audio Audio { get; private set; }

		public static Input Input { get; private set; }
		public static Window Window { get; private set; }

		static Game Game;

		public static Result<void, String> Initialize(String title, System system, Graphics graphics, Audio audio, int32 windowWidth, int32 windowHeight)
		{
			if (initialized) return .Err("Is already initialized");

			Log.Message(scope String("Initializing Pile {0}.{1}")..Format(Version.Major, Version.Minor));
			var w = scope Stopwatch(true);
			Title = title;
			System = system;
			Graphics = graphics;
			Audio = audio;

			// Print platform
			{
				let s = scope String();
				Environment.OSVersion.ToString(s);

				Log.Message(scope String("Platform: {0} (Bfp {1})")..Format(s, Environment.OSVersion.Platform));
			}

			// System init
			if (System != null)
			{
				System.[Friend]Initialize();
				Log.Message(scope String("System: {0}")..Format(System.ApiName));
				
				Window = System.[Friend]CreateWindow(windowWidth, windowHeight);
				Input = System.[Friend]CreateInput();
				System.[Friend]DetermineDataPaths(title);

				Directory.SetCurrentDirectory(System.DataPath);
			}

			// Graphics init
			if (Graphics != null)
			{
				Graphics.[Friend]Initialize();
				Log.Message(scope String("Graphics: {0} {1}.{2} ({3})")..Format(Graphics.ApiName, Graphics.MajorVersion, Graphics.MinorVersion, Graphics.DeviceName));
			}

			// Audio init
			if (Audio != null)
			{
				Audio.[Friend]Initialize();
				Log.Message(scope String("Audio: {0} {1}.{2}")..Format(Audio.ApiName, Audio.MajorVersion, Audio.MinorVersion));
			}

			Packages.[Friend]Initialize();

			w.Stop();
			Log.Message(scope String("Pile initialized (took {0}ms)")..Format(w.Elapsed.Milliseconds));

			initialized = true;
			return .Ok;
		}

		public static Result<void, String> Start(Game game, bool deleteGameOnShutdown = true)
		{
			if (running || exiting) return .Err("Is already running");
			else if (!initialized) return .Err("Core must be initialized first");
			else if (game == null) return .Err("Game is null");

			Log.Message("Starting up game");
			Game = game;

			let timer = scope Stopwatch(true);
			double sleepError = 0;
			var frameCount = 0;
			var frameTicks = 0L;

			int64 lastTime = 0;
			int64 currTime;
			int64 diffTime;

			running = true;
			CallStartup();

			while(running)
			{
				// step time and diff
				currTime = timer.[Friend]GetElapsedDateTimeTicks();
				diffTime = currTime - lastTime;
				lastTime = currTime;

				// Variable time step
				Time.[Friend]RawDuration += diffTime;
				Time.[Friend]Duration += Time.Scale == 1 ? diffTime : (int64)Math.Round(diffTime * Time.Scale);
				Time.[Friend]RawDelta = (float)(diffTime * TimeSpan.[Friend]SecondsPerTick);
				Time.[Friend]Delta = Time.RawDelta * Time.Scale;

				// Update
				CallUpdate();

				// Render
				if (!exiting && !Window.Closed)
				{
					Window.[Friend]Render(); // Calls CallRender()
					Window.[Friend]Present();
				}

				// Count FPS
				frameCount++;
				if ((double)(timer.[Friend]GetElapsedDateTimeTicks() - frameTicks) * TimeSpan.[Friend]SecondsPerTick >= 1)
				{
					Time.[Friend]FPS = frameCount;
					frameTicks = timer.[Friend]GetElapsedDateTimeTicks();
					frameCount = 0;
				}

				// Wait for FPS
				if ((float)(timer.[Friend]GetElapsedDateTimeTicks() - currTime) * TimeSpan.[Friend]MillisecondsPerTick + sleepError < Time.[Friend]targetMilliseconds)
				{
					let sleep = Time.[Friend]targetMilliseconds - (timer.[Friend]GetElapsedDateTimeTicks() - currTime) * TimeSpan.[Friend]MillisecondsPerTick + sleepError;
					let realSleep = (int32)Math.Floor(sleep);

					if (sleep > 0) Thread.Sleep(realSleep);

					sleepError = realSleep - sleep;
				}
			}

			CallShutdown();

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

		static void CallStartup()
		{
			Game.[Friend]Startup();
		}

		static void CallUpdate()
		{
			Graphics?.[Friend]Update();
			if (System != null)
			{
				Input.[Friend]Step();
				System.[Friend]Update();
			}

			Game.[Friend]Update();
		}

		static void CallRender()
		{
			Game.[Friend]Render();
			Graphics?.[Friend]AfterRender();
		}

		static void CallShutdown()
		{
			Game.[Friend]Shutdown();
		}
	}
}
