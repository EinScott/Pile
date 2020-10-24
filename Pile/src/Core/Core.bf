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

// TODO before public: more default importers (aseprite, png), font support/spritefonts/batcher font drawing, finish png writing
// TODO: audio, support more platforms (build soloud & sdl for linux etc, investigate what is crashing win32 builds), look into bgfx graphics

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

		static readonly Version Version = .(0, 3);

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

			Log.Message(scope String()..AppendF("Initializing Pile {}.{}", Version.Major, Version.Minor));
			var w = scope Stopwatch(true);
			Title = title;
			System = system;
			Graphics = graphics;
			Audio = audio;

			// Print platform
			{
				let s = scope String();
				Environment.OSVersion.ToString(s);

				Log.Message(scope String()..AppendF("Platform: {} (Bfp {})", s, Environment.OSVersion.Platform));
			}

			// System init
			{
				System.Initialize();
				Log.Message(scope String()..AppendF("System: {}", System.ApiName));
				
				Window = System.CreateWindow(windowWidth, windowHeight);
				Input = System.CreateInput();
				System.DetermineDataPaths(title);

				Directory.SetCurrentDirectory(System.DataPath);
			}

			// Graphics init
			{
				Graphics.Initialize();
				Log.Message(scope String()..AppendF("Graphics: {} {}.{} ({})", Graphics.ApiName, Graphics.MajorVersion, Graphics.MinorVersion, Graphics.DeviceName));
			}

			// Audio init
			{
				Audio.Initialize();
				Log.Message(scope String()..AppendF("Audio: {} {}.{}", Audio.ApiName, Audio.MajorVersion, Audio.MinorVersion));
			}

			// Packages init
			Packages.Initialize();

			w.Stop();
			Log.Message(scope String()..AppendF("Pile initialized (took {}ms)", w.Elapsed.Milliseconds));

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
				Time.RawDelta = diffTime * TimeSpan.[Friend]SecondsPerTick;

				// Update engine
				Graphics.Step();
				Input.Step();
				System.Step();
				Game.[Friend]Step();

				if (Time.freeze > double.Epsilon)
				{
					// Freeze time
					Time.freeze -= Time.RawDelta;

					if (Time.freeze <= double.Epsilon)
						Time.freeze = 0;
				}
				else
				{
					// Scaled time vars
					Time.Duration += Time.Scale == 1 ? diffTime : (int64)Math.Round(diffTime * Time.Scale);
					Time.Delta = Time.RawDelta * Time.Scale;
	
					// Update
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
