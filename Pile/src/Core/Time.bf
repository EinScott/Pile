using System;

namespace Pile
{
	public static class Time
	{
		const int DEFAULT_TARGET_FPS = 60;
		const int DEFAULT_MIN_FPS = 20;

		internal static int64 targetTicks = (int64)((double)10000000 / DEFAULT_TARGET_FPS);
		static int targetFps = DEFAULT_TARGET_FPS;

		// The game tries to run at this framerate. 0 mean no upper limit.
		// If the a frame is completed faster than the duration of a frame at this framerate, the thread will sleep for the remaining time.
		public static int TargetFPS
		{
			get => targetFps;
			set
			{
				targetFps = value;

				// 0 pretty much means no upper limit
				if (targetFps == 0) targetTicks = 0;
				else
				{
					// Update target ms
					targetTicks = (int64)((double)10000000 / targetFps);

					// Adjust MinFPS if needed
					if (targetFps < minFPS)
					{
						Log.Warning("TargetFPS can't be lower than MinFPS. Automatically set MinFPS to TargetFPS");
						MinFPS = targetFps;
					}
				}
			}
		}

		internal static int64 maxTicks = (int64)((double)10000000 / DEFAULT_MIN_FPS);
		static int minFPS = DEFAULT_MIN_FPS;

		// This limits how much the game tries to catch up. 0 means no lower limit.
		// If the actual delta time is higher than the duration of one frame at this framerate, RawDelta will be set to the later, thus the game will slow down.
		public static int MinFPS
		{
			get => minFPS;
			set
			{
				minFPS = value;

				// 0 pretty much means no lower limit
				if (minFPS == 0) maxTicks = int64.MaxValue;
				else
				{
					// Update max ticks
					maxTicks = (int64)((double)10000000 / minFPS);

					// Adjust TargetFPS if needed
					if (minFPS > targetFps)
					{
						// While this works, it leads to weired behaviour which most likely is not intended.
						// The actual game would rightfully so run at a lower framerate than the Delta(s) suggest it does, effectively speeding up the game like Scale.
						Log.Warning("MinFPS can't be larger than TargetFPS. Automatically set TargetFPS to MinFPS");
						TargetFPS = minFPS;
					}
				}
			}
		}

		public static int FPS { get; internal set; }

		// All of these rely on the game loop clock and are likely not tooo accurate
		// For accurate time measurements use DateTime
		public static TimeSpan RawDuration { get; internal set; }
		public static TimeSpan Duration { get; internal set; }

		public static double RawDelta { get; internal set; }
		public static double Delta { get; internal set; }

		public static double Scale = 1;

		internal static double freeze = 0;
		public static void Freeze(double time, bool add = true)
		{
			if (add) freeze += time;
			else freeze = time;
		}

		public static bool OnInterval(double time, double delta, double interval, double offset)
		{
		    return Math.Floor((time - offset - delta) / interval) < Math.Floor((time - offset) / interval);
		}

		public static bool OnInterval(double delta, double interval, double offset)
		{
		    return OnInterval(RawDuration.TotalSeconds, delta, interval, offset);
		}

		public static bool OnInterval(double interval, double offset = 0.0)
		{
		    return OnInterval(RawDuration.TotalSeconds, Delta, interval, offset);
		}

		public static bool BetweenInterval(double time, double interval, double offset)
		{
		    return (time - offset) % (interval * 2) >= interval;
		}

		public static bool BetweenInterval(double interval, double offset = 0.0)
		{
		    return BetweenInterval(RawDuration.TotalSeconds, interval, offset);
		}
	}
}
