using System;
using System.Reflection;
using System.Diagnostics;
using System.Collections;

using internal Pile;

namespace Pile
{
	[AttributeUsage(.Method, .DisallowAllowMultiple)]
	public struct PerfTrackAttribute : Attribute, IComptimeMethodApply
	{
		String sectionNameOverride;

		public this(String sectionNameOverride = "") // more options?
		{
			this.sectionNameOverride = sectionNameOverride;
		}

		[Comptime]
		public void ApplyToMethod(ComptimeMethodInfo methodInfo)
		{
			// Make name
			let sectionName = scope String(sectionNameOverride);
			if (sectionName.IsEmpty)
			{
				methodInfo.ToString(sectionName);
				sectionName.RemoveFromEnd(Math.Abs(sectionName.IndexOf('(') - sectionName.Length));
			}

			// Put tracking on method
			Compiler.EmitMethodEntry(methodInfo, """
				let __pt = scope System.Diagnostics.Stopwatch(true);
				""");

			Compiler.EmitMethodExit(methodInfo, scope $"""
				Performance.[Friend]SectionEnd("{sectionName}", __pt.Elapsed);
				""");
		}
	}

	public static class Performance
	{
		private static void SectionEnd(String sectionName, TimeSpan time)
		{
			Log.Debug(scope $"{sectionName} in {time.Ticks}t");
		}

		// define to disable this?

		// draws current delta/max delta, fps
		// also provide some graphics of what is taking up what amount of time
		// so [PerfTrack] on function will track its duration here, which can be drawn (in some cool diagrams?)
		// this has to track call begin time too, since [PerfTrack] functions could be run stacked (reflect that in the cool diagram)
		// multiple things can have the same op name and their exec times will be summed up

		// does the user have to draw these? well currently, since there is no default font
		// should we change that? -- WITH PACKAGE BUILDING AS PART OF THE BUILD PROCESS WE COULD!
		// -> update docs in that case... these are also for you!

		// maybe a perf graph over time?

		static Dictionary<String, TimeSpan> sectionDurations;

		// simple test to just draw perf bar for now
		[PerfTrack("PerfInternal")]
		public static void DrawPerf(Batch2D batch, int pixelScale = 3) // make (pixel)Scale a static prop later?
		{
			Debug.Assert(pixelScale > 0);

			const Point2 targetOffset = .(17, 1);
			const Point2 barOffset = .(1, 2);
			const int64 defaultTargetTicks = (int64)((double)Time.[Friend]TICKS_PER_SECOND / Time.[Friend]DEFAULT_TARGET_FPS);

			// outline?

			int64 targetTicks;
			if (Time.TargetFPS != 0)
				targetTicks = Time.targetTicks;
			else // Assume mark to be at default target frame rate (60fps)
				targetTicks = defaultTargetTicks;

			batch.Rect(.(targetOffset * pixelScale, Point2(pixelScale, pixelScale * 3)), .Red);

			if (Time.MinFPS != 0)
			{
				// draw bar where delta time cap is!
				batch.Rect(
					.(Point2((int)(targetOffset.X * ((double)Time.maxTicks / targetTicks)),
						targetOffset.Y) * pixelScale,
						Point2(pixelScale, pixelScale * 3)),
					.Cyan);
			}

			batch.Rect(
				.(barOffset * pixelScale,
					Point2((int)((targetOffset.X * pixelScale) * ((double)Time.loopTicks / targetTicks)),
					pixelScale)),
				.White);
		}
	}
}
