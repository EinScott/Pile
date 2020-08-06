using System;
using System.Diagnostics;
using System.Threading;
using System.IO;

namespace Pile
{
	static
	{
		public static mixin CondDelete(var instance)
		{
			if (instance != null) delete instance;
		}	
	}

	public static class Core
	{
		static this()
		{
			//Runtime.SetCrashReportKind(.GUI);
		}

		static ~this()
		{
			if (running || exiting) Delete();
		}

		static void Delete()
		{
			CondDelete!(Game);

			CondDelete!(Window);
			CondDelete!(Input);

			CondDelete!(Audio);
			CondDelete!(Graphics);
			CondDelete!(System);
		}

		static bool running;
		static bool exiting;

		public static String Title { get; private set; }

		public static System System { get; private set; }
		public static Graphics Graphics { get; private set; }
		public static Audio Audio { get; private set; }

		public static Input Input { get; private set; }
		public static Window Window { get; private set; }

		static Game Game;

		public static Result<void, String> Run(Game game, System system, Graphics graphics, Audio audio, int windowWidth, int windowHeight, String title)
		{
			if (running || exiting) return .Err("Is already running");
			else if (game == null) return .Err("Game is null");

			Title = title;
			Game = game;
			System = system;
			Graphics = graphics;
			Audio = audio;

			System?.[Friend]Initialize();
			
			Window = System?.[Friend]CreateWindow(windowWidth, windowHeight);
			Input = System?.[Friend]CreateInput();
			System?.[Friend]DetermineDataPath();

			Directory.SetCurrentDirectory(System.DataPath);

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
				Time.[Friend]Duration += diffTime;
				Time.[Friend]RawDelta = (float)(diffTime * TimeSpan.[Friend]SecondsPerTick);
				Time.[Friend]Delta = Time.RawDelta * Time.Scale;

				// Update
				CallUpdate();

				// Render
				if (!exiting)
				{
					CallRender();
				}

				// Count FPS
				frameCount++;
				if ((double)(timer.[Friend]GetElapsedDateTimeTicks() - frameTicks) * TimeSpan.[Friend]SecondsPerTick >= 1)
				{
					Time.[Friend]FPS = frameCount;
					frameTicks = timer.[Friend]GetElapsedDateTimeTicks();
					frameCount = 0;
					Console.WriteLine(Time.FPS);
				}

				// Wait for FPS
				if ((float)(timer.[Friend]GetElapsedDateTimeTicks() - currTime) * TimeSpan.[Friend]MillisecondsPerTick + sleepError < Time.[Friend]targetMilliseconds)
				{
					let sleep = Time.[Friend]targetMilliseconds - (timer.[Friend]GetElapsedDateTimeTicks() - currTime) * TimeSpan.[Friend]MillisecondsPerTick + sleepError;
					
					Thread.Sleep((int32)Math.Floor(sleep));
					sleepError = Math.Floor(sleep) - sleep;
				}
			}

			CallShutdown();

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
			if (System != null)
			{
				Input.[Friend]Step();
				System.[Friend]Update();
			}

			Game.[Friend]Update();
		}

		static void CallRender()
		{

		}

		static void CallShutdown()
		{
			Game.[Friend]Shutdown();
		}
	}
}
