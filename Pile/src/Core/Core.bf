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

// TODO before public: asset importers, font support/spritefonts/batcher font drawing, asset/package system stuff (what to do about packers??), finish png writing
// TODO: audio, networking, support more platforms (build soloud & sdl for linux etc, investigate what is crashing win32 builds)

/* For networking to something like PILE_SERVER, wich automatically forces null implementations in some modules,
 * doesnt open a window, doesn't call render and instead sets up a new thread that receives commands from the console and triggers an event
 * Also have something like Networker, which is setup like any other core module

 * Question is, should this be forced into this class?? Probably, but maybe not... we'll see -- yes, it probably will
*/

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
			DeleteNotNull!(Window);
			DeleteNotNull!(Input);

			DeleteNotNull!(Audio);
			DeleteNotNull!(Graphics);
			DeleteNotNull!(System);
		}

		static readonly Version Version = .(0, 2);

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

		public static Result<void> Initialize(String title, System system, Graphics graphics, Audio audio, int32 windowWidth, int32 windowHeight)
		{
			if (initialized) LogErrorReturn!("Core is already initialized");
			if (system == null || graphics == null || audio == null) LogErrorReturn!("Core modules cannot be null");

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
			{
				System.[Friend]Initialize();
				Log.Message(scope String("System: {0}")..Format(System.ApiName));
				
				Window = System.[Friend]CreateWindow(windowWidth, windowHeight);
				Input = System.[Friend]CreateInput();
				System.[Friend]DetermineDataPaths(title);

				Directory.SetCurrentDirectory(System.DataPath);
			}

			// Graphics init
			{
				Graphics.[Friend]Initialize();
				Log.Message(scope String("Graphics: {0} {1}.{2} ({3})")..Format(Graphics.ApiName, Graphics.MajorVersion, Graphics.MinorVersion, Graphics.DeviceName));
			}

			// Audio init
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

		public static Result<void> Start(Game game, bool deleteGameOnShutdown = true)
		{
			if (running || exiting) LogErrorReturn!("A game is already running");
			else if (!initialized) LogErrorReturn!("Core needs to be initialized first");
			else if (game == null) LogErrorReturn!("Game cannot be null");

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

			// Startup game
			Game.[Friend]Startup();

			while(running)
			{
				// step time and diff
				currTime = timer.[Friend]GetElapsedDateTimeTicks();
				diffTime = currTime - lastTime;
				lastTime = currTime;

				// Raw time
				Time.[Friend]RawDuration += diffTime;
				Time.[Friend]RawDelta = diffTime * TimeSpan.[Friend]SecondsPerTick;

				// Update engine
				Graphics.[Friend]Step();
				Input.[Friend]Step();
				System.[Friend]Step();
				Game.[Friend]Step();

				if (Time.[Friend]freeze > double.Epsilon)
				{
					// Freeze time
					Time.[Friend]freeze -= Time.RawDelta;
					Log.Message(Time.[Friend]freeze);

					if (Time.[Friend]freeze <= double.Epsilon)
						Time.[Friend]freeze = 0;
				}
				else
				{
					// Scaled time vars
					Time.[Friend]Duration += Time.Scale == 1 ? diffTime : (int64)Math.Round(diffTime * Time.Scale);
					Time.[Friend]Delta = Time.RawDelta * Time.Scale;
	
					// Update
					Game.[Friend]Update();
				}

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

		static void CallRender()
		{
			Game.[Friend]Render();
			Graphics.[Friend]AfterRender();
		}
	}
}
