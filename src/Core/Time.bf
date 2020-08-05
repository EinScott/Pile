using System;

namespace Pile
{
	public static class Time
	{
		static this() => TargetFPS = 60;

		static double targetMilliseconds;
		static int targetFps;
		public static int TargetFPS
		{
			get => targetFps;
			set
			{
				targetFps = value;
				targetMilliseconds = (double)1000 / targetFps;
			}
		}

		public static int FPS { get; private set; }
		public static TimeSpan Duration { get; private set; }

		public static float RawDelta { get; private set; }
		public static float Delta { get; private set; }

		public static float Scale;

		public static bool OnInterval(double time, double delta, double interval, double offset)
		{
		    return Math.Floor((time - offset - delta) / interval) < Math.Floor((time - offset) / interval);
		}

		public static bool OnInterval(double delta, double interval, double offset)
		{
		    return OnInterval(Duration.TotalSeconds, delta, interval, offset);
		}

		public static bool OnInterval(double interval, double offset = 0.0)
		{
		    return OnInterval(Duration.TotalSeconds, Delta, interval, offset);
		}

		public static bool BetweenInterval(double time, double interval, double offset)
		{
		    return (time - offset) % (interval * 2) >= interval;
		}

		public static bool BetweenInterval(double interval, double offset = 0.0)
		{
		    return BetweenInterval(Duration.TotalSeconds, interval, offset);
		}
	}
}
