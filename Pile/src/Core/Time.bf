using System;
using System.Diagnostics;

namespace Pile
{
	static class Time
	{
		const int DEFAULT_TARGET_FPS = 60;
		const int DEFAULT_MIN_FPS = 20;

		internal static int64 loopTicks; // Last loop duration without sleep

		internal static int64 targetTicks = (int64)((double)TimeSpan.TicksPerSecond / DEFAULT_TARGET_FPS);
		static uint targetFps = DEFAULT_TARGET_FPS;

		internal static int64 maxTicks = (int64)((double)TimeSpan.TicksPerSecond / DEFAULT_MIN_FPS);
		static uint minFps = DEFAULT_MIN_FPS;

		internal static int fps;
		internal static TimeSpan rawDuration;
		internal static TimeSpan duration;
		internal static float rawDelta;
		internal static float delta;
		internal static float freeze;
		internal static bool freezing;
		internal static bool forceFixed;

		public static float Scale = 1;

		/// The game tries to run at this frame rate. 0 means no upper limit.
		/// If the a frame is completed faster than the duration of a frame at this frame rate, the thread will sleep for the remaining time.
		public static uint TargetFPS
		{
			[Inline]
			get => targetFps;
			set
			{
				targetFps = value;

				// 0 pretty much means no upper limit
				if (targetFps == 0) targetTicks = 0;
				else
				{
					// Update target ms
					targetTicks = (int64)((double)TimeSpan.TicksPerSecond / targetFps);

					// Adjust MinFPS if needed
					if (targetFps < minFps)
					{
						Log.Warn("TargetFPS can't be lower than MinFPS. Automatically set MinFPS to TargetFPS - 1");
						MinFPS = targetFps - 1;
					}
				}

				forceFixed = targetFps != 0 && maxTicks == targetTicks;
			}
		}

		/// This limits how much the game tries to catch up. 0 means no lower limit.
		/// If the actual delta time is higher than the duration of one frame at this frame rate, RawDelta will be set to the later, thus the game will slow down.
		public static uint MinFPS
		{
			[Inline]
			get => minFps;
			set
			{
				minFps = value;

				// 0 pretty much means no lower limit
				if (minFps == 0) maxTicks = int64.MaxValue;
				else
				{
					// Update max ticks
					maxTicks = (int64)((double)TimeSpan.TicksPerSecond / minFps);

					// Adjust TargetFPS if needed
					if (minFps > targetFps)
					{
						// While this works, it leads to weird behavior which most likely is not intended.
						// The actual game would rightfully so run at a lower frame rate than the Delta(s) suggest it does, effectively speeding up the game like Scale.
						Log.Warn("MinFPS can't be larger than TargetFPS. Automatically set TargetFPS to MinFPS + 1");
						TargetFPS = minFps + 1;
					}
				}

				forceFixed = targetFps != 0 && maxTicks == targetTicks;
			}
		}

		[Inline]
		public static int FPS => fps;
		
		[Inline]
		/// All of these rely on the game loop clock and are likely not too accurate
		/// For actual real-time measurements use DateTime
		public static TimeSpan RawDuration => rawDuration;
		[Inline]
		public static TimeSpan Duration => duration;

		[Inline]
		public static float RawDelta => rawDelta;

		[Inline]
		public static float Delta => delta;

		[Inline]
		public static bool IsFreezing => freezing;

		public static void Freeze(float time, bool add = true)
		{
			if (add) freeze += time;
			else freeze = time;

			freezing = freeze > 0;
		}

		// NOTE: This is not a quirk of Target- or MinFPS, but is handled
		// separately in the Core.Run loop (See code at top of core loop)
		/// Use to fix Time.Delta to a fixed value. Sets both FPS options to the given fps value.
		/// Thus, the game itself will always run at the given frame rate, and slow down when
		/// the real frame rate is less than the one set here.
		public static void FixFPS(uint fps)
		{
			Debug.Assert(fps > 0);

			TargetFPS = fps;
			MinFPS = fps;
			forceFixed = true;
		}

		[Inline]
		public static bool OnInterval(double time, double delta, double interval, double offset)
		{
		    return Math.Floor((time - offset - delta) / interval) < Math.Floor((time - offset) / interval);
		}

		[Inline]
		public static bool OnInterval(double delta, double interval, double offset)
		{
		    return OnInterval(RawDuration.TotalSeconds, delta, interval, offset);
		}

		[Inline]
		public static bool OnInterval(double interval, double offset = 0.0)
		{
		    return OnInterval(RawDuration.TotalSeconds, Delta, interval, offset);
		}

		[Inline]
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
