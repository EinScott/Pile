using System;

namespace Pile
{
	public static class Time
	{
		static double targetMilliseconds = (double)1000 / 60;
		static int targetFps = 60;
		public static int TargetFPS
		{
			get => targetFps;
			set
			{
				targetFps = value;

				// 0 pretty much means no limit
				if (targetFps == 0) targetMilliseconds = 0;
				else targetMilliseconds = (double)1000 / targetFps;
			}
		}

		public static int FPS { get; private set; }

		// All of these rely on the game loop clock and are likely not tooo accurate
		// For accurate time measurements use DateTime
		public static TimeSpan RawDuration { get; private set; }
		public static TimeSpan Duration { get; private set; }

		public static double RawDelta { get; private set; }
		public static double Delta { get; private set; }

		public static double Scale = 1;

		private static double freeze = 0;
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
