using System;
using System.Reflection;
using System.Diagnostics;
using System.Collections;

using internal Pile;

// Disable in DEBUG by default, but leave option to keep it
// Because of this mechanic the PILE_IGNORE_PERFTRACK should only be used in this file
#if !DEBUG && !PILE_FORCE_PERFTRACK
#define PILE_IGNORE_PERFTRACK
#endif

namespace Pile
{
	[AttributeUsage(.Method)]
	public struct PerfTrackAttribute : Attribute, IComptimeMethodApply
	{
		String sectionNameOverride;
		bool appendOverride;

		public this(String sectionNameOverride = String.Empty, bool appendOverride = false)
		{
#if !PILE_IGNORE_PERFTRACK
			this.sectionNameOverride = sectionNameOverride;
			this.appendOverride = appendOverride;
#else
			this.sectionNameOverride = String.Empty;
			this.appendOverride = false;
#endif
		}

		[Comptime]
		public void ApplyToMethod(ComptimeMethodInfo methodInfo)
		{
#if !PILE_IGNORE_PERFTRACK
			// Make name
			let sectionName = appendOverride
				? scope String()
				: scope String(sectionNameOverride);

			if (sectionName.IsEmpty)
			{
				methodInfo.ToString(sectionName);
				sectionName.RemoveFromEnd(Math.Abs(sectionName.IndexOf('(') - sectionName.Length));

				if (appendOverride)
					sectionName..Append(' ')..Append(sectionNameOverride);
			}

			// Put tracking on method
			Compiler.EmitMethodEntry(methodInfo, """
				let __pt = scope System.Diagnostics.Stopwatch(true);
				""");

			Compiler.EmitMethodExit(methodInfo, scope $"""
				Performance.[Friend]SectionEnd("{sectionName}", __pt.Elapsed);
				""");
#endif
		}
	}

	public static class Performance
	{
		// @do !!! PerfTrack has to track call begin time too, since [PerfTrack] functions could be run stacked (reflect that in the cool diagram)
		// -> Dictionary<String, (callDepth, TimeSpan)> where callDepths is a static variable incremented in Begin and decremented in end calls

		// We need double buffering here because render functions should also be able to fill these
		// Thus the stats will just be delayed by one frame
		static Dictionary<String, TimeSpan> sectionDurationsFill;
		static Dictionary<String, TimeSpan> sectionDurationsRead;

		public static int Scale = 3;

#if PILE_IGNORE_PERFTRACK
		[SkipCall]
#endif
		internal static void Initialize()
		{
			sectionDurationsFill = new .();
			sectionDurationsRead = new .(); 
		}

#if PILE_IGNORE_PERFTRACK
		[SkipCall]
#endif
		[PerfTrack("PerfInternal")]
		internal static void Step()
		{
			Swap!(sectionDurationsFill, sectionDurationsRead);

			sectionDurationsFill.Clear();
		}

#if PILE_IGNORE_PERFTRACK
		[SkipCall]
#endif
		private static void SectionEnd(String sectionName, TimeSpan time)
		{
			if (sectionDurationsFill.GetValue(sectionName) case .Ok(let val))
			{
				sectionDurationsFill[sectionName] = val + time; // Sum up
			}
			else sectionDurationsFill.Add(sectionName, time);
		}

		// @do Render()
		// how does rendering work exactly
		// does this have a builtin batcher? where do the shaders come from?
		// i guess keep drawing manual for now? -- or ever?
		// does the user have to draw these? well currently, since there is no default font
		// should we change that? -- WITH PACKAGE BUILDING AS PART OF THE BUILD PROCESS WE COULD!
		// -> update docs in that case... these are also for you!
		[PerfTrack("PerfInternal")]
		public static void Render(Batch2D batch)
		{
			Debug.Assert(Scale > 0);

			const Point2 targetOffset = .(17, 1);
			const Point2 barOffset = .(1, 2);
			const int64 defaultTargetTicks = (int64)((double)Time.[Friend]TICKS_PER_SECOND / Time.[Friend]DEFAULT_TARGET_FPS);

			int64 targetTicks;
			if (Time.TargetFPS != 0)
				targetTicks = Time.targetTicks;
			else // Assume mark to be at default target frame rate (60fps)
				targetTicks = defaultTargetTicks;

			batch.Rect(.(targetOffset * Scale, Point2(Scale, Scale * 3)), .Red);

			if (Time.MinFPS != 0)
			{
				// draw bar where delta time cap is!
				batch.Rect(
					.(Point2((int)(targetOffset.X * ((double)Time.maxTicks / targetTicks)),
						targetOffset.Y) * Scale,
						Point2(Scale, Scale * 3)),
					.LightGray);
			}

			batch.Rect(
				.(barOffset * Scale,
					Point2((int)((targetOffset.X * Scale) * ((double)Time.loopTicks / targetTicks)),
					Scale)),
				.White);

			// @do draw text for FPS & delta time
			// maybe a perf graph over time?
			// maybe some sort of graph of the avaialable data (also possibly)

#if PILE_IGNORE_PERFTRACK
			// @do Draw perf table..
			// we probably will need some more font fitting and drawing improvements for this... very rudamentary and unscaled right now
			// draw like... the top ten things... 
#endif
		}

		// simple test to just draw perf bar for now
		public static void DrawPerf(Batch2D batch, int pixelScale = 3)
		{
			Debug.Assert(pixelScale > 0);

			const Point2 targetOffset = .(17, 1);
			const Point2 barOffset = .(1, 2);
			const int64 defaultTargetTicks = (int64)((double)Time.[Friend]TICKS_PER_SECOND / Time.[Friend]DEFAULT_TARGET_FPS);

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
					.LightGray);
			}

			batch.Rect(
				.(barOffset * pixelScale,
					Point2((int)((targetOffset.X * pixelScale) * ((double)Time.loopTicks / targetTicks)),
					pixelScale)),
				.White);
		}
	}
}
